#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONTRACT="$ROOT_DIR/skills/matlab-plotting-skill/references/data-contract.md"
GUIDE="$ROOT_DIR/docs/chart-selection-guide.md"

grep -q '### `segmented_line`' "$CONTRACT"
grep -q 'ordered x-axis column plus one or more numeric series' "$CONTRACT"
grep -q 'named phases, operating regimes, policy periods' "$CONTRACT"
grep -q 'experiment' "$CONTRACT"
grep -q 'stages' "$CONTRACT"
grep -q '`segment`, `phase`, `regime`, `stage`, or' "$CONTRACT"
grep -q '`period` column' "$CONTRACT"
grep -q 'no segment column exists' "$CONTRACT"
grep -q 'not imply unsupported regime changes' "$CONTRACT"
grep -q 'Phase or regime changes: `segmented_line`' "$GUIDE"
grep -q 'segment, phase,' "$GUIDE"
grep -q 'regime, stage, or period column' "$GUIDE"

echo "segmented_line data contract test passed."
