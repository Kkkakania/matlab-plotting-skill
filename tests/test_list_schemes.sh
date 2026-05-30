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

count="$(printf '%s\n' "$output" | grep -Ec '^[A-Za-z0-9_]+[[:space:]]')"
if [[ "$count" -ne 50 ]]; then
  echo "scheme list should include 50 schemes, found $count" >&2
  exit 1
fi

echo "scheme list test passed."
