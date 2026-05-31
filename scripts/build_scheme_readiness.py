#!/usr/bin/env python3
"""Build a user-facing scheme readiness matrix."""

from __future__ import annotations

import argparse
import json
from pathlib import Path

from build_gallery_index import parse_catalog
from build_task_manifest import TASK_LANES

ROOT_DIR = Path(__file__).resolve().parents[1]
DEFAULT_CATALOG = ROOT_DIR / "skills/matlab-plotting-skill/references/scheme-catalog.md"
DEFAULT_STATUS = ROOT_DIR / "docs/task-status.json"
DEFAULT_GALLERY = ROOT_DIR / "docs/gallery"

KEY_LANES = ["catalog", "data-contract", "explicit-cli", "png-render", "vector-render", "report", "gallery", "safety"]
LANE_NAMES = {lane["lane"] for lane in TASK_LANES}
MARKS = {True: "yes", False: "no"}


def task_id_for(scheme_index: int, scheme: str, lane: str) -> str:
    if lane not in LANE_NAMES:
        raise ValueError(f"unknown lane: {lane}")
    lane_index = [item["lane"] for item in TASK_LANES].index(lane) + 1
    number = scheme_index * len(TASK_LANES) + lane_index
    return f"TASK-{number:03d}-{scheme}-{lane}"


def readiness_label(row: dict[str, object]) -> str:
    if row["gallery_preview"] and all(row[lane] for lane in KEY_LANES):
        return "gallery-backed"
    if row["gallery_preview"]:
        return "preview available"
    if row["explicit-cli"] and row["png-render"]:
        return "render path started"
    return "cataloged"


def build_readiness(catalog: Path, status_file: Path, gallery_dir: Path) -> list[dict[str, object]]:
    statuses = json.loads(status_file.read_text(encoding="utf-8")) if status_file.exists() else {}
    rows: list[dict[str, object]] = []
    for scheme_index, scheme_info in enumerate(parse_catalog(catalog)):
        scheme = scheme_info["scheme"]
        row: dict[str, object] = {
            "scheme": scheme,
            "family": scheme_info["family"],
            "best_for": scheme_info["best_for"],
            "gallery_preview": (gallery_dir / f"{scheme}.png").is_file(),
        }
        for lane in KEY_LANES:
            row[lane] = statuses.get(task_id_for(scheme_index, scheme, lane)) == "done"
        row["readiness"] = readiness_label(row)
        rows.append(row)
    return rows


def write_markdown(rows: list[dict[str, object]], output: Path) -> None:
    counts: dict[str, int] = {}
    for row in rows:
        label = str(row["readiness"])
        counts[label] = counts.get(label, 0) + 1
    lines = [
        "# Scheme Readiness",
        "",
        "This matrix separates the 50-scheme catalog from the smaller set of schemes",
        "that currently have committed gallery previews and completed support tasks.",
        "",
        "## Summary",
        "",
        "| Readiness | Schemes |",
        "|---|---:|",
    ]
    for label in ["gallery-backed", "preview available", "render path started", "cataloged"]:
        lines.append(f"| {label} | {counts.get(label, 0)} |")
    lines.extend(
        [
            "",
            "## Matrix",
            "",
            "| Scheme | Family | Readiness | Gallery | Data Contract | Explicit CLI | PNG | Vector | Report | Safety |",
            "|---|---|---|---|---|---|---|---|---|---|",
        ]
    )
    for row in rows:
        gallery = f"[preview](gallery/{row['scheme']}.png)" if row["gallery_preview"] else "no"
        lines.append(
            "| "
            f"`{row['scheme']}` | {row['family']} | {row['readiness']} | {gallery} | "
            f"{MARKS[bool(row['data-contract'])]} | {MARKS[bool(row['explicit-cli'])]} | "
            f"{MARKS[bool(row['png-render'])]} | {MARKS[bool(row['vector-render'])]} | "
            f"{MARKS[bool(row['report'])]} | {MARKS[bool(row['safety'])]} |"
        )
    lines.extend(
        [
            "",
            "## Notes",
            "",
            "- `gallery-backed` means the key task lanes are marked done and a committed PNG preview exists.",
            "- `preview available` means a committed PNG exists, but at least one support lane is still pending.",
            "- `cataloged` means the scheme is part of the catalog and roadmap, but should be treated as less proven.",
            "",
        ]
    )
    output.write_text("\n".join(lines), encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--catalog", type=Path, default=DEFAULT_CATALOG)
    parser.add_argument("--status", type=Path, default=DEFAULT_STATUS)
    parser.add_argument("--gallery", type=Path, default=DEFAULT_GALLERY)
    parser.add_argument("--out", type=Path, default=ROOT_DIR / "docs/scheme-readiness.md")
    args = parser.parse_args()
    rows = build_readiness(args.catalog, args.status, args.gallery)
    write_markdown(rows, args.out)
    print(f"Wrote scheme readiness for {len(rows)} schemes: {args.out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
