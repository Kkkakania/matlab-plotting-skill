#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

json_output="$("$ROOT_DIR/scripts/render_with_matlab.sh" --list-schemes-json)"

count="$(printf '%s\n' "$json_output" | python3 -c 'import json,sys; print(len(json.load(sys.stdin)))')"
if [[ "$count" -ne 51 ]]; then
  echo "expected 51 JSON scheme entries, found $count" >&2
  exit 1
fi

printf '%s\n' "$json_output" | python3 -c '
import json, sys
schemes = json.load(sys.stdin)
names = {item["scheme"] for item in schemes}
assert "line_trend" in names
assert "annotated_callout" in names
assert "stacked_time_series" in names
assert all({"schema_version", "scheme", "family", "best_for", "palette"} <= set(item) for item in schemes)
assert {item["schema_version"] for item in schemes} == {"1.0"}
'

status_json_output="$("$ROOT_DIR/scripts/render_with_matlab.sh" --list-schemes-json --status)"

printf '%s\n' "$status_json_output" | python3 -c '
import json, sys
schemes = json.load(sys.stdin)
by_name = {item["scheme"]: item for item in schemes}
assert by_name["regression_scatter"]["readiness"] == "gallery-backed"
assert by_name["regression_scatter"]["gallery"] == "preview"
assert by_name["bubble_scatter"]["readiness"] == "render path started"
assert by_name["bubble_scatter"]["gallery"] == "no"
assert all({"scheme", "family", "best_for", "palette", "readiness", "gallery"} <= set(item) for item in schemes)
'

echo "scheme JSON list test passed."
