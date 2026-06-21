#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

GALLERY="$ROOT_DIR/docs/gallery"
CATALOG="$ROOT_DIR/skills/matlab-plotting-skill/references/scheme-catalog.md"
INDEX="$TMP_DIR/gallery-index.md"

if [[ ! -s "$GALLERY/stacked_time_series.png" ]]; then
  echo "missing committed stacked_time_series gallery preview" >&2
  exit 1
fi

python3 "$ROOT_DIR/scripts/build_gallery_index.py" \
  --dir "$GALLERY" \
  --catalog "$CATALOG" \
  --out "$INDEX" \
  --format png \
  --only-existing

grep -q '| `stacked_time_series` | Trend | Stacked synchronized signals | !\[stacked_time_series\](.*stacked_time_series.png) |' "$INDEX"
grep -q 'docs/gallery/stacked_time_series.png' "$ROOT_DIR/README.md"
grep -q 'docs/gallery/stacked_time_series.png' "$ROOT_DIR/README.zh-CN.md"
grep -q '| `stacked_time_series.png` | `stacked_time_series` | synthetic demo data |' "$ROOT_DIR/docs/gallery/provenance.md"

echo "stacked_time_series gallery test passed."
