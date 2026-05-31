#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT="$ROOT_DIR/scripts/render_with_matlab.sh"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

check_missing_value() {
  local option="$1"
  local out_file="$TMP_DIR/${option#--}.out"
  local err_file="$TMP_DIR/${option#--}.err"
  local status

  set +e
  "$SCRIPT" "$option" >"$out_file" 2>"$err_file"
  status=$?
  set -e

  if [[ "$status" -eq 0 ]]; then
    echo "expected $option without a value to fail" >&2
    exit 1
  fi

  if [[ "$status" -ne 2 ]]; then
    echo "expected $option without a value to exit 2, got $status" >&2
    cat "$err_file" >&2
    exit 1
  fi

  if ! grep -q -- "$option requires a value" "$err_file"; then
    echo "expected clear missing-value message for $option" >&2
    cat "$err_file" >&2
    exit 1
  fi
}

check_missing_value --data
check_missing_value --goal
check_missing_value --out
check_missing_value --formats
check_missing_value --scheme
check_missing_value --var
check_missing_value --scheme-info
check_missing_value --scheme-info-json

check_bad_formats() {
  local formats="$1"
  local expected="$2"
  local out_file="$TMP_DIR/formats.out"
  local err_file="$TMP_DIR/formats.err"
  local status

  set +e
  "$SCRIPT" --list-schemes --formats "$formats" >"$out_file" 2>"$err_file"
  status=$?
  set -e

  if [[ "$status" -ne 2 ]]; then
    echo "expected --formats '$formats' to exit 2, got $status" >&2
    cat "$err_file" >&2
    exit 1
  fi

  if ! grep -q -- "$expected" "$err_file"; then
    echo "expected clear format validation message for '$formats'" >&2
    cat "$err_file" >&2
    exit 1
  fi
}

check_bad_formats "png,jpg" "Invalid --formats entry: jpg"
check_bad_formats "," "--formats must include at least one"

echo "render_with_matlab argument test passed."
