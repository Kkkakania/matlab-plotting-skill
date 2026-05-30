#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

json_output="$("$ROOT_DIR/scripts/render_with_matlab.sh" --list-schemes-json)"

count="$(printf '%s\n' "$json_output" | python3 -c 'import json,sys; print(len(json.load(sys.stdin)))')"
if [[ "$count" -ne 50 ]]; then
  echo "expected 50 JSON scheme entries, found $count" >&2
  exit 1
fi

printf '%s\n' "$json_output" | python3 -c '
import json, sys
schemes = json.load(sys.stdin)
names = {item["scheme"] for item in schemes}
assert "line_trend" in names
assert "annotated_callout" in names
assert all({"scheme", "family", "best_for", "palette"} <= set(item) for item in schemes)
'

echo "scheme JSON list test passed."
