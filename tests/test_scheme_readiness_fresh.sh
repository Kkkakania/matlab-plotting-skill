#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_MD="$(mktemp)"
trap 'rm -f "$TMP_MD"' EXIT

python3 "$ROOT_DIR/scripts/build_scheme_readiness.py" --out "$TMP_MD" >/dev/null

if ! diff -u "$ROOT_DIR/docs/scheme-readiness.md" "$TMP_MD"; then
  echo "docs/scheme-readiness.md is stale; regenerate it with scripts/build_scheme_readiness.py" >&2
  exit 1
fi

echo "scheme readiness freshness test passed."
