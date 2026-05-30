#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONTRACT="$ROOT_DIR/skills/matlab-plotting-skill/references/data-contract.md"
GUIDE="$ROOT_DIR/docs/chart-selection-guide.md"

grep -q '### `scatter_relationship`' "$CONTRACT"
grep -q 'at least two numeric columns' "$CONTRACT"
grep -q 'paired observations' "$CONTRACT"
grep -q 'first two numeric' "$CONTRACT"
grep -q 'x-y relationship' "$CONTRACT"
grep -q 'already aggregated category summaries' "$CONTRACT"
grep -q '`grouped_bar`, `box_jitter`, or `grouped_scatter`' "$CONTRACT"
grep -q 'Simple x-y relation: `scatter_relationship`' "$GUIDE"
grep -q 'paired rows with at least two' "$GUIDE"
grep -q 'numeric measurement columns' "$GUIDE"

echo "scatter_relationship data contract test passed."
