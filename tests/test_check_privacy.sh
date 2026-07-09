#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT
PRIVATE_ROOT="/"
PRIVATE_ROOT+="Users"
PRIVATE_ROOT+="/wi"
HOME_ROOT="/"
HOME_ROOT+="home"
HOME_ROOT+="/researcher"
WINDOWS_ROOT="C:"
WINDOWS_ROOT+="\\"
WINDOWS_ROOT+="Users"
WINDOWS_ROOT+="\\researcher"

printf 'gitdir: %s/example/.git/worktrees/example\n' "$PRIVATE_ROOT" > "$TMP_DIR/.git"

(
  cd "$TMP_DIR"
  "$ROOT_DIR/scripts/check_privacy.sh"
)

printf 'local path: %s/private/data.csv\n' "$PRIVATE_ROOT" > "$TMP_DIR/leak.txt"

set +e
(
  cd "$TMP_DIR"
  "$ROOT_DIR/scripts/check_privacy.sh"
) >/dev/null 2>&1
status=$?
set -e

if [[ "$status" -eq 0 ]]; then
  echo "privacy check should still catch private paths in normal files" >&2
  exit 1
fi

rm "$TMP_DIR/leak.txt"
printf 'local path: %s/private/data.csv\n' "$HOME_ROOT" > "$TMP_DIR/home-leak.txt"

set +e
(
  cd "$TMP_DIR"
  "$ROOT_DIR/scripts/check_privacy.sh"
) >/dev/null 2>&1
status=$?
set -e

if [[ "$status" -eq 0 ]]; then
  echo "privacy check should catch POSIX home paths" >&2
  exit 1
fi

rm "$TMP_DIR/home-leak.txt"
printf 'local path: %s\\private\\data.csv\n' "$WINDOWS_ROOT" > "$TMP_DIR/windows-leak.txt"

set +e
(
  cd "$TMP_DIR"
  "$ROOT_DIR/scripts/check_privacy.sh"
) >/dev/null 2>&1
status=$?
set -e

if [[ "$status" -eq 0 ]]; then
  echo "privacy check should catch Windows user paths" >&2
  exit 1
fi

echo "privacy check test passed."
