#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

output="$("$ROOT_DIR/scripts/render_with_matlab.sh" --list-schemes)"

if [[ "$output" != *"line_trend"* ]]; then
  echo "scheme list should include line_trend" >&2
  exit 1
fi

if [[ "$output" != *"annotated_callout"* ]]; then
  echo "scheme list should include annotated_callout" >&2
  exit 1
fi

if [[ "$output" != *"stacked_time_series"* ]]; then
  echo "scheme list should include stacked_time_series" >&2
  exit 1
fi

count="$(printf '%s\n' "$output" | grep -Ec '^[A-Za-z0-9_]+[[:space:]]')"
if [[ "$count" -ne 51 ]]; then
  echo "scheme list should include 51 schemes, found $count" >&2
  exit 1
fi

status_output="$("$ROOT_DIR/scripts/render_with_matlab.sh" --list-schemes --status)"

if [[ "$status_output" != *"gallery-backed"* ]]; then
  echo "scheme list with status should include readiness labels" >&2
  exit 1
fi

if [[ "$status_output" != *"cataloged"* ]]; then
  echo "scheme list with status should surface partially supported schemes" >&2
  exit 1
fi

if [[ "$status_output" != *"regression_scatter"* || "$status_output" != *"bubble_scatter"* ]]; then
  echo "scheme list with status should include relationship schemes" >&2
  exit 1
fi

echo "scheme list test passed."
