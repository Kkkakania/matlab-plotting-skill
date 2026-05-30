#!/usr/bin/env python3
"""Build a Markdown index for rendered gallery outputs."""

from __future__ import annotations

import argparse
import re
from pathlib import Path


SCHEME_ROW = re.compile(
    r"^\| `(?P<scheme>[^`]+)` \| (?P<family>[^|]+) \| (?P<best_for>[^|]+) \| (?P<palette>[^|]+) \|"
)


def parse_catalog(path: Path) -> list[dict[str, str]]:
    rows: list[dict[str, str]] = []
    for line in path.read_text(encoding="utf-8").splitlines():
        match = SCHEME_ROW.match(line)
        if match:
            rows.append({key: value.strip() for key, value in match.groupdict().items()})
    if not rows:
        raise SystemExit(f"No schemes found in catalog: {path}")
    return rows


def relative_link(target: Path, base: Path) -> str:
    return target.relative_to(base).as_posix() if target.is_relative_to(base) else target.as_posix()


def build_index(gallery_dir: Path, catalog: Path, output: Path, fmt: str, only_existing: bool) -> None:
    schemes = parse_catalog(catalog)
    output.parent.mkdir(parents=True, exist_ok=True)
    base = output.parent

    lines = [
        "# Gallery Index",
        "",
        f"Gallery directory: `{gallery_dir}`",
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

    output.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(f"Wrote gallery index: {output}")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--dir", required=True, type=Path, help="Directory containing rendered files.")
    parser.add_argument("--catalog", required=True, type=Path, help="Scheme catalog markdown file.")
    parser.add_argument("--out", required=True, type=Path, help="Markdown index output path.")
    parser.add_argument("--format", default="png", help="Rendered file extension to link.")
    parser.add_argument("--only-existing", action="store_true", help="Only include schemes with non-empty outputs.")
    args = parser.parse_args()

    if not args.dir.is_dir():
        raise SystemExit(f"Gallery directory not found: {args.dir}")
    if not args.catalog.is_file():
        raise SystemExit(f"Scheme catalog not found: {args.catalog}")
    build_index(args.dir, args.catalog, args.out, args.format.lstrip("."), args.only_existing)


if __name__ == "__main__":
    main()
