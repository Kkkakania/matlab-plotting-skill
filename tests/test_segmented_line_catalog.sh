#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

grep -q '| `segmented_line` | Trend | Phase or regime changes | categorical |' \
  "$ROOT_DIR/skills/matlab-plotting-skill/references/scheme-catalog.md"

info_output="$("$ROOT_DIR/scripts/render_with_matlab.sh" --scheme-info segmented_line)"

if [[ "$info_output" != *"Scheme: segmented_line"* ]]; then
  echo "scheme info should include segmented_line" >&2
  exit 1
fi

if [[ "$info_output" != *"Family: Trend"* ]]; then
  echo "segmented_line should be in the Trend family" >&2
  exit 1
fi

if [[ "$info_output" != *"Best for: Phase or regime changes"* ]]; then
  echo "segmented_line should describe phase or regime changes" >&2
  exit 1
fi

json_output="$("$ROOT_DIR/scripts/render_with_matlab.sh" --scheme-info-json segmented_line)"
printf '%s\n' "$json_output" | python3 -c '
import json, sys
item = json.load(sys.stdin)
assert item["scheme"] == "segmented_line"
assert item["family"] == "Trend"
assert item["best_for"] == "Phase or regime changes"
assert item["palette"] == "categorical"
'

echo "segmented_line catalog test passed."
