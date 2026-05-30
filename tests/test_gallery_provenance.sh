#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GALLERY="$ROOT_DIR/docs/gallery"
PROVENANCE="$GALLERY/provenance.md"

if [[ ! -s "$PROVENANCE" ]]; then
  echo "missing gallery provenance file" >&2
  exit 1
fi

while IFS= read -r asset; do
  if ! grep -q "| \`$asset\` |" "$PROVENANCE"; then
    echo "gallery asset missing provenance row: $asset" >&2
    exit 1
  fi
done < <(find "$GALLERY" -maxdepth 1 -type f -name '*.png' -exec basename {} \; | sort)

grep -q '| `line_trend.png` | `line_trend` | synthetic demo data |' "$PROVENANCE"
grep -q 'not screenshots of papers' "$PROVENANCE"

echo "gallery provenance test passed."
