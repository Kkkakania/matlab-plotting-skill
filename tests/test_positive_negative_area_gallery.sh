#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

GALLERY="$ROOT_DIR/docs/gallery"
CATALOG="$ROOT_DIR/skills/matlab-plotting-skill/references/scheme-catalog.md"
INDEX="$TMP_DIR/gallery-index.md"

if [[ ! -s "$GALLERY/positive_negative_area.png" ]]; then
  echo "missing committed positive_negative_area gallery preview" >&2
  exit 1
fi

python3 "$ROOT_DIR/scripts/build_gallery_index.py" \
  --dir "$GALLERY" \
  --catalog "$CATALOG" \
  --out "$INDEX" \
  --format png \
  --only-existing

grep -q '| `positive_negative_area` | Trend | Signed change around zero | !\[positive_negative_area\](.*positive_negative_area.png) |' "$INDEX"
grep -q 'docs/gallery/positive_negative_area.png' "$ROOT_DIR/README.md"
grep -q '| `positive_negative_area.png` | `positive_negative_area` | synthetic demo data |' "$ROOT_DIR/docs/gallery/provenance.md"

echo "positive_negative_area gallery test passed."
