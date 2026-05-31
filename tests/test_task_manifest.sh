#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_JSON="$(mktemp)"
TMP_MD="$(mktemp)"

python3 "$ROOT_DIR/scripts/build_task_manifest.py" --json-out "$TMP_JSON" --markdown-out "$TMP_MD"

python3 - "$TMP_JSON" <<'PY'
import json
import sys
from collections import Counter
from pathlib import Path

manifest = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
tasks = manifest["tasks"]
ids = [task["id"] for task in tasks]
schemes = [task["scheme"] for task in tasks]
lanes = {task["lane"] for task in tasks}
per_scheme = Counter(schemes)
family_counts = manifest["family_counts"]
lane_counts = manifest["lane_counts"]

assert manifest["scheme_count"] == 50
assert manifest["lane_count"] == 10
assert manifest["task_count"] == 500
assert sum(family_counts.values()) == 500
assert sum(lane_counts.values()) == 500
assert lane_counts["catalog"] == 50
assert lane_counts["safety"] == 50
assert family_counts["Trend"] == 60
assert family_counts["Layout"] == 30
assert len(tasks) == 500
assert len(ids) == len(set(ids))
assert ids[0] == "TASK-001-line_trend-catalog"
assert ids[-1] == "TASK-500-annotated_callout-safety"
assert set(per_scheme.values()) == {10}
assert lanes == {
    "catalog",
    "data-contract",
    "demo-data",
    "selection-rule",
    "explicit-cli",
    "png-render",
    "vector-render",
    "report",
    "gallery",
    "safety",
}
assert all(task["acceptance"] for task in tasks)
assert all(task["command_hint"] for task in tasks)
assert all(task["status"] == "planned" for task in tasks)
PY

grep -q "TASK-001-line_trend-catalog" "$TMP_MD"
grep -q "TASK-500-annotated_callout-safety" "$TMP_MD"
grep -q "Long-Horizon Scheme Backlog" "$TMP_MD"
grep -q "planning backlog, not a release cadence" "$TMP_MD"
grep -q "Total tasks: 500" "$TMP_MD"
grep -q "| ID | Scheme | Lane | Goal | Acceptance | Command Hint | Status |" "$TMP_MD"
grep -q "Catalog entry names the scheme" "$TMP_MD"
grep -q "MATLAB_BIN=/path/to/matlab" "$TMP_MD"
grep -q "## Family Summary" "$TMP_MD"
grep -q "## Lane Summary" "$TMP_MD"
grep -q "| Trend | 60 |" "$TMP_MD"
grep -q "| catalog | 50 |" "$TMP_MD"

rm -f "$TMP_JSON" "$TMP_MD"

echo "task manifest test passed."
