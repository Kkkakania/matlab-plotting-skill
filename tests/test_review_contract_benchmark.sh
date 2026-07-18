#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUNNER="$ROOT_DIR/scripts/run_review_contract_benchmark.py"
MANIFEST="$ROOT_DIR/examples/review/multi_series_manifest.json"
REVIEW="$ROOT_DIR/examples/review/multi_series_review.json"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

python3 "$RUNNER" \
  --validator "$ROOT_DIR/scripts/validate_plot_review.py" \
  --manifest "$MANIFEST" \
  --review "$REVIEW" \
  --out "$TMP_DIR"

python3 - "$TMP_DIR/review_contract_benchmark.json" <<'PY'
import json
import sys
from pathlib import Path

report = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
assert report["schema_version"] == "1.0"
assert report["status"] == "passed"
assert report["summary"] == {
    "checks": 15,
    "passed": 15,
    "failed": 0,
    "fail_closed_checks": 14,
}
assert report["cases"][0]["id"] == "valid_control"
assert report["cases"][0]["expected"] == "accept"
assert all(case["passed"] for case in report["cases"])
assert all("/Users/" not in case["detail"] for case in report["cases"])
PY

grep -q "# Review Contract Adversarial Benchmark" \
  "$TMP_DIR/review_contract_benchmark.md"
grep -q "15/15 checks passed" "$TMP_DIR/review_contract_benchmark.md"
grep -q 'unknown_action' "$TMP_DIR/review_contract_benchmark.md"

echo "review contract benchmark test passed."
