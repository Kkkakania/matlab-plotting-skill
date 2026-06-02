#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

info_output="$("$ROOT_DIR/scripts/render_with_matlab.sh" --scheme-info line_trend)"

if [[ "$info_output" != *"Scheme: line_trend"* ]]; then
  echo "scheme info should include the scheme name" >&2
  exit 1
fi

if [[ "$info_output" != *"Family: Trend"* ]]; then
  echo "scheme info should include the scheme family" >&2
  exit 1
fi

if [[ "$info_output" != *"Best for: One time or ordered series"* ]]; then
  echo "scheme info should include the intended use" >&2
  exit 1
fi

json_output="$("$ROOT_DIR/scripts/render_with_matlab.sh" --scheme-info-json line_trend)"
printf '%s\n' "$json_output" | python3 -c '
import json, sys
item = json.load(sys.stdin)
assert item["schema_version"] == "1.0"
assert item["scheme"] == "line_trend"
assert item["family"] == "Trend"
assert item["best_for"] == "One time or ordered series"
assert item["palette"] == "categorical"
'

if "$ROOT_DIR/scripts/render_with_matlab.sh" --scheme-info not_a_scheme >/tmp/mp-scheme-info.out 2>/tmp/mp-scheme-info.err; then
  echo "unknown scheme info request should fail" >&2
  exit 1
fi

if ! grep -q "Unknown scheme: not_a_scheme" /tmp/mp-scheme-info.err; then
  echo "unknown scheme failure should name the scheme" >&2
  exit 1
fi

echo "scheme info test passed."
