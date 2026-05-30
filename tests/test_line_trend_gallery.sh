#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

GALLERY="$ROOT_DIR/docs/gallery"
CATALOG="$ROOT_DIR/skills/matlab-plotting-skill/references/scheme-catalog.md"
INDEX="$TMP_DIR/gallery-index.md"

if [[ ! -s "$GALLERY/line_trend.png" ]]; then
  echo "missing committed line_trend gallery preview" >&2
  exit 1
fi

python3 "$ROOT_DIR/scripts/build_gallery_index.py" \
  --dir "$GALLERY" \
  --catalog "$CATALOG" \
  --out "$INDEX" \
  --format png \
  --only-existing

grep -q '| `line_trend` | Trend | One time or ordered series | !\[line_trend\](.*line_trend.png) |' "$INDEX"

if grep -q "| \`line_trend\` .* missing" "$INDEX"; then
  echo "line_trend gallery row should link an image, not report missing" >&2
  exit 1
fi

echo "line_trend gallery test passed."
