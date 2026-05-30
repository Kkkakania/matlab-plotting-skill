#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

grep -q '| `positive_negative_area` | Trend | Signed change around zero | diverging |' \
  "$ROOT_DIR/skills/matlab-plotting-skill/references/scheme-catalog.md"

info_output="$("$ROOT_DIR/scripts/render_with_matlab.sh" --scheme-info positive_negative_area)"

if [[ "$info_output" != *"Scheme: positive_negative_area"* ]]; then
  echo "scheme info should include positive_negative_area" >&2
  exit 1
fi

if [[ "$info_output" != *"Family: Trend"* ]]; then
  echo "positive_negative_area should be in the Trend family" >&2
  exit 1
fi

if [[ "$info_output" != *"Best for: Signed change around zero"* ]]; then
  echo "positive_negative_area should describe signed change around zero" >&2
  exit 1
fi

json_output="$("$ROOT_DIR/scripts/render_with_matlab.sh" --scheme-info-json positive_negative_area)"
printf '%s\n' "$json_output" | python3 -c '
import json, sys
item = json.load(sys.stdin)
assert item["scheme"] == "positive_negative_area"
assert item["family"] == "Trend"
assert item["best_for"] == "Signed change around zero"
assert item["palette"] == "diverging"
'

echo "positive_negative_area catalog test passed."
