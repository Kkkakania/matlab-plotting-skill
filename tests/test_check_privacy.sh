#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT
PRIVATE_ROOT="/Users/"
PRIVATE_ROOT+="wi"

printf 'gitdir: %s/example/.git/worktrees/example\n' "$PRIVATE_ROOT" > "$TMP_DIR/.git"

(
  cd "$TMP_DIR"
  "$ROOT_DIR/scripts/check_privacy.sh"
)

printf 'local path: %s/private/data.csv\n' "$PRIVATE_ROOT" > "$TMP_DIR/leak.txt"
HOME_ROOT="/home"
HOME_ROOT+="/example"
WSL_ROOT="/mnt/c"
WSL_ROOT+="/Users/example"
WINDOWS_ROOT="C:"
WINDOWS_ROOT+="\\Users\\example"
PROFILE_ROOT="%USER"
PROFILE_ROOT+="PROFILE%\\example"
CODESPACES_ROOT="/work"
CODESPACES_ROOT+="spaces/private-repo"
VOLUME_ROOT="/Volumes"
VOLUME_ROOT+="/External"
{
  printf 'linux path: %s/private/data.csv\n' "$HOME_ROOT"
  printf 'wsl path: %s/private/data.csv\n' "$WSL_ROOT"
  printf 'windows path: %s\\private\\data.csv\n' "$WINDOWS_ROOT"
  printf 'profile path: %s\\private\\data.csv\n' "$PROFILE_ROOT"
  printf 'codespaces path: %s/private/data.csv\n' "$CODESPACES_ROOT"
  printf 'volume path: %s/private/data.csv\n' "$VOLUME_ROOT"
} >> "$TMP_DIR/leak.txt"

set +e
output="$(
  cd "$TMP_DIR"
  "$ROOT_DIR/scripts/check_privacy.sh"
)" 2>&1
status=$?
set -e

if [[ "$status" -eq 0 ]]; then
  echo "privacy check should still catch private paths in normal files" >&2
  exit 1
fi

for expected in \
  "$PRIVATE_ROOT/private/data.csv" \
  "$HOME_ROOT/private/data.csv" \
  "$WSL_ROOT/private/data.csv" \
  "$WINDOWS_ROOT\\private\\data.csv" \
  "$PROFILE_ROOT\\private\\data.csv" \
  "$CODESPACES_ROOT/private/data.csv" \
  "$VOLUME_ROOT/private/data.csv"; do
  if [[ "$output" != *"$expected"* ]]; then
    echo "privacy check missed expected marker: $expected" >&2
    printf '%s\n' "$output" >&2
    exit 1
  fi
done

echo "privacy check test passed."
