#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

grep -q '| `multi_line_comparison` | Trend | Several comparable series | categorical |' \
  "$ROOT_DIR/skills/matlab-plotting-skill/references/scheme-catalog.md"

info_output="$("$ROOT_DIR/scripts/render_with_matlab.sh" --scheme-info multi_line_comparison)"

if [[ "$info_output" != *"Scheme: multi_line_comparison"* ]]; then
  echo "scheme info should include multi_line_comparison" >&2
  exit 1
fi

if [[ "$info_output" != *"Family: Trend"* ]]; then
  echo "multi_line_comparison should be in the Trend family" >&2
  exit 1
fi

if [[ "$info_output" != *"Best for: Several comparable series"* ]]; then
  echo "multi_line_comparison should describe comparable series" >&2
  exit 1
fi

json_output="$("$ROOT_DIR/scripts/render_with_matlab.sh" --scheme-info-json multi_line_comparison)"
printf '%s\n' "$json_output" | python3 -c '
import json, sys
item = json.load(sys.stdin)
assert item["scheme"] == "multi_line_comparison"
assert item["family"] == "Trend"
assert item["best_for"] == "Several comparable series"
assert item["palette"] == "categorical"
'

echo "multi_line_comparison catalog test passed."
