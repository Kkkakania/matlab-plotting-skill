#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RENDERER="$ROOT_DIR/scripts/render_with_matlab.sh"
BUNDLE_BUILDER="$ROOT_DIR/scripts/build_review_bundle.py"
BUNDLE_VERIFIER="$ROOT_DIR/scripts/verify_review_bundle.py"
DATA="$ROOT_DIR/examples/data/multi_series.csv"
REVIEW="$ROOT_DIR/examples/review/multi_series_review.json"
GOAL="Compare the baseline and candidate methods over time and make uncertainty or overlap easy to inspect without inventing error bounds"
OUT_DIR=""

usage() {
  cat <<'USAGE'
Usage:
  run_review_demo.sh --out <directory>

Runs the deterministic Build Week demo with bundled synthetic data and a
checked GPT-5.6 review fixture. Set MATLAB_BIN when MATLAB is not on PATH.
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --out)
      if [[ $# -lt 2 || -z "${2:-}" || "$2" == --* ]]; then
        echo "--out requires a value." >&2
        exit 2
      fi
      OUT_DIR="$2"
      shift 2
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ -z "$OUT_DIR" ]]; then
  echo "--out <directory> is required." >&2
  exit 2
fi

"$RENDERER" --candidate-pack --candidate-count 3 \
  --data "$DATA" --goal "$GOAL" --out "$OUT_DIR" --formats png,svg

"$RENDERER" --finalize-review "$REVIEW" \
  --candidate-manifest "$OUT_DIR/candidate_manifest.json" \
  --data "$DATA" --goal "$GOAL" --out "$OUT_DIR" --formats png,svg

python3 "$BUNDLE_BUILDER" \
  --evidence "$OUT_DIR/review_evidence.json" \
  --candidate-manifest "$OUT_DIR/candidate_manifest.json" \
  --out "$OUT_DIR/review_report.html" \
  --manifest-out "$OUT_DIR/review_bundle_manifest.json"

python3 "$BUNDLE_VERIFIER" \
  --manifest "$OUT_DIR/review_bundle_manifest.json" \
  --root "$OUT_DIR"

printf 'Demo complete:\n'
printf '  comparison: %s\n' "$OUT_DIR/before_after.png"
printf '  evidence:   %s\n' "$OUT_DIR/review_evidence.md"
printf '  report:     %s\n' "$OUT_DIR/review_report.html"
printf '  integrity:  %s\n' "$OUT_DIR/review_bundle_manifest.json"
