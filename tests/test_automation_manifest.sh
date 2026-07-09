#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_JSON="$(mktemp)"

python3 "$ROOT_DIR/scripts/build_automation_manifest.py" --out "$TMP_JSON"

python3 - "$TMP_JSON" <<'PY'
import json
import sys
from pathlib import Path

manifest = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
checks = manifest["checks"]
schemes = {item["scheme"] for item in checks}
ids = [item["id"] for item in checks]
families = {item["family"] for item in checks}
stages = {item["stage"] for item in checks}

assert manifest["scheme_count"] == 51
assert manifest["check_count"] >= 510
assert len(checks) == manifest["check_count"]
assert len(ids) == len(set(ids))
assert "line_trend" in schemes
assert "annotated_callout" in schemes
assert "stacked_time_series" in schemes
assert "Trend" in families
assert {"catalog", "selection", "render", "report", "safety"} <= stages
assert all(item["command_hint"] for item in checks)
PY

NESTED_DIR="$(mktemp -d)"
rm -rf "$NESTED_DIR"
python3 "$ROOT_DIR/scripts/build_automation_manifest.py" --out "$NESTED_DIR/out/automation.json"
test -s "$NESTED_DIR/out/automation.json"
rm -rf "$NESTED_DIR"

rm -f "$TMP_JSON"

echo "automation manifest test passed."
