#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT="$ROOT_DIR/scripts/release_check.sh"

if [[ ! -x "$SCRIPT" ]]; then
  echo "missing executable release check script: $SCRIPT" >&2
  exit 1
fi

help_output="$("$SCRIPT" --help)"

grep -q "release_check.sh" <<<"$help_output"
grep -q "with-matlab" <<<"$help_output"
grep -q "check_privacy.sh" <<<"$help_output"
grep -q "PYTHONDONTWRITEBYTECODE=1" "$SCRIPT"
grep -q "find scripts -type d -name '__pycache__'" "$SCRIPT"
grep -q "tests/test_docs_voice.sh" "$SCRIPT"
grep -q "tests/test_troubleshooting_docs.sh" "$SCRIPT"
grep -q "tests/test_render_with_matlab_args.sh" "$SCRIPT"

echo "release check script test passed."
