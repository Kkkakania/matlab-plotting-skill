#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

GALLERY="$ROOT_DIR/docs/gallery"
CATALOG="$ROOT_DIR/skills/matlab-plotting-skill/references/scheme-catalog.md"
INDEX="$TMP_DIR/gallery-index.md"

if [[ ! -s "$GALLERY/multi_line_comparison.png" ]]; then
  echo "missing committed multi_line_comparison gallery preview" >&2
  exit 1
fi

python3 "$ROOT_DIR/scripts/build_gallery_index.py" \
  --dir "$GALLERY" \
  --catalog "$CATALOG" \
  --out "$INDEX" \
  --format png \
  --only-existing

grep -q '| `multi_line_comparison` | Trend | Several comparable series | !\[multi_line_comparison\](.*multi_line_comparison.png) |' "$INDEX"
grep -q 'docs/gallery/multi_line_comparison.png' "$ROOT_DIR/README.md"
grep -q '| `multi_line_comparison.png` | `multi_line_comparison` | synthetic CSV example |' "$ROOT_DIR/docs/gallery/provenance.md"

echo "multi_line_comparison gallery test passed."
