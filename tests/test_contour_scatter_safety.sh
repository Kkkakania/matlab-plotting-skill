#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PREVIEW="$ROOT_DIR/docs/gallery/contour_scatter.png"
PROVENANCE="$ROOT_DIR/docs/gallery/provenance.md"
README="$ROOT_DIR/README.md"

if [[ ! -s "$PREVIEW" ]]; then
  echo "missing contour_scatter gallery preview" >&2
  exit 1
fi

patterns=(
  '/''Users/'
  '17 ak''un'
  'ak''un'
  'Author'':'
  'Copyright The Math''Works'
  'G''PL'
  '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}'
)

for pattern in "${patterns[@]}"; do
  if grep -E "$pattern" "$PROVENANCE" "$README"; then
    echo "contour_scatter public docs contain private or provenance-unclear traces" >&2
    exit 1
  fi
done

grep -q '| `contour_scatter.png` | `contour_scatter` | synthetic demo data |' "$PROVENANCE"
grep -q 'docs/gallery/contour_scatter.png' "$README"

echo "contour_scatter safety test passed."
