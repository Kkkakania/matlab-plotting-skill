#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

OUT_DIR="$TMP_DIR/render-output"
DOCTOR_DIR="$TMP_DIR/doctor-output"
mkdir -p "$OUT_DIR"
mkdir -p "$DOCTOR_DIR"

help_output="$("$ROOT_DIR/scripts/collect_first_use_feedback.sh" --help)"
grep -q -- "--doctor <dir>" <<<"$help_output"

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

cat >"$DOCTOR_DIR/first_use_doctor.json" <<'JSON'
{
  "schema_version": "1.0",
  "mode": "metadata-only",
  "overall_status": "warn",
  "checks": [
    {
      "name": "scheme catalog count",
      "status": "pass",
      "detail": "50 schemes listed"
    },
    {
      "name": "data extension",
      "status": "warn",
      "detail": ".txt is not supported by the renderer"
    }
  ]
}
JSON

feedback="$("$ROOT_DIR/scripts/collect_first_use_feedback.sh" \
  --out "$OUT_DIR" \
  --doctor "$DOCTOR_DIR" \
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
grep -q "first_use_doctor.md/json summary" <<<"$feedback"
grep -q "Overall status: warn" <<<"$feedback"
grep -q "Mode: metadata-only" <<<"$feedback"
grep -q "data extension: warn - .txt is not supported by the renderer" <<<"$feedback"
grep -q "<redacted-path>" <<<"$feedback"

if grep -q "/Users/example" <<<"$feedback"; then
  echo "feedback draft leaked a local absolute path" >&2
  echo "$feedback" >&2
  exit 1
fi

missing_doctor_status=0
"$ROOT_DIR/scripts/collect_first_use_feedback.sh" --out "$OUT_DIR" --doctor "$TMP_DIR/missing-doctor" >/dev/null 2>"$TMP_DIR/missing-doctor.err" || missing_doctor_status=$?
if [[ "$missing_doctor_status" -ne 2 ]]; then
  echo "expected missing doctor output directory to exit 2, got $missing_doctor_status" >&2
  cat "$TMP_DIR/missing-doctor.err" >&2
  exit 1
fi
grep -q "Doctor output directory not found" "$TMP_DIR/missing-doctor.err"

missing_status=0
"$ROOT_DIR/scripts/collect_first_use_feedback.sh" --out "$TMP_DIR/missing" >/dev/null 2>"$TMP_DIR/missing.err" || missing_status=$?
if [[ "$missing_status" -ne 2 ]]; then
  echo "expected missing output directory to exit 2, got $missing_status" >&2
  cat "$TMP_DIR/missing.err" >&2
  exit 1
fi

echo "first-use feedback collector test passed."
