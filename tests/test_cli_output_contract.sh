#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOC="$ROOT_DIR/docs/cli-output-contract.md"
PRIVATE_DOC="$ROOT_DIR/docs/private-data-handling.md"

grep -q "# CLI Output Contract" "$DOC"
grep -q -- "--list-schemes-json --status" "$DOC"
grep -q -- "--scheme-info-json <name> --status" "$DOC"
grep -q "schema_version" "$DOC"
grep -q "render_report.json" "$DOC"
grep -q "ScoreSnapshot" "$DOC"
grep -q "Unknown schemes fail with exit code" "$DOC"

status_info="$("$ROOT_DIR/scripts/render_with_matlab.sh" --scheme-info-json regression_scatter --status)"
printf '%s\n' "$status_info" | python3 -c '
import json, sys
item = json.load(sys.stdin)
assert item["schema_version"] == "1.0"
assert item["scheme"] == "regression_scatter"
assert item["readiness"] == "gallery-backed"
assert item["gallery"] == "preview"
'

grep -q "# Private Data Handling" "$PRIVATE_DOC"
grep -q "Safe To Share" "$PRIVATE_DOC"
grep -q "Do Not Share" "$PRIVATE_DOC"
grep -q "Raw research" "$PRIVATE_DOC"
grep -q "check_forbidden_files.sh" "$PRIVATE_DOC"

echo "CLI output contract and private data docs test passed."
