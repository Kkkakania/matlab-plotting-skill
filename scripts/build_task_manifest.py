#!/usr/bin/env python3
"""Build the long-horizon scheme backlog for the plotting skill."""

from __future__ import annotations

import argparse
import json
import re
import sys
from collections import Counter
from pathlib import Path


ROOT_DIR = Path(__file__).resolve().parents[1]
DEFAULT_CATALOG = ROOT_DIR / "skills/matlab-plotting-skill/references/scheme-catalog.md"
ALLOWED_STATUSES = {"planned", "in_progress", "done", "blocked"}

TASK_LANES = [
    {
        "lane": "catalog",
        "title": "Clarify catalog entry",
        "acceptance": "Catalog entry names the scheme, family, best use, and palette.",
        "command_hint": "./scripts/render_with_matlab.sh --scheme-info {scheme}",
    },
    {
        "lane": "data-contract",
        "title": "Document input shape",
        "acceptance": "Data expectations are clear enough to choose the scheme without private examples.",
        "command_hint": "grep -n \"{scheme}\" skills/matlab-plotting-skill/references/scheme-catalog.md docs/chart-selection-guide.md",
    },
    {
        "lane": "demo-data",
        "title": "Provide synthetic demo data",
        "acceptance": "Synthetic data can exercise the scheme with no private files.",
        "command_hint": "MATLAB_BIN=/path/to/matlab ./scripts/render_with_matlab.sh --smoke-test --formats png",
    },
    {
        "lane": "selection-rule",
        "title": "Route suitable data to the scheme",
        "acceptance": "Plan-only output can explain when this scheme is selected or considered.",
        "command_hint": "./scripts/render_with_matlab.sh --plan-only --data <file> --goal <goal> --scheme {scheme}",
    },
    {
        "lane": "explicit-cli",
        "title": "Support explicit CLI selection",
        "acceptance": "The scheme can be requested with --scheme and receives a deterministic report.",
        "command_hint": "./scripts/render_with_matlab.sh --data <file> --goal <goal> --scheme {scheme} --formats png",
    },
    {
        "lane": "png-render",
        "title": "Render PNG output",
        "acceptance": "PNG output is generated and non-empty for the scheme.",
        "command_hint": "./scripts/render_with_matlab.sh --data <file> --goal <goal> --scheme {scheme} --formats png",
    },
    {
        "lane": "vector-render",
        "title": "Render vector output",
        "acceptance": "SVG or PDF output is generated for paper/report workflows.",
        "command_hint": "./scripts/render_with_matlab.sh --data <file> --goal <goal> --scheme {scheme} --formats svg,pdf",
    },
    {
        "lane": "report",
        "title": "Explain output in reports",
        "acceptance": "Markdown and JSON reports name the scheme and explain selection context.",
        "command_hint": "grep -R \"{scheme}\" <output-dir>/render_report.md <output-dir>/render_report.json",
    },
    {
        "lane": "gallery",
        "title": "Represent scheme in gallery",
        "acceptance": "Gallery generation can include the rendered output and catalog metadata.",
        "command_hint": "python3 scripts/build_gallery_index.py --dir <render-dir> --catalog skills/matlab-plotting-skill/references/scheme-catalog.md --out <index.md>",
    },
    {
        "lane": "safety",
        "title": "Pass privacy and provenance checks",
        "acceptance": "No private paths, forbidden files, or provenance-unclear assets are introduced.",
        "command_hint": "./scripts/check_privacy.sh && ./scripts/check_forbidden_files.sh",
    },
]


def parse_catalog(catalog_path: Path) -> list[dict[str, str]]:
    pattern = re.compile(
        r"^\| `(?P<scheme>[^`]+)` \| (?P<family>[^|]+) \| "
        r"(?P<best_for>[^|]+) \| (?P<palette>[^|]+) \|"
    )
    rows: list[dict[str, str]] = []
    for line in catalog_path.read_text(encoding="utf-8").splitlines():
        match = pattern.match(line)
        if match:
            rows.append({key: value.strip() for key, value in match.groupdict().items()})
    return rows


def load_status_overrides(overrides_path: Path | None) -> dict[str, str]:
    if overrides_path is None:
        return {}
    overrides = json.loads(overrides_path.read_text(encoding="utf-8"))
    if not isinstance(overrides, dict):
        print("Status overrides must be a JSON object.", file=sys.stderr)
        raise SystemExit(2)
    clean_overrides = {str(task_id): str(status) for task_id, status in overrides.items()}
    for status in clean_overrides.values():
        if status not in ALLOWED_STATUSES:
            print(f"Unknown task status: {status}", file=sys.stderr)
            print("Allowed statuses: " + ", ".join(sorted(ALLOWED_STATUSES)), file=sys.stderr)
            raise SystemExit(2)
    return clean_overrides


