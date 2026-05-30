#!/usr/bin/env bash
set -euo pipefail

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MATLAB_DIR="$SKILL_DIR/assets/matlab"
SCHEME_CATALOG="$SKILL_DIR/references/scheme-catalog.md"
MATLAB_BIN="${MATLAB_BIN:-matlab}"
DATA_PATH=""
GOAL_TEXT=""
OUT_DIR="figures"
FORMATS="png,svg"
SMOKE_TEST=0
LIST_SCHEMES=0
CHECK_ONLY=0
PLAN_ONLY=0
INSPECT_DATA=0
SCHEME_NAME=""
MAT_VARIABLE=""

usage() {
  cat <<'USAGE'
Usage:
  render_with_matlab.sh --data <file> --goal "<text>" [--scheme <name>] [--var <mat-variable>] [--out <dir>] [--formats png,svg]
  render_with_matlab.sh --smoke-test [--out <dir>] [--formats png]
  render_with_matlab.sh --list-schemes
  render_with_matlab.sh --check
  render_with_matlab.sh --inspect-data --data <file> [--var <mat-variable>]
  render_with_matlab.sh --plan-only --data <file> --goal "<text>" [--scheme <name>] [--var <mat-variable>]

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
    --scheme)
      SCHEME_NAME="${2:-}"
      shift 2
      ;;
    --var)
      MAT_VARIABLE="${2:-}"
      shift 2
      ;;
    --smoke-test)
      SMOKE_TEST=1
      shift
      ;;
    --list-schemes)
      LIST_SCHEMES=1
      shift
      ;;
    --check)
      CHECK_ONLY=1
      shift
      ;;
    --plan-only)
      PLAN_ONLY=1
      shift
      ;;
    --inspect-data)
      INSPECT_DATA=1
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

check_matlab_bin() {
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
}

if [[ "$LIST_SCHEMES" -eq 1 ]]; then
  if [[ ! -f "$SCHEME_CATALOG" ]]; then
    echo "Scheme catalog not found: $SCHEME_CATALOG" >&2
    exit 1
  fi
  sed -nE 's/^\| `([^`]+)` \| ([^|]+) \| ([^|]+) \| ([^|]+) \|.*/\1\t\2\t\3\t\4/p' "$SCHEME_CATALOG" |
    while IFS=$'\t' read -r scheme family best_for palette; do
      printf '%-28s %-14s %s [%s]\n' "$scheme" "$family" "$best_for" "$palette"
    done
  exit 0
fi

check_matlab_bin

if [[ "$CHECK_ONLY" -eq 1 ]]; then
  "$MATLAB_BIN" -batch "disp(version)"
  echo "MATLAB CLI check passed: $MATLAB_BIN"
  exit 0
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

if [[ "$INSPECT_DATA" -eq 1 ]]; then
  "$MATLAB_BIN" -batch "addpath(genpath($(matlab_quote "$MATLAB_DIR"))); inspection = mpInspectData($(matlab_quote "$DATA_PATH"), $(matlab_quote "$MAT_VARIABLE")); disp(jsonencode(inspection));"
  exit 0
fi

if [[ "$PLAN_ONLY" -eq 1 ]]; then
  "$MATLAB_BIN" -batch "addpath(genpath($(matlab_quote "$MATLAB_DIR"))); plan = mpPlan($(matlab_quote "$DATA_PATH"), $(matlab_quote "$GOAL_TEXT"), $(matlab_quote "$SCHEME_NAME"), $(matlab_quote "$MAT_VARIABLE")); disp(jsonencode(plan));"
  exit 0
fi

"$MATLAB_BIN" -batch "addpath(genpath($(matlab_quote "$MATLAB_DIR"))); result = mpRun($(matlab_quote "$DATA_PATH"), $(matlab_quote "$GOAL_TEXT"), $(matlab_quote "$OUT_DIR"), $formats_expr, $(matlab_quote "$SCHEME_NAME"), $(matlab_quote "$MAT_VARIABLE")); disp(result.SelectedScheme);"
