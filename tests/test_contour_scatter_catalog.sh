#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

grep -q '| `contour_scatter` | Relationship | Dense local structure | sequential |' \
  "$ROOT_DIR/skills/matlab-plotting-skill/references/scheme-catalog.md"

info_output="$("$ROOT_DIR/scripts/render_with_matlab.sh" --scheme-info contour_scatter)"

if [[ "$info_output" != *"Scheme: contour_scatter"* ]]; then
  echo "scheme info should include contour_scatter" >&2
  exit 1
fi

if [[ "$info_output" != *"Family: Relationship"* ]]; then
  echo "contour_scatter should be in the Relationship family" >&2
  exit 1
fi

if [[ "$info_output" != *"Best for: Dense local structure"* ]]; then
  echo "contour_scatter should describe local density structure" >&2
  exit 1
fi

json_output="$("$ROOT_DIR/scripts/render_with_matlab.sh" --scheme-info-json contour_scatter)"

python3 - "$json_output" <<'PY'
import json
import sys

item = json.loads(sys.argv[1])
assert item["scheme"] == "contour_scatter"
assert item["family"] == "Relationship"
assert item["best_for"] == "Dense local structure"
assert item["palette"] == "sequential"
PY

echo "contour_scatter catalog test passed."
