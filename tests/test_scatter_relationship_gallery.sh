#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

GALLERY="$ROOT_DIR/docs/gallery"
CATALOG="$ROOT_DIR/skills/matlab-plotting-skill/references/scheme-catalog.md"
INDEX="$TMP_DIR/gallery-index.md"

if [[ ! -s "$GALLERY/scatter_relationship.png" ]]; then
  echo "missing committed scatter_relationship gallery preview" >&2
  exit 1
fi

python3 "$ROOT_DIR/scripts/build_gallery_index.py" \
  --dir "$GALLERY" \
  --catalog "$CATALOG" \
  --out "$INDEX" \
  --format png \
  --only-existing

grep -q '| `scatter_relationship` | Relationship | Two continuous variables | !\[scatter_relationship\](.*scatter_relationship.png) |' "$INDEX"
grep -q 'docs/gallery/scatter_relationship.png' "$ROOT_DIR/README.md"
grep -q '| `scatter_relationship.png` | `scatter_relationship` | synthetic demo data |' "$ROOT_DIR/docs/gallery/provenance.md"

echo "scatter_relationship gallery test passed."
