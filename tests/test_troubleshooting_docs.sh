#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOC="$ROOT_DIR/docs/troubleshooting.md"
SKILL_DOC="$ROOT_DIR/skills/matlab-plotting-skill/SKILL.md"

if [[ ! -s "$DOC" ]]; then
  echo "missing docs/troubleshooting.md" >&2
  exit 1
fi

grep -q "# Troubleshooting" "$DOC"
grep -q "MATLAB is not found" "$DOC"
grep -q "The command hangs" "$DOC"
grep -q "No figure files were written" "$DOC"
grep -q "The selected scheme feels wrong" "$DOC"
grep -q "MAT file has multiple variables" "$DOC"
grep -q "Do not paste private data" "$DOC"
grep -q "scripts/doctor.sh" "$DOC"
grep -q "collect_first_use_feedback.sh" "$DOC"
grep -q -- "--data-shape" "$DOC"
grep -q "docs/private-data-handling.md" "$DOC"

grep -q "docs/troubleshooting.md" "$ROOT_DIR/README.md"
grep -q "docs/troubleshooting.md" "$ROOT_DIR/README.zh-CN.md"
grep -q "docs/troubleshooting.md" "$SKILL_DOC"

echo "troubleshooting docs test passed."
