#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

grep -q '| `stacked_time_series` | Trend | Stacked synchronized signals | categorical |' \
  "$ROOT_DIR/skills/matlab-plotting-skill/references/scheme-catalog.md"

info_output="$("$ROOT_DIR/scripts/render_with_matlab.sh" --scheme-info stacked_time_series)"

if [[ "$info_output" != *"Scheme: stacked_time_series"* ]]; then
  echo "scheme info should include stacked_time_series" >&2
  exit 1
fi

if [[ "$info_output" != *"Family: Trend"* ]]; then
  echo "stacked_time_series should be in the Trend family" >&2
  exit 1
fi

if [[ "$info_output" != *"Best for: Stacked synchronized signals"* ]]; then
  echo "stacked_time_series should describe synchronized signals" >&2
  exit 1
fi

json_output="$("$ROOT_DIR/scripts/render_with_matlab.sh" --scheme-info-json stacked_time_series)"
printf '%s\n' "$json_output" | python3 -c '
import json, sys
item = json.load(sys.stdin)
assert item["scheme"] == "stacked_time_series"
assert item["family"] == "Trend"
assert item["best_for"] == "Stacked synchronized signals"
assert item["palette"] == "categorical"
'

echo "stacked_time_series catalog test passed."
