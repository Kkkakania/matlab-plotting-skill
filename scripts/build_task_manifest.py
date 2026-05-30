#!/usr/bin/env python3
"""Build an exact 500-task roadmap for the plotting skill."""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path


ROOT_DIR = Path(__file__).resolve().parents[1]
DEFAULT_CATALOG = ROOT_DIR / "skills/matlab-plotting-skill/references/scheme-catalog.md"

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


def build_tasks(catalog_path: Path) -> dict[str, object]:
    schemes = parse_catalog(catalog_path)
    tasks: list[dict[str, str | int]] = []
    task_number = 1
    for scheme_info in schemes:
        scheme = scheme_info["scheme"]
        for lane in TASK_LANES:
            tasks.append(
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
    return {
        "source_catalog": str(catalog_path.relative_to(ROOT_DIR)),
        "scheme_count": len(schemes),
        "lane_count": len(TASK_LANES),
        "task_count": len(tasks),
        "tasks": tasks,
    }


def write_markdown(manifest: dict[str, object], output_path: Path) -> None:
    tasks = manifest["tasks"]
    assert isinstance(tasks, list)
    lines = [
        "# 500 Task Plan",
        "",
        f"Total schemes: {manifest['scheme_count']}",
        f"Task lanes per scheme: {manifest['lane_count']}",
        f"Total tasks: {manifest['task_count']}",
        "",
        "| ID | Scheme | Lane | Title | Status |",
        "|---|---|---|---|---|",
    ]
    for task in tasks:
        lines.append(
            f"| `{task['id']}` | `{task['scheme']}` | {task['lane']} | "
            f"{task['title']} | {task['status']} |"
        )
    output_path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--catalog", type=Path, default=DEFAULT_CATALOG)
    parser.add_argument("--json-out", type=Path, required=True)
    parser.add_argument("--markdown-out", type=Path, required=True)
    args = parser.parse_args()

    manifest = build_tasks(args.catalog)
    args.json_out.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    write_markdown(manifest, args.markdown_out)
    print(
        f"Wrote {manifest['task_count']} planned tasks for "
        f"{manifest['scheme_count']} schemes: {args.json_out}, {args.markdown_out}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
