#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONTRACT="$ROOT_DIR/skills/matlab-plotting-skill/references/data-contract.md"
GUIDE="$ROOT_DIR/docs/chart-selection-guide.md"

grep -q '### `positive_negative_area`' "$CONTRACT"
grep -q 'ordered x-axis column plus one signed numeric series' "$CONTRACT"
grep -q 'contains both' "$CONTRACT"
grep -q 'positive and negative values' "$CONTRACT"
grep -q 'good fit for residuals, deltas, net' "$CONTRACT"
grep -q 'change, or deviation from a baseline' "$CONTRACT"
grep -q 'Avoid this scheme for always-positive totals' "$CONTRACT"
grep -q 'Values above and below zero: `positive_negative_area`' "$GUIDE"
grep -q 'best when zero is a' "$GUIDE"
grep -q 'meaningful reference line' "$GUIDE"

echo "positive_negative_area data contract test passed."
