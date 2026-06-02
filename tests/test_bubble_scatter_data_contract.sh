#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONTRACT="$ROOT_DIR/skills/matlab-plotting-skill/references/data-contract.md"
GUIDE="$ROOT_DIR/docs/chart-selection-guide.md"

grep -q '### `bubble_scatter`' "$CONTRACT"
grep -q 'x, y, magnitude' "$CONTRACT"
grep -q 'third numeric column' "$CONTRACT"
grep -q 'Third magnitude variable: `bubble_scatter`' "$GUIDE"
grep -q 'at least three numeric columns' "$GUIDE"

echo "bubble_scatter data contract test passed."
