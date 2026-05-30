#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

grep -q '| `zoomed_inset_line` | Trend | Long trend with a local event | categorical |' \
  "$ROOT_DIR/skills/matlab-plotting-skill/references/scheme-catalog.md"

info_output="$("$ROOT_DIR/scripts/render_with_matlab.sh" --scheme-info zoomed_inset_line)"

if [[ "$info_output" != *"Scheme: zoomed_inset_line"* ]]; then
  echo "scheme info should include zoomed_inset_line" >&2
  exit 1
fi

if [[ "$info_output" != *"Family: Trend"* ]]; then
  echo "zoomed_inset_line should be in the Trend family" >&2
  exit 1
fi

if [[ "$info_output" != *"Best for: Long trend with a local event"* ]]; then
  echo "zoomed_inset_line should describe long trends with local events" >&2
  exit 1
fi

json_output="$("$ROOT_DIR/scripts/render_with_matlab.sh" --scheme-info-json zoomed_inset_line)"
printf '%s\n' "$json_output" | python3 -c '
import json, sys
item = json.load(sys.stdin)
assert item["scheme"] == "zoomed_inset_line"
assert item["family"] == "Trend"
assert item["best_for"] == "Long trend with a local event"
assert item["palette"] == "categorical"
'

echo "zoomed_inset_line catalog test passed."
