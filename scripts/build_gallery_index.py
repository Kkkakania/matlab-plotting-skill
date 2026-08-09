#!/usr/bin/env python3
"""Build a Markdown index for rendered gallery outputs."""

from __future__ import annotations

import argparse
import difflib
import os
import re
from pathlib import Path


SCHEME_ROW = re.compile(
    r"^\| `(?P<scheme>[^`]+)` \| (?P<family>[^|]+) \| (?P<best_for>[^|]+) \| (?P<palette>[^|]+) \|"
)


def parse_catalog(path: Path) -> list[dict[str, str]]:
    rows: list[dict[str, str]] = []
    seen: set[str] = set()
    for line in path.read_text(encoding="utf-8").splitlines():
        match = SCHEME_ROW.match(line)
        if match:
            row = {key: value.strip() for key, value in match.groupdict().items()}
            scheme = row["scheme"]
            if scheme in seen:
                raise SystemExit(f"Duplicate scheme in catalog: {scheme}")
            seen.add(scheme)
            rows.append(row)
    if not rows:
        raise SystemExit(f"No schemes found in catalog: {path}")
    return rows


def relative_link(target: Path, base: Path) -> str:
    return Path(os.path.relpath(target.resolve(), start=base.resolve())).as_posix()


def render_index(gallery_dir: Path, catalog: Path, output: Path, fmt: str, only_existing: bool) -> str:
    schemes = parse_catalog(catalog)
    base = output.parent

    lines = [
        "# Gallery Index",
        "",
        f"Gallery directory: `{relative_link(gallery_dir, base)}`",
        "",
        "| Scheme | Family | Best For | Output |",
        "|---|---|---|---|",
    ]

    for row in schemes:
        image = gallery_dir / f"{row['scheme']}.{fmt}"
        if image.is_file() and image.stat().st_size > 0:
            link = relative_link(image, base)
            output_cell = f"![{row['scheme']}]({link})"
        else:
            if only_existing:
                continue
            output_cell = "missing"
        lines.append(
            f"| `{row['scheme']}` | {row['family']} | {row['best_for']} | {output_cell} |"
        )

    return "\n".join(lines) + "\n"


def build_index(gallery_dir: Path, catalog: Path, output: Path, fmt: str, only_existing: bool) -> None:
    content = render_index(gallery_dir, catalog, output, fmt, only_existing)
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(content, encoding="utf-8")
    print(f"Wrote gallery index: {output}")


def normalize_format(raw_format: str) -> str:
    fmt = raw_format.strip().lstrip(".").lower()
    if fmt not in {"png", "svg", "pdf"}:
        raise SystemExit("Invalid gallery format. Use one of: png, svg, pdf.")
    return fmt


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--dir", required=True, type=Path, help="Directory containing rendered files.")
    parser.add_argument("--catalog", required=True, type=Path, help="Scheme catalog markdown file.")
    parser.add_argument("--out", required=True, type=Path, help="Markdown index output path.")
    parser.add_argument("--format", default="png", help="Rendered file extension to link.")
    parser.add_argument("--only-existing", action="store_true", help="Only include schemes with non-empty outputs.")
    parser.add_argument("--check", action="store_true", help="Fail if the existing index differs from generated content.")
    args = parser.parse_args()

    if not args.dir.is_dir():
        raise SystemExit(f"Gallery directory not found: {args.dir}")
    if not args.catalog.is_file():
        raise SystemExit(f"Scheme catalog not found: {args.catalog}")
    fmt = normalize_format(args.format)
    if args.check:
        expected = render_index(args.dir, args.catalog, args.out, fmt, args.only_existing)
        if not args.out.is_file():
            raise SystemExit(f"Gallery index not found: {args.out}")
        actual = args.out.read_text(encoding="utf-8")
        if actual != expected:
            print("".join(difflib.unified_diff(actual.splitlines(True), expected.splitlines(True), fromfile=str(args.out), tofile=f"{args.out} (generated)")), end="")
            raise SystemExit("Gallery index is stale; regenerate it without --check.")
        print(f"Gallery index is current: {args.out}")
        return
    build_index(args.dir, args.catalog, args.out, fmt, args.only_existing)


if __name__ == "__main__":
    main()
