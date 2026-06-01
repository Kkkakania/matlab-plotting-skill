#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONTRACT="$ROOT_DIR/skills/matlab-plotting-skill/references/data-contract.md"
GUIDE="$ROOT_DIR/docs/chart-selection-guide.md"

grep -q '### `contour_scatter`' "$CONTRACT"
grep -q 'dense paired observations' "$CONTRACT"
grep -q 'local density contours' "$CONTRACT"
grep -q 'Dense overlapping points: `density_scatter` or `contour_scatter`' "$GUIDE"
grep -q 'contour lines are easier to read' "$GUIDE"

echo "contour_scatter data contract test passed."
