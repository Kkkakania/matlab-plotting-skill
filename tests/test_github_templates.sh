#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

required=(
  ".github/ISSUE_TEMPLATE/bug_report.yml"
  ".github/ISSUE_TEMPLATE/first_use_feedback.yml"
  ".github/ISSUE_TEMPLATE/scheme_request.yml"
  ".github/ISSUE_TEMPLATE/config.yml"
  ".github/pull_request_template.md"
)

for file in "${required[@]}"; do
  if [[ ! -s "$ROOT_DIR/$file" ]]; then
    echo "missing GitHub template: $file" >&2
    exit 1
  fi
done

grep -q "MATLAB" "$ROOT_DIR/.github/ISSUE_TEMPLATE/bug_report.yml"
grep -q "First-use feedback" "$ROOT_DIR/.github/ISSUE_TEMPLATE/first_use_feedback.yml"
grep -q "render_report.md" "$ROOT_DIR/.github/ISSUE_TEMPLATE/first_use_feedback.yml"
grep -q "private data" "$ROOT_DIR/.github/ISSUE_TEMPLATE/first_use_feedback.yml"
grep -q "First render walkthrough" "$ROOT_DIR/.github/ISSUE_TEMPLATE/config.yml"
grep -q "scheme" "$ROOT_DIR/.github/ISSUE_TEMPLATE/scheme_request.yml"
grep -q "clean-room" "$ROOT_DIR/.github/pull_request_template.md"

echo "GitHub templates test passed."
