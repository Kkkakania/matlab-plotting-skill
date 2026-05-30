#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PREVIEW="$ROOT_DIR/docs/gallery/zoomed_inset_line.png"
PROVENANCE="$ROOT_DIR/docs/gallery/provenance.md"
README="$ROOT_DIR/README.md"

if [[ ! -s "$PREVIEW" ]]; then
  echo "missing zoomed_inset_line gallery preview" >&2
  exit 1
fi

patterns=(
  '/Users/'
  '17 ak''un'
  'ak''un'
  'Author'':'
  'Copyright The Math''Works'
  'G''PL'
  '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}'
)

for pattern in "${patterns[@]}"; do
  if grep -E "$pattern" "$PROVENANCE" "$README"; then
    echo "zoomed_inset_line public docs contain private or provenance-unclear traces" >&2
    exit 1
  fi
done

grep -q '| `zoomed_inset_line.png` | `zoomed_inset_line` | synthetic demo data |' "$PROVENANCE"
grep -q 'docs/gallery/zoomed_inset_line.png' "$README"

echo "zoomed_inset_line safety test passed."
