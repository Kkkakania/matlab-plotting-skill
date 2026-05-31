#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT="$ROOT_DIR/scripts/run_visual_fixtures.sh"

if [[ ! -x "$SCRIPT" ]]; then
  echo "missing executable visual fixtures script: $SCRIPT" >&2
  exit 1
fi

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

set +e
"$SCRIPT" --out >/dev/null 2>"$TMP_DIR/missing-out.err"
missing_out_status=$?
set -e

if [[ "$missing_out_status" -ne 2 ]]; then
  echo "expected --out without a value to exit 2, got $missing_out_status" >&2
  cat "$TMP_DIR/missing-out.err" >&2
  exit 1
fi

if ! grep -q -- "--out requires a value" "$TMP_DIR/missing-out.err"; then
  echo "expected clear missing-value message for --out" >&2
  cat "$TMP_DIR/missing-out.err" >&2
  exit 1
fi

help_output="$("$SCRIPT" --help)"

grep -q "test_mp_visual_fixtures.m" <<<"$help_output"
grep -q "MATLAB_BIN" <<<"$help_output"
grep -q "figures/visual-fixtures" <<<"$help_output"

echo "visual fixtures script test passed."
