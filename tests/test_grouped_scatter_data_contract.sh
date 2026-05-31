#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONTRACT="$ROOT_DIR/skills/matlab-plotting-skill/references/data-contract.md"
GUIDE="$ROOT_DIR/docs/chart-selection-guide.md"

grep -q '### `grouped_scatter`' "$CONTRACT"
grep -q 'at least two numeric columns' "$CONTRACT"
grep -q 'grouping column' "$CONTRACT"
grep -q 'Groups in x-y data: `grouped_scatter`' "$GUIDE"
grep -q 'x, y, group' "$GUIDE"

echo "grouped_scatter data contract test passed."
