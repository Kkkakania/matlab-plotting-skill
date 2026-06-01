#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONTRACT="$ROOT_DIR/skills/matlab-plotting-skill/references/data-contract.md"
GUIDE="$ROOT_DIR/docs/chart-selection-guide.md"

grep -q '### `regression_scatter`' "$CONTRACT"
grep -q 'two numeric columns' "$CONTRACT"
grep -q 'trend line is explanatory' "$CONTRACT"
grep -q 'Trend line needed: `regression_scatter`' "$GUIDE"

echo "regression_scatter data contract test passed."
