#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

grep -q '| `regression_scatter` | Relationship | Relationship plus trend line | categorical |' \
  "$ROOT_DIR/skills/matlab-plotting-skill/references/scheme-catalog.md"

info_output="$("$ROOT_DIR/scripts/render_with_matlab.sh" --scheme-info regression_scatter)"

if [[ "$info_output" != *"Scheme: regression_scatter"* ]]; then
  echo "scheme info should include regression_scatter" >&2
  exit 1
fi

if [[ "$info_output" != *"Family: Relationship"* ]]; then
  echo "regression_scatter should be in the Relationship family" >&2
  exit 1
fi

if [[ "$info_output" != *"Best for: Relationship plus trend line"* ]]; then
  echo "regression_scatter should describe a relationship plus trend line" >&2
  exit 1
fi

json_output="$("$ROOT_DIR/scripts/render_with_matlab.sh" --scheme-info-json regression_scatter)"

python3 - "$json_output" <<'PY'
import json
import sys

item = json.loads(sys.argv[1])
assert item["scheme"] == "regression_scatter"
assert item["family"] == "Relationship"
assert item["best_for"] == "Relationship plus trend line"
assert item["palette"] == "categorical"
PY

echo "regression_scatter catalog test passed."
