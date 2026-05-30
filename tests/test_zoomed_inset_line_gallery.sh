#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

GALLERY="$ROOT_DIR/docs/gallery"
CATALOG="$ROOT_DIR/skills/matlab-plotting-skill/references/scheme-catalog.md"
INDEX="$TMP_DIR/gallery-index.md"

if [[ ! -s "$GALLERY/zoomed_inset_line.png" ]]; then
  echo "missing committed zoomed_inset_line gallery preview" >&2
  exit 1
fi

python3 "$ROOT_DIR/scripts/build_gallery_index.py" \
  --dir "$GALLERY" \
  --catalog "$CATALOG" \
  --out "$INDEX" \
  --format png \
  --only-existing

grep -q '| `zoomed_inset_line` | Trend | Long trend with a local event | !\[zoomed_inset_line\](.*zoomed_inset_line.png) |' "$INDEX"
grep -q 'docs/gallery/zoomed_inset_line.png' "$ROOT_DIR/README.md"
grep -q '| `zoomed_inset_line.png` | `zoomed_inset_line` | synthetic demo data |' "$ROOT_DIR/docs/gallery/provenance.md"

echo "zoomed_inset_line gallery test passed."
