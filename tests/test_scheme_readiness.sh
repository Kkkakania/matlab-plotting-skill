#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_MD="$(mktemp)"
trap 'rm -f "$TMP_MD"' EXIT

python3 "$ROOT_DIR/scripts/build_scheme_readiness.py" --out "$TMP_MD"

grep -q "# Scheme Readiness" "$TMP_MD"
grep -q "| gallery-backed | 9 |" "$TMP_MD"
grep -q "| preview available | 2 |" "$TMP_MD"
grep -q "## Stable First-Use Schemes" "$TMP_MD"
grep -q '`line_trend`, `multi_line_comparison`, `confidence_band`' "$TMP_MD"
grep -q 'Start with these before trying cataloged-only schemes.' "$TMP_MD"
grep -q '| `line_trend` | Trend | gallery-backed | \[preview\](gallery/line_trend.png) | yes | yes | yes | yes | yes | yes |' "$TMP_MD"
grep -q '| `density_scatter` | Relationship | gallery-backed | \[preview\](gallery/density_scatter.png) | yes | yes | yes | yes | yes | yes |' "$TMP_MD"
grep -q '| `contour_scatter` | Relationship | cataloged | no | no | no | no | no | no | no |' "$TMP_MD"

echo "scheme readiness test passed."
