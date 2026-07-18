#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VALIDATOR="$ROOT_DIR/scripts/validate_plot_review.py"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

cat >"$TMP_DIR/manifest.json" <<'JSON'
{
  "schema_version": "1.0",
  "candidates": [
    {"id": "candidate-01", "scheme": "line_trend"},
    {"id": "candidate-02", "scheme": "multi_line_comparison"}
  ]
}
JSON

cat >"$TMP_DIR/review.json" <<'JSON'
{
  "schema_version": "1.0",
  "selected_candidate": "candidate-02",
  "verdict": "repair",
  "reviewer": {"surface": "codex", "model": "gpt-5.6-terra"},
  "summary": "Candidate 02 communicates the comparison most clearly after a small legibility repair.",
  "scores": {
    "claim_support": 5,
    "legibility": 3,
    "accessibility": 4,
    "honesty": 5,
    "reproducibility": 5
  },
  "findings": [
    {
      "code": "small_text",
      "severity": "medium",
      "evidence": "Axis labels are difficult to read at demo-video size.",
      "recommendation": "Increase the minimum font size."
    }
  ],
  "repair_actions": [
    {"action": "increase_font_size", "value": 12},
    {"action": "enable_grid"},
    {"action": "legend_best"}
  ]
}
JSON

python3 "$VALIDATOR" \
  --review "$TMP_DIR/review.json" \
  --manifest "$TMP_DIR/manifest.json" \
  --out "$TMP_DIR/normalized.json"

python3 - "$TMP_DIR/normalized.json" <<'PY'
import json
import sys
from pathlib import Path

review = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
assert review["selected_candidate"] == "candidate-02"
assert review["reviewer"] == {"surface": "codex", "model": "gpt-5.6-terra"}
assert review["repair_actions"][0] == {"action": "increase_font_size", "value": 12}
assert review["repair_actions"][1] == {"action": "enable_grid"}
assert review["validation"]["status"] == "validated"
assert review["validation"]["allowed_actions"] == [
    "enable_grid",
    "enforce_zero_baseline",
    "high_contrast_palette",
    "increase_font_size",
    "legend_best",
]
PY

python3 - "$TMP_DIR/review.json" "$TMP_DIR/unknown-action.json" <<'PY'
import json
import sys
from pathlib import Path

review = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
review["repair_actions"] = [{"action": "run_matlab_code", "value": "delete('*')"}]
Path(sys.argv[2]).write_text(json.dumps(review), encoding="utf-8")
PY

set +e
python3 "$VALIDATOR" --review "$TMP_DIR/unknown-action.json" --manifest "$TMP_DIR/manifest.json" \
  >"$TMP_DIR/unknown-action.out" 2>"$TMP_DIR/unknown-action.err"
status=$?
set -e
if [[ "$status" -ne 2 ]]; then
  echo "unknown repair actions must be rejected with exit 2" >&2
  exit 1
fi
grep -q "unsupported repair action" "$TMP_DIR/unknown-action.err"

python3 - "$TMP_DIR/review.json" "$TMP_DIR/bad-candidate.json" <<'PY'
import json
import sys
from pathlib import Path

review = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
review["selected_candidate"] = "candidate-99"
Path(sys.argv[2]).write_text(json.dumps(review), encoding="utf-8")
PY

set +e
python3 "$VALIDATOR" --review "$TMP_DIR/bad-candidate.json" --manifest "$TMP_DIR/manifest.json" \
  >"$TMP_DIR/bad-candidate.out" 2>"$TMP_DIR/bad-candidate.err"
status=$?
set -e
if [[ "$status" -ne 2 ]]; then
  echo "reviews must select a candidate from the manifest" >&2
  exit 1
fi
grep -q "selected_candidate is not present" "$TMP_DIR/bad-candidate.err"

echo "plot review validator test passed."
