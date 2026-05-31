#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

required=(
  "CONTRIBUTING.md"
  "SECURITY.md"
  "CODE_OF_CONDUCT.md"
  "CHANGELOG.md"
)

for file in "${required[@]}"; do
  if [[ ! -s "$ROOT_DIR/$file" ]]; then
    echo "missing required repository document: $file" >&2
    exit 1
  fi
done

grep -q "clean-room" "$ROOT_DIR/CONTRIBUTING.md"
grep -q "MATLAB" "$ROOT_DIR/CONTRIBUTING.md"
grep -q "private data" "$ROOT_DIR/SECURITY.md"
grep -q "v0.1.5" "$ROOT_DIR/CHANGELOG.md"
grep -q "Works without MATLAB" "$ROOT_DIR/README.md"
grep -q "Requires MATLAB" "$ROOT_DIR/README.md"
grep -q -- "--list-schemes" "$ROOT_DIR/README.md"
grep -q -- "--plan-only" "$ROOT_DIR/README.md"

echo "repository docs test passed."
