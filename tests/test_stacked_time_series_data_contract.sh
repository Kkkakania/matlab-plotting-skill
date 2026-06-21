#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONTRACT="$ROOT_DIR/skills/matlab-plotting-skill/references/data-contract.md"
GUIDE="$ROOT_DIR/docs/chart-selection-guide.md"

grep -q '### `stacked_time_series`' "$CONTRACT"
grep -q 'one ordered x-axis column plus at least three related numeric signal columns' "$CONTRACT"
grep -q '`time, voltage, current, power`' "$CONTRACT"
grep -q 'shared x-axis' "$CONTRACT"
grep -q 'separate y-axes' "$CONTRACT"
grep -q 'Use `multi_line_comparison`' "$CONTRACT"
grep -q 'Synchronized channels on one time axis: `stacked_time_series`' "$GUIDE"
grep -q 'voltage/current/power' "$GUIDE"
grep -q 'separate y-scales' "$GUIDE"

echo "stacked_time_series data contract test passed."
