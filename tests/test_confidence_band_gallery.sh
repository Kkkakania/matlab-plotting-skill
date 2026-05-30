#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

GALLERY="$ROOT_DIR/docs/gallery"
CATALOG="$ROOT_DIR/skills/matlab-plotting-skill/references/scheme-catalog.md"
INDEX="$TMP_DIR/gallery-index.md"

if [[ ! -s "$GALLERY/confidence_band.png" ]]; then
  echo "missing committed confidence_band gallery preview" >&2
  exit 1
fi

python3 "$ROOT_DIR/scripts/build_gallery_index.py" \
  --dir "$GALLERY" \
  --catalog "$CATALOG" \
  --out "$INDEX" \
  --format png \
  --only-existing

grep -q '| `confidence_band` | Trend | Mean plus uncertainty | !\[confidence_band\](.*confidence_band.png) |' "$INDEX"
grep -q 'docs/gallery/confidence_band.png' "$ROOT_DIR/README.md"
grep -q '| `confidence_band.png` | `confidence_band` | synthetic CSV example |' "$ROOT_DIR/docs/gallery/provenance.md"

echo "confidence_band gallery test passed."
