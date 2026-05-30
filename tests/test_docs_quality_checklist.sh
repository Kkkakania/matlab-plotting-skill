#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOC="$ROOT_DIR/docs/figure-quality-checklist.md"

if [[ ! -s "$DOC" ]]; then
  echo "missing figure quality checklist" >&2
  exit 1
fi

grep -q "Export" "$DOC"
grep -q "Color" "$DOC"
grep -q "MATLAB" "$DOC"
grep -q "Before Sharing" "$DOC"

echo "figure quality checklist test passed."
