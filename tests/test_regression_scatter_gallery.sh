#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

GALLERY="$ROOT_DIR/docs/gallery"
CATALOG="$ROOT_DIR/skills/matlab-plotting-skill/references/scheme-catalog.md"
INDEX="$TMP_DIR/gallery-index.md"

if [[ ! -s "$GALLERY/regression_scatter.png" ]]; then
  echo "missing committed regression_scatter gallery preview" >&2
  exit 1
fi

python3 "$ROOT_DIR/scripts/build_gallery_index.py" \
  --dir "$GALLERY" \
  --catalog "$CATALOG" \
  --out "$INDEX" \
  --format png \
  --only-existing

grep -q '| `regression_scatter` | Relationship | Relationship plus trend line | !\[regression_scatter\](.*regression_scatter.png) |' "$INDEX"
grep -q 'docs/gallery/regression_scatter.png' "$ROOT_DIR/README.md"
grep -q '| `regression_scatter.png` | `regression_scatter` | synthetic demo data |' "$ROOT_DIR/docs/gallery/provenance.md"

echo "regression_scatter gallery test passed."
