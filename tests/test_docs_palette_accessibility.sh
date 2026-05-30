#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOC="$ROOT_DIR/docs/palette-accessibility-notes.md"

if [[ ! -s "$DOC" ]]; then
  echo "missing palette accessibility notes" >&2
  exit 1
fi

grep -q "Categorical" "$DOC"
grep -q "Sequential" "$DOC"
grep -q "Diverging" "$DOC"
grep -q "grayscale" "$DOC"
grep -q "colorblind" "$DOC"

echo "palette accessibility notes test passed."
