#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONTRACT="$ROOT_DIR/skills/matlab-plotting-skill/references/data-contract.md"
GUIDE="$ROOT_DIR/docs/chart-selection-guide.md"

grep -q '### `zoomed_inset_line`' "$CONTRACT"
grep -q 'long ordered x-axis' "$CONTRACT"
grep -q 'local event,' "$CONTRACT"
grep -q 'transition, anomaly, or detail window' "$CONTRACT"
grep -q 'two-column table such as `time, signal`' "$CONTRACT"
grep -q 'one x-axis column plus several numeric series columns' "$CONTRACT"
grep -q 'Local event inside a long series: `zoomed_inset_line`' "$GUIDE"
grep -q 'zoomed inset works' "$GUIDE"
grep -q 'best when the full trend matters and one interval needs closer inspection' "$GUIDE"

echo "zoomed_inset_line data contract test passed."
