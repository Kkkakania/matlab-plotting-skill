#!/usr/bin/env python3
"""Build a machine-readable automation manifest for plotting schemes."""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path


ROOT_DIR = Path(__file__).resolve().parents[1]
DEFAULT_CATALOG = ROOT_DIR / "skills/matlab-plotting-skill/references/scheme-catalog.md"

CHECK_TEMPLATES = [
    ("catalog", "catalog-row", "scheme appears in references/scheme-catalog.md"),
    ("catalog", "list-text", "scheme appears in --list-schemes output"),
    ("catalog", "list-json", "scheme appears in --list-schemes-json output"),
    ("catalog", "scheme-info-text", "scheme has human-readable --scheme-info output"),
    ("catalog", "scheme-info-json", "scheme has machine-readable --scheme-info-json output"),
    ("selection", "demo-data", "synthetic demo data can be generated for the scheme"),
    ("selection", "explicit-scheme", "explicit --scheme selection can target the scheme"),
    ("selection", "plan-only", "plan-only flow can explain the scheme choice"),
    ("selection", "score-snapshot", "selection report includes candidate scoring context"),
    ("render", "png-export", "PNG export path is covered"),
    ("render", "svg-export", "SVG export path is covered"),
    ("render", "pdf-export", "PDF export path is covered"),
    ("render", "renderer-dispatch", "renderer dispatch maps the scheme to MATLAB code"),
    ("render", "visual-fixture", "visual fixture or smoke render can exercise the scheme"),
    ("report", "markdown-report", "Markdown render report records the scheme"),
    ("report", "json-report", "JSON render report records the scheme"),
    ("report", "gallery-index", "gallery index can link the scheme output"),
    ("report", "output-names", "output file names stay predictable"),
    ("safety", "privacy-paths", "reports avoid absolute local input paths"),
    ("safety", "forbidden-files", "workflow avoids committed binary/private artifacts"),
    ("safety", "palette", "scheme uses a declared palette family"),
    ("safety", "accessibility-note", "color choice can be checked against palette notes"),
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


def command_hint(scheme: str, check_name: str) -> str:
    base = "./scripts/render_with_matlab.sh"
    if check_name == "list-text":
        return f"{base} --list-schemes | grep {scheme}"
    if check_name == "list-json":
        return f"{base} --list-schemes-json"
    if check_name == "scheme-info-text":
        return f"{base} --scheme-info {scheme}"
    if check_name == "scheme-info-json":
        return f"{base} --scheme-info-json {scheme}"
    if check_name == "plan-only":
        return f"{base} --plan-only --data <file> --goal <goal> --scheme {scheme}"
    if check_name in {"png-export", "svg-export", "pdf-export"}:
        fmt = check_name.split("-")[0]
        return f"{base} --data <file> --goal <goal> --scheme {scheme} --formats {fmt}"
    if check_name == "visual-fixture":
        return "./scripts/run_visual_fixtures.sh"
    if check_name == "gallery-index":
        return "python3 scripts/build_gallery_index.py --dir <render-dir> --catalog <catalog> --out <index.md>"
    if check_name == "forbidden-files":
        return "./scripts/check_forbidden_files.sh"
    if check_name == "privacy-paths":
        return "./scripts/check_privacy.sh"
    return "./scripts/release_check.sh"


def build_manifest(catalog_path: Path) -> dict[str, object]:
    schemes = parse_catalog(catalog_path)
    checks = []
    for item in schemes:
        scheme = item["scheme"]
        for stage, check_name, purpose in CHECK_TEMPLATES:
            checks.append(
                {
                    "id": f"{scheme}.{stage}.{check_name}",
                    "scheme": scheme,
                    "family": item["family"],
                    "palette": item["palette"],
                    "stage": stage,
                    "check": check_name,
                    "purpose": purpose,
                    "command_hint": command_hint(scheme, check_name),
                }
            )
    return {
        "source_catalog": str(catalog_path.relative_to(ROOT_DIR)),
        "scheme_count": len(schemes),
        "checks_per_scheme": len(CHECK_TEMPLATES),
        "check_count": len(checks),
        "checks": checks,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--catalog", type=Path, default=DEFAULT_CATALOG)
    parser.add_argument("--out", type=Path, required=True)
    args = parser.parse_args()

    manifest = build_manifest(args.catalog)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    print(f"Wrote {manifest['check_count']} checks for {manifest['scheme_count']} schemes: {args.out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
