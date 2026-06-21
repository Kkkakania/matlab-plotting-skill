#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PREVIEW="$ROOT_DIR/docs/gallery/stacked_time_series.png"
PROVENANCE="$ROOT_DIR/docs/gallery/provenance.md"
README="$ROOT_DIR/README.md"
README_ZH="$ROOT_DIR/README.zh-CN.md"

if [[ ! -s "$PREVIEW" ]]; then
  echo "missing stacked_time_series gallery preview" >&2
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
  if grep -E "$pattern" "$PROVENANCE" "$README" "$README_ZH"; then
    echo "stacked_time_series public docs contain private or provenance-unclear traces" >&2
    exit 1
  fi
done

grep -q '| `stacked_time_series.png` | `stacked_time_series` | synthetic demo data |' "$PROVENANCE"
grep -q 'docs/gallery/stacked_time_series.png' "$README"
grep -q 'docs/gallery/stacked_time_series.png' "$README_ZH"

echo "stacked_time_series safety test passed."
