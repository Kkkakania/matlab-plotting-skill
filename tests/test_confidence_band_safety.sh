#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DATA="$ROOT_DIR/examples/data/confidence_band.csv"
PREVIEW="$ROOT_DIR/docs/gallery/confidence_band.png"
PROVENANCE="$ROOT_DIR/docs/gallery/provenance.md"

if [[ ! -s "$DATA" ]]; then
  echo "missing confidence_band synthetic CSV" >&2
  exit 1
fi

if [[ ! -s "$PREVIEW" ]]; then
  echo "missing confidence_band gallery preview" >&2
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
  if grep -E "$pattern" "$DATA" "$PROVENANCE"; then
    echo "confidence_band public assets contain private or provenance-unclear traces" >&2
    exit 1
  fi
done

grep -q '| `confidence_band.png` | `confidence_band` | synthetic CSV example |' "$PROVENANCE"

echo "confidence_band safety test passed."
