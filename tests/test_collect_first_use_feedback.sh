#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

OUT_DIR="$TMP_DIR/render-output"
mkdir -p "$OUT_DIR"

cat >"$OUT_DIR/render_report.md" <<'REPORT'
# Render Report

- Selected scheme: line_trend
- Top alternatives: multi_line_comparison, confidence_band
- Output formats: png, svg
- Warning: source path /Users/example/private/project/data.csv was redacted
REPORT

cat >"$OUT_DIR/render_report.json" <<'JSON'
{
  "selectedScheme": "line_trend",
  "outputFormats": ["png", "svg"],
  "selectionExplanation": {
    "topAlternatives": ["multi_line_comparison", "confidence_band"]
  }
}
JSON

feedback="$("$ROOT_DIR/scripts/collect_first_use_feedback.sh" \
  --out "$OUT_DIR" \
  --command './scripts/render_with_matlab.sh --data /Users/example/private/project/data.csv --goal "show a trend"' \
  --matlab R2025a \
  --os "macOS" \
  --commit abc1234 \
  --goal "show a trend")"

grep -q "First-use feedback draft" <<<"$feedback"
grep -q "MATLAB: R2025a" <<<"$feedback"
grep -q "Commit: abc1234" <<<"$feedback"
grep -q "Selected scheme: line_trend" <<<"$feedback"
grep -q "Top alternatives: multi_line_comparison, confidence_band" <<<"$feedback"
grep -q "Output formats: png, svg" <<<"$feedback"
grep -q "<redacted-path>" <<<"$feedback"

if grep -q "/Users/example" <<<"$feedback"; then
  echo "feedback draft leaked a local absolute path" >&2
  echo "$feedback" >&2
  exit 1
fi

missing_status=0
"$ROOT_DIR/scripts/collect_first_use_feedback.sh" --out "$TMP_DIR/missing" >/dev/null 2>"$TMP_DIR/missing.err" || missing_status=$?
if [[ "$missing_status" -ne 2 ]]; then
  echo "expected missing output directory to exit 2, got $missing_status" >&2
  cat "$TMP_DIR/missing.err" >&2
  exit 1
fi

echo "first-use feedback collector test passed."
