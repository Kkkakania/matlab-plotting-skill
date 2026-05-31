#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONTRACT="$ROOT_DIR/skills/matlab-plotting-skill/references/data-contract.md"
GUIDE="$ROOT_DIR/docs/chart-selection-guide.md"

grep -q '### `density_scatter`' "$CONTRACT"
grep -q 'hundreds of paired observations' "$CONTRACT"
grep -q 'at least two numeric columns' "$CONTRACT"
grep -q 'Dense overlapping points: `density_scatter`' "$GUIDE"
grep -q 'overlap hides individual points' "$GUIDE"

echo "density_scatter data contract test passed."
