#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOC="$ROOT_DIR/docs/chart-selection-guide.md"

if [[ ! -s "$DOC" ]]; then
  echo "missing chart selection guide" >&2
  exit 1
fi

grep -q "Trend" "$DOC"
grep -q "Relationship" "$DOC"
grep -q "Matrix" "$DOC"
grep -q "Composition" "$DOC"
grep -q "When Not To Use" "$DOC"

echo "chart selection guide test passed."
