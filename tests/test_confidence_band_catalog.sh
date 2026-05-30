#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

grep -q '| `confidence_band` | Trend | Mean plus uncertainty | categorical |' \
  "$ROOT_DIR/skills/matlab-plotting-skill/references/scheme-catalog.md"

info_output="$("$ROOT_DIR/scripts/render_with_matlab.sh" --scheme-info confidence_band)"

if [[ "$info_output" != *"Scheme: confidence_band"* ]]; then
  echo "scheme info should include confidence_band" >&2
  exit 1
fi

if [[ "$info_output" != *"Family: Trend"* ]]; then
  echo "confidence_band should be in the Trend family" >&2
  exit 1
fi

if [[ "$info_output" != *"Best for: Mean plus uncertainty"* ]]; then
  echo "confidence_band should describe mean plus uncertainty" >&2
  exit 1
fi

json_output="$("$ROOT_DIR/scripts/render_with_matlab.sh" --scheme-info-json confidence_band)"
printf '%s\n' "$json_output" | python3 -c '
import json, sys
item = json.load(sys.stdin)
assert item["scheme"] == "confidence_band"
assert item["family"] == "Trend"
assert item["best_for"] == "Mean plus uncertainty"
assert item["palette"] == "categorical"
'

echo "confidence_band catalog test passed."
