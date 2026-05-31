#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PREVIEW="$ROOT_DIR/docs/gallery/scatter_relationship.png"
PROVENANCE="$ROOT_DIR/docs/gallery/provenance.md"
README="$ROOT_DIR/README.md"

if [[ ! -s "$PREVIEW" ]]; then
  echo "missing scatter_relationship gallery preview" >&2
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
    echo "scatter_relationship public docs contain private or provenance-unclear traces" >&2
    exit 1
  fi
done

grep -q '| `scatter_relationship.png` | `scatter_relationship` | synthetic demo data |' "$PROVENANCE"
grep -q 'docs/gallery/scatter_relationship.png' "$README"

echo "scatter_relationship safety test passed."
