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

echo "privacy check test passed."
