#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MATLAB_BIN="${MATLAB_BIN:-matlab}"
OUT_DIR="$ROOT_DIR/figures/visual-fixtures"

usage() {
  cat <<'USAGE'
Usage:
  run_visual_fixtures.sh [--out <dir>]

Runs tests/test_mp_visual_fixtures.m with MATLAB and writes fixture images to
figures/visual-fixtures by default.

Environment:
  MATLAB_BIN=/path/to/matlab
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --out)
      OUT_DIR="${2:-}"
      shift 2
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ "$MATLAB_BIN" == */* ]]; then
  if [[ ! -x "$MATLAB_BIN" ]]; then
    echo "MATLAB executable not found: $MATLAB_BIN" >&2
    exit 127
  fi
elif ! command -v "$MATLAB_BIN" >/dev/null 2>&1; then
  echo "MATLAB executable not found: $MATLAB_BIN" >&2
  exit 127
fi

mkdir -p "$OUT_DIR"
export MP_VISUAL_FIXTURE_DIR="$OUT_DIR"

"$MATLAB_BIN" -batch "addpath(genpath('skills/matlab-plotting-skill/assets/matlab')); results = runtests('tests/test_mp_visual_fixtures.m'); assertSuccess(results);"