def build_tasks(
    catalog_path: Path,
    scheme_filter: str = "",
    lane_filter: str = "",
    status_overrides: dict[str, str] | None = None,
) -> dict[str, object]:
    status_overrides = status_overrides or {}
    schemes = parse_catalog(catalog_path)
    scheme_names = {scheme["scheme"] for scheme in schemes}
    lane_names = {lane["lane"] for lane in TASK_LANES}
    if scheme_filter and scheme_filter not in scheme_names:
        print(f"Unknown scheme filter: {scheme_filter}", file=sys.stderr)
        print("Run with --scheme-info or --list-schemes to inspect available schemes.", file=sys.stderr)
        raise SystemExit(2)
    if lane_filter and lane_filter not in lane_names:
        print(f"Unknown lane filter: {lane_filter}", file=sys.stderr)
        print("Available lanes: " + ", ".join(lane["lane"] for lane in TASK_LANES), file=sys.stderr)
        raise SystemExit(2)
    all_tasks: list[dict[str, str | int]] = []
    task_number = 1
    for scheme_info in schemes:
        scheme = scheme_info["scheme"]
        for lane in TASK_LANES:
            all_tasks.append(
                {
                    "number": task_number,
                    "id": f"TASK-{task_number:03d}-{scheme}-{lane['lane']}",
                    "scheme": scheme,
                    "family": scheme_info["family"],
                    "palette": scheme_info["palette"],
                    "lane": lane["lane"],
                    "title": lane["title"],
                    "acceptance": lane["acceptance"],
                    "command_hint": lane["command_hint"].format(scheme=scheme),
                    "status": "planned",
                }
            )
            task_number += 1
    task_ids = {str(task["id"]) for task in all_tasks}
    for task_id in status_overrides:
        if task_id not in task_ids:
            print(f"Unknown task override ID: {task_id}", file=sys.stderr)
            raise SystemExit(2)
    for task in all_tasks:
        task_id = str(task["id"])
        if task_id in status_overrides:
            task["status"] = status_overrides[task_id]
    tasks = [
        task
        for task in all_tasks
        if (not scheme_filter or task["scheme"] == scheme_filter)
        and (not lane_filter or task["lane"] == lane_filter)
    ]
    family_counts = dict(Counter(str(task["family"]) for task in tasks))
    lane_counts = dict(Counter(str(task["lane"]) for task in tasks))
    status_counts = dict(Counter(str(task["status"]) for task in tasks))
    return {
        "source_catalog": str(catalog_path.relative_to(ROOT_DIR)),
        "scheme_count": len(schemes),
        "lane_count": len(TASK_LANES),
        "task_count": len(tasks),
        "filters": {"scheme": scheme_filter, "lane": lane_filter},
        "family_counts": family_counts,
        "lane_counts": lane_counts,
        "status_counts": status_counts,
        "tasks": tasks,
    }


def write_markdown(manifest: dict[str, object], output_path: Path) -> None:
    tasks = manifest["tasks"]
    assert isinstance(tasks, list)
    lines = [
        "# Long-Horizon Scheme Backlog",
        "",
        "This board is a planning backlog, not a release cadence. Batch related",
        "tasks into normal maintenance releases instead of tagging every row.",
        "",
        f"Total schemes: {manifest['scheme_count']}",
        f"Task lanes per scheme: {manifest['lane_count']}",
        f"Total tasks: {manifest['task_count']}",
        "",
    ]
    filters = manifest["filters"]
    assert isinstance(filters, dict)
    active_filters = [f"{key}={value}" for key, value in filters.items() if value]
    if active_filters:
        lines.extend([f"Active filters: {', '.join(active_filters)}", ""])
    lines.extend(
        [
            "## Family Summary",
            "",
            "| Family | Tasks |",
            "|---|---:|",
        ]
    )
    for family, count in manifest["family_counts"].items():
        lines.append(f"| {family} | {count} |")
    lines.extend(
        [
            "",
            "## Lane Summary",
            "",
            "| Lane | Tasks |",
            "|---|---:|",
        ]
    )
    for lane, count in manifest["lane_counts"].items():
        lines.append(f"| {lane} | {count} |")
    lines.extend(
        [
            "",
            "## Status Summary",
            "",
            "| Status | Tasks |",
            "|---|---:|",
        ]
    )
    for status, count in manifest["status_counts"].items():
        lines.append(f"| {status} | {count} |")
    lines.extend(
        [
            "",
            "## Task Board",
            "",
            "| ID | Scheme | Lane | Goal | Acceptance | Command Hint | Status |",
            "|---|---|---|---|---|---|---|",
        ]
    )
    for task in tasks:
        lines.append(
            f"| `{task['id']}` | `{task['scheme']}` | {task['lane']} | "
            f"{task['title']} | {task['acceptance']} | `{task['command_hint']}` | {task['status']} |"
        )
    output_path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--catalog", type=Path, default=DEFAULT_CATALOG)
    parser.add_argument("--json-out", type=Path, required=True)
    parser.add_argument("--markdown-out", type=Path, required=True)
    parser.add_argument("--scheme", default="", help="Only include tasks for one scheme.")
    parser.add_argument("--lane", default="", help="Only include tasks for one task lane.")
    parser.add_argument("--status-overrides", type=Path, default=None, help="JSON object mapping task IDs to statuses.")
    args = parser.parse_args()

    manifest = build_tasks(args.catalog, args.scheme, args.lane, load_status_overrides(args.status_overrides))
    args.json_out.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    write_markdown(manifest, args.markdown_out)
    print(
        f"Wrote {manifest['task_count']} backlog tasks for "
        f"{manifest['scheme_count']} schemes: {args.json_out}, {args.markdown_out}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
