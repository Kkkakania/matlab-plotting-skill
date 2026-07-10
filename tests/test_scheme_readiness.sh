#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_MD="$(mktemp)"
trap 'rm -f "$TMP_MD"' EXIT

python3 "$ROOT_DIR/scripts/build_scheme_readiness.py" --out "$TMP_MD"

grep -q "# Scheme Readiness" "$TMP_MD"
grep -q "| gallery-backed | 12 |" "$TMP_MD"
grep -q "| preview available | 2 |" "$TMP_MD"
grep -q "| render path started | 1 |" "$TMP_MD"
grep -q "## Stable First-Use Schemes" "$TMP_MD"
grep -q '`line_trend`, `multi_line_comparison`, `confidence_band`' "$TMP_MD"
grep -q 'Start with these before trying cataloged-only schemes.' "$TMP_MD"
grep -q '| `line_trend` | Trend | gallery-backed | \[preview\](gallery/line_trend.png) | yes | yes | yes | yes | yes | yes |' "$TMP_MD"
grep -q '| `density_scatter` | Relationship | gallery-backed | \[preview\](gallery/density_scatter.png) | yes | yes | yes | yes | yes | yes |' "$TMP_MD"
grep -q '| `contour_scatter` | Relationship | gallery-backed | \[preview\](gallery/contour_scatter.png) | yes | yes | yes | yes | yes | yes |' "$TMP_MD"
grep -q '| `regression_scatter` | Relationship | gallery-backed | \[preview\](gallery/regression_scatter.png) | yes | yes | yes | yes | yes | yes |' "$TMP_MD"
grep -q '| `stacked_time_series` | Trend | gallery-backed | \[preview\](gallery/stacked_time_series.png) | yes | yes | yes | yes | yes | yes |' "$TMP_MD"
grep -q '| `bubble_scatter` | Relationship | render path started | no | yes | yes | yes | yes | yes | no |' "$TMP_MD"

NESTED_DIR="$(mktemp -d)"
rm -rf "$NESTED_DIR"
python3 "$ROOT_DIR/scripts/build_scheme_readiness.py" --out "$NESTED_DIR/docs/scheme-readiness.md" >/dev/null
test -s "$NESTED_DIR/docs/scheme-readiness.md"
rm -rf "$NESTED_DIR"

echo "scheme readiness test passed."
