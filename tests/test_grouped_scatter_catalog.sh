#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

grep -q '| `grouped_scatter` | Relationship | Two variables with groups | categorical |' \
  "$ROOT_DIR/skills/matlab-plotting-skill/references/scheme-catalog.md"

info_output="$("$ROOT_DIR/scripts/render_with_matlab.sh" --scheme-info grouped_scatter)"

if [[ "$info_output" != *"Scheme: grouped_scatter"* ]]; then
  echo "scheme info should include grouped_scatter" >&2
  exit 1
fi

if [[ "$info_output" != *"Family: Relationship"* ]]; then
  echo "grouped_scatter should be in the Relationship family" >&2
  exit 1
fi

if [[ "$info_output" != *"Best for: Two variables with groups"* ]]; then
  echo "grouped_scatter should describe grouped x-y data" >&2
  exit 1
fi

json_output="$("$ROOT_DIR/scripts/render_with_matlab.sh" --scheme-info-json grouped_scatter)"

python3 - "$json_output" <<'PY'
import json
import sys

item = json.loads(sys.argv[1])
assert item["scheme"] == "grouped_scatter"
assert item["family"] == "Relationship"
assert item["best_for"] == "Two variables with groups"
assert item["palette"] == "categorical"
PY

echo "grouped_scatter catalog test passed."
