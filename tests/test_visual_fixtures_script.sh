#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT="$ROOT_DIR/scripts/run_visual_fixtures.sh"

if [[ ! -x "$SCRIPT" ]]; then
  echo "missing executable visual fixtures script: $SCRIPT" >&2
  exit 1
fi

help_output="$("$SCRIPT" --help)"

grep -q "test_mp_visual_fixtures.m" <<<"$help_output"
grep -q "MATLAB_BIN" <<<"$help_output"
grep -q "figures/visual-fixtures" <<<"$help_output"

echo "visual fixtures script test passed."
