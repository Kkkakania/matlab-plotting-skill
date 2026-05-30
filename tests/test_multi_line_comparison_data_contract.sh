#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONTRACT="$ROOT_DIR/skills/matlab-plotting-skill/references/data-contract.md"
GUIDE="$ROOT_DIR/docs/chart-selection-guide.md"

grep -q '### `multi_line_comparison`' "$CONTRACT"
grep -q 'wide table or numeric matrix with one ordered x-axis column' "$CONTRACT"
grep -q 'least two numeric series columns' "$CONTRACT"
grep -q 'time, method_a,' "$CONTRACT"
grep -q 'time, group, value' "$CONTRACT"
grep -q 'wide table with one' "$GUIDE"
grep -q 'least two numeric series columns' "$GUIDE"

echo "multi_line_comparison data contract test passed."
