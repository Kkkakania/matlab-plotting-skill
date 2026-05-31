#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

grep -q '| `density_scatter` | Relationship | Dense x-y samples | sequential |' \
  "$ROOT_DIR/skills/matlab-plotting-skill/references/scheme-catalog.md"

info_output="$("$ROOT_DIR/scripts/render_with_matlab.sh" --scheme-info density_scatter)"

if [[ "$info_output" != *"Scheme: density_scatter"* ]]; then
  echo "scheme info should include density_scatter" >&2
  exit 1
fi

if [[ "$info_output" != *"Family: Relationship"* ]]; then
  echo "density_scatter should be in the Relationship family" >&2
  exit 1
fi

if [[ "$info_output" != *"Best for: Dense x-y samples"* ]]; then
  echo "density_scatter should describe dense x-y samples" >&2
  exit 1
fi

json_output="$("$ROOT_DIR/scripts/render_with_matlab.sh" --scheme-info-json density_scatter)"

python3 - "$json_output" <<'PY'
import json
import sys

item = json.loads(sys.argv[1])
assert item["scheme"] == "density_scatter"
assert item["family"] == "Relationship"
assert item["best_for"] == "Dense x-y samples"
assert item["palette"] == "sequential"
PY

echo "density_scatter catalog test passed."
