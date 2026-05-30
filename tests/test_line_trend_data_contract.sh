#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CATALOG="$ROOT_DIR/skills/matlab-plotting-skill/references/scheme-catalog.md"
GUIDE="$ROOT_DIR/docs/chart-selection-guide.md"

grep -q '| `line_trend` | Trend | One time or ordered series | categorical |' "$CATALOG"
grep -q 'One ordered numeric series: `line_trend`' "$GUIDE"

echo "line_trend data contract test passed."
