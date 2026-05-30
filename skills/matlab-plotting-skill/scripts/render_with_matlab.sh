#!/usr/bin/env bash
set -euo pipefail

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MATLAB_DIR="$SKILL_DIR/assets/matlab"
MATLAB_BIN="${MATLAB_BIN:-matlab}"
DATA_PATH=""
GOAL_TEXT=""
OUT_DIR="figures"
FORMATS="png,svg"
SMOKE_TEST=0

usage() {
  cat <<'USAGE'
Usage:
  render_with_matlab.sh --data <file> --goal "<text>" [--out <dir>] [--formats png,svg]
  render_with_matlab.sh --smoke-test [--out <dir>] [--formats png]

Environment:
  MATLAB_BIN=/path/to/matlab
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --data)
      DATA_PATH="${2:-}"
      shift 2
      ;;
    --goal)
      GOAL_TEXT="${2:-}"
      shift 2
      ;;
    --out)
      OUT_DIR="${2:-}"
      shift 2
      ;;
    --formats)
      FORMATS="${2:-}"
      shift 2
      ;;
    --smoke-test)
      SMOKE_TEST=1
      shift
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
    echo "Set MATLAB_BIN to the full MATLAB executable path." >&2
    exit 127
  fi
elif ! command -v "$MATLAB_BIN" >/dev/null 2>&1; then
  echo "MATLAB executable not found: $MATLAB_BIN" >&2
  echo "Try: MATLAB_BIN=/Applications/MATLAB_R2025a.app/bin/matlab $0 --smoke-test" >&2
  exit 127
fi

mkdir -p "$OUT_DIR"

matlab_quote() {
  local value="$1"
  value="${value//\\/\\\\}"
  value="${value//\'/\'\'}"
  printf "'%s'" "$value"
}

formats_expr="split(string($(matlab_quote "$FORMATS")), ',')"

if [[ "$SMOKE_TEST" -eq 1 ]]; then
  "$MATLAB_BIN" -batch "addpath(genpath($(matlab_quote "$MATLAB_DIR"))); mpSmokeTest($(matlab_quote "$OUT_DIR"), $formats_expr);"
  exit 0
fi

if [[ -z "$DATA_PATH" ]]; then
  echo "--data is required unless --smoke-test is used." >&2
  usage >&2
  exit 2
fi

if [[ ! -f "$DATA_PATH" ]]; then
  echo "Data file not found: $DATA_PATH" >&2
  exit 66
fi

"$MATLAB_BIN" -batch "addpath(genpath($(matlab_quote "$MATLAB_DIR"))); result = mpRun($(matlab_quote "$DATA_PATH"), $(matlab_quote "$GOAL_TEXT"), $(matlab_quote "$OUT_DIR"), $formats_expr); disp(result.SelectedScheme);"

