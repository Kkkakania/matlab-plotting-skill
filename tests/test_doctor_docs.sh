#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOC="$ROOT_DIR/docs/first-use-doctor.md"
WORKFLOW="$ROOT_DIR/.github/workflows/quality.yml"
RELEASE="$ROOT_DIR/scripts/release_check.sh"

if [[ ! -s "$DOC" ]]; then
  echo "missing first-use doctor docs" >&2
  exit 1
fi

grep -q "# First-use Doctor" "$DOC"
grep -q -- "./scripts/doctor.sh --out" "$DOC"
grep -q -- "--with-matlab" "$DOC"
grep -q "metadata-only" "$DOC"
grep -q "first_use_doctor.json" "$DOC"
grep -q "does not render figures" "$DOC"

grep -q "docs/first-use-doctor.md" "$ROOT_DIR/README.md"
grep -q "docs/first-use-doctor.md" "$ROOT_DIR/README.zh-CN.md"
grep -q "doctor.sh" "$ROOT_DIR/skills/matlab-plotting-skill/SKILL.md"
grep -q "doctor.sh" "$ROOT_DIR/docs/first-five-minutes.md"
grep -q "doctor.sh" "$ROOT_DIR/docs/first-render-walkthrough.md"
grep -q "doctor.sh" "$ROOT_DIR/docs/first-render-walkthrough.zh-CN.md"
grep -q "doctor.sh" "$ROOT_DIR/CHANGELOG.md"

grep -q "bash -n scripts/doctor.sh" "$WORKFLOW"
grep -q "bash -n tests/test_doctor.sh" "$WORKFLOW"
grep -q "tests/test_doctor.sh" "$WORKFLOW"
grep -q "tests/test_doctor_docs.sh" "$WORKFLOW"
grep -q "tests/test_doctor.sh" "$RELEASE"
grep -q "tests/test_doctor_docs.sh" "$RELEASE"

echo "doctor docs test passed."
