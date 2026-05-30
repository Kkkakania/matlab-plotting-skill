#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

grep -q '| `scatter_relationship` | Relationship | Two continuous variables | categorical |' \
  "$ROOT_DIR/skills/matlab-plotting-skill/references/scheme-catalog.md"

info_output="$("$ROOT_DIR/scripts/render_with_matlab.sh" --scheme-info scatter_relationship)"

if [[ "$info_output" != *"Scheme: scatter_relationship"* ]]; then
  echo "scheme info should include scatter_relationship" >&2
  exit 1
fi

if [[ "$info_output" != *"Family: Relationship"* ]]; then
  echo "scatter_relationship should be in the Relationship family" >&2
  exit 1
fi

if [[ "$info_output" != *"Best for: Two continuous variables"* ]]; then
  echo "scatter_relationship should describe two continuous variables" >&2
  exit 1
fi

json_output="$("$ROOT_DIR/scripts/render_with_matlab.sh" --scheme-info-json scatter_relationship)"
printf '%s\n' "$json_output" | python3 -c '
import json, sys
item = json.load(sys.stdin)
assert item["scheme"] == "scatter_relationship"
assert item["family"] == "Relationship"
assert item["best_for"] == "Two continuous variables"
assert item["palette"] == "categorical"
'

echo "scatter_relationship catalog test passed."
