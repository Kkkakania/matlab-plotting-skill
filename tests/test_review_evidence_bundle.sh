#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILDER="$ROOT_DIR/scripts/build_review_bundle.py"
VERIFIER="$ROOT_DIR/scripts/verify_review_bundle.py"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT
BUNDLE="$TMP_DIR/bundle"
mkdir -p "$BUNDLE/candidates" "$BUNDLE/final"

python3 - "$BUNDLE" <<'PY'
import base64
import json
import sys
from pathlib import Path

root = Path(sys.argv[1])
png = base64.b64decode(
    "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUB"
    "AScY42YAAAAASUVORK5CYII="
)
for relative in (
    "candidates/candidate-01__confidence_band.png",
    "candidates/candidate-02__multi_line_comparison.png",
    "final/multi_line_comparison.png",
    "before_after.png",
):
    (root / relative).write_bytes(png)

(root / "candidate_manifest.json").write_text(json.dumps({
    "schema_version": "1.0",
    "workflow": "codex-visual-review",
    "goal": "Compare <script>alert('x')</script> methods",
    "data_file": "synthetic.csv",
    "data_summary": {"rows": 4, "columns": 3},
    "candidates": [
        {
            "id": "candidate-01",
            "rank": 1,
            "scheme": "confidence_band",
            "selection_score": 11,
            "files": ["candidates/candidate-01__confidence_band.png"],
        },
        {
            "id": "candidate-02",
            "rank": 2,
            "scheme": "multi_line_comparison",
            "selection_score": 10,
            "files": ["candidates/candidate-02__multi_line_comparison.png"],
        },
    ],
}), encoding="utf-8")

(root / "validated_review.json").write_text(json.dumps({
    "schema_version": "1.0",
    "validation": {"status": "validated"},
}), encoding="utf-8")

(root / "review_evidence.json").write_text(json.dumps({
    "schema_version": "1.0",
    "workflow": "generate-review-repair-evidence",
    "goal": "Compare <script>alert('x')</script> methods",
    "data_file": "synthetic.csv",
    "selected_candidate": "candidate-02",
    "selected_scheme": "multi_line_comparison",
    "verdict": "repair",
    "reviewer": {"surface": "codex", "model": "gpt-5.6-sol"},
    "summary": "Use the honest comparison & repair the labels.",
    "scores": {
        "claim_support": 5,
        "legibility": 4,
        "accessibility": 4,
        "honesty": 5,
        "reproducibility": 5,
    },
    "findings": [{
        "code": "semantic_mismatch",
        "severity": "high",
        "evidence": "The columns are two methods, not uncertainty bounds.",
        "recommendation": "Use an explicit multi-line comparison.",
    }],
    "applied_actions": ["increase_font_size", "high_contrast_palette"],
    "before_file": "candidates/candidate-02__multi_line_comparison.png",
    "after_files": ["final/multi_line_comparison.png"],
    "comparison_file": "before_after.png",
}), encoding="utf-8")
PY

python3 "$BUILDER" \
  --evidence "$BUNDLE/review_evidence.json" \
  --candidate-manifest "$BUNDLE/candidate_manifest.json" \
  --out "$BUNDLE/review_report.html" \
  --manifest-out "$BUNDLE/review_bundle_manifest.json"

python3 "$VERIFIER" \
  --manifest "$BUNDLE/review_bundle_manifest.json" \
  --root "$BUNDLE"

python3 - "$BUNDLE" "$TMP_DIR" <<'PY'
import json
import sys
from pathlib import Path

root = Path(sys.argv[1])
private_root = Path(sys.argv[2])
html = (root / "review_report.html").read_text(encoding="utf-8")
manifest = json.loads((root / "review_bundle_manifest.json").read_text(encoding="utf-8"))

