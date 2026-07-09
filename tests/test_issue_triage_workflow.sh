#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORKFLOW="$ROOT_DIR/.github/workflows/issue-triage.yml"

if [[ ! -s "$WORKFLOW" ]]; then
  echo "missing issue triage workflow" >&2
  exit 1
fi

grep -q "issues:" "$WORKFLOW"
grep -q "types: \\[opened\\]" "$WORKFLOW"
grep -q "issues: write" "$WORKFLOW"
grep -q "matlab-figure-ecosystem-triage" "$WORKFLOW"
grep -q "synthetic CSV/MATLAB example" "$WORKFLOW"
grep -q "Kkkakania/matlab-scientific-figures#31" "$WORKFLOW"
grep -q "Awaiting feedback" "$WORKFLOW"
grep -q "gh issue comment" "$WORKFLOW"
grep -q "run_gh()" "$WORKFLOW"
grep -q "max_attempts=3" "$WORKFLOW"
grep -q "HTTP 5" "$WORKFLOW"

if grep -q "read:project" "$WORKFLOW"; then
  echo "issue triage workflow must not require GitHub Projects scopes" >&2
  exit 1
fi

if grep -q "project:" "$WORKFLOW"; then
  echo "issue triage workflow must not request project permission" >&2
  exit 1
fi

echo "Issue triage workflow test passed."
