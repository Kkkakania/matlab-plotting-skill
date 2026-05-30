#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONTRACT="$ROOT_DIR/skills/matlab-plotting-skill/references/data-contract.md"
GUIDE="$ROOT_DIR/docs/chart-selection-guide.md"

grep -q '### `confidence_band`' "$CONTRACT"
grep -q 'ordered x-axis column plus a central numeric series' "$CONTRACT"
grep -q '`x, center, lower, upper`' "$CONTRACT"
grep -q 'single center series is' "$CONTRACT"
grep -q 'Mean with uncertainty: `confidence_band`' "$GUIDE"
grep -q 'optional lower/upper columns' "$GUIDE"

echo "confidence_band data contract test passed."