assert "data:image/png;base64," in html
assert "default-src 'none'; img-src data:; style-src 'unsafe-inline'" in html
assert "<script>alert('x')</script>" not in html
assert "&lt;script&gt;alert(&#x27;x&#x27;)&lt;/script&gt;" in html
assert str(private_root) not in html
assert "file://" not in html
assert "candidate-01" in html and "candidate-02" in html
assert "Integrity verified" in html
assert manifest["schema_version"] == "1.0"
assert manifest["algorithm"] == "sha256"
assert manifest["status"] == "complete"
assert manifest["report_file"] == "review_report.html"
assert len(manifest["artifacts"]) == 7
assert all(len(item["sha256"]) == 64 for item in manifest["artifacts"])
assert all(not item["path"].startswith("/") for item in manifest["artifacts"])
assert [item["path"] for item in manifest["artifacts"]] == sorted(
    item["path"] for item in manifest["artifacts"]
)
PY

cp "$BUNDLE/before_after.png" "$TMP_DIR/before_after.original.png"
python3 - "$BUNDLE/before_after.png" <<'PY'
import sys
from pathlib import Path

path = Path(sys.argv[1])
content = bytearray(path.read_bytes())
content[-1] ^= 1
path.write_bytes(content)
PY
set +e
python3 "$VERIFIER" \
  --manifest "$BUNDLE/review_bundle_manifest.json" \
  --root "$BUNDLE" >"$TMP_DIR/tamper.out" 2>"$TMP_DIR/tamper.err"
tamper_status=$?
set -e
if [[ "$tamper_status" -eq 0 ]]; then
  echo "tampered evidence should fail verification" >&2
  exit 1
fi
grep -q "SHA-256 mismatch: before_after.png" "$TMP_DIR/tamper.err"
cp "$TMP_DIR/before_after.original.png" "$BUNDLE/before_after.png"

python3 - "$BUNDLE/review_evidence.json" <<'PY'
import json
import sys
from pathlib import Path

path = Path(sys.argv[1])
evidence = json.loads(path.read_text(encoding="utf-8"))
evidence["comparison_file"] = "../outside.png"
path.write_text(json.dumps(evidence), encoding="utf-8")
PY

set +e
python3 "$BUILDER" \
  --evidence "$BUNDLE/review_evidence.json" \
  --candidate-manifest "$BUNDLE/candidate_manifest.json" \
  --out "$BUNDLE/rejected.html" \
  --manifest-out "$BUNDLE/rejected.json" >"$TMP_DIR/traversal.out" 2>"$TMP_DIR/traversal.err"
traversal_status=$?
set -e
if [[ "$traversal_status" -eq 0 ]]; then
  echo "path traversal should fail bundle generation" >&2
  exit 1
fi
grep -q "unsafe artifact path" "$TMP_DIR/traversal.err"

python3 - "$BUNDLE/review_evidence.json" <<'PY'
import json
import sys
from pathlib import Path

path = Path(sys.argv[1])
evidence = json.loads(path.read_text(encoding="utf-8"))
evidence["comparison_file"] = "before_after.png"
path.write_text(json.dumps(evidence), encoding="utf-8")
PY
mv "$BUNDLE/validated_review.json" "$TMP_DIR/validated_review.json"
ln -s "$TMP_DIR/validated_review.json" "$BUNDLE/validated_review.json"

set +e
python3 "$BUILDER" \
  --evidence "$BUNDLE/review_evidence.json" \
  --candidate-manifest "$BUNDLE/candidate_manifest.json" \
  --out "$BUNDLE/rejected-symlink.html" \
  --manifest-out "$BUNDLE/rejected-symlink.json" >"$TMP_DIR/symlink.out" 2>"$TMP_DIR/symlink.err"
symlink_status=$?
set -e
if [[ "$symlink_status" -eq 0 ]]; then
  echo "evidence symlink outside the bundle should fail generation" >&2
  exit 1
fi
grep -q "unsafe artifact path" "$TMP_DIR/symlink.err"

echo "review evidence bundle test passed."
