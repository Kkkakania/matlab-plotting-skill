#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

grep -q '| `bubble_scatter` | Relationship | x-y plus magnitude | sequential |' \
  "$ROOT_DIR/skills/matlab-plotting-skill/references/scheme-catalog.md"

info_output="$("$ROOT_DIR/scripts/render_with_matlab.sh" --scheme-info bubble_scatter)"

if [[ "$info_output" != *"Scheme: bubble_scatter"* ]]; then
  echo "scheme info should include bubble_scatter" >&2
  exit 1
fi

if [[ "$info_output" != *"Family: Relationship"* ]]; then
  echo "bubble_scatter should be in the Relationship family" >&2
  exit 1
fi

if [[ "$info_output" != *"Best for: x-y plus magnitude"* ]]; then
  echo "bubble_scatter should describe x-y data plus magnitude" >&2
  exit 1
fi

json_output="$("$ROOT_DIR/scripts/render_with_matlab.sh" --scheme-info-json bubble_scatter)"

python3 - "$json_output" <<'PY'
import json
import sys

item = json.loads(sys.argv[1])
assert item["scheme"] == "bubble_scatter"
assert item["family"] == "Relationship"
assert item["best_for"] == "x-y plus magnitude"
assert item["palette"] == "sequential"
PY

echo "bubble_scatter catalog test passed."
