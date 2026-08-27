#!/usr/bin/env bash
set -euo pipefail

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MATLAB_DIR="$SKILL_DIR/assets/matlab"
SCHEME_CATALOG="$SKILL_DIR/references/scheme-catalog.md"
REPO_ROOT="$(cd "$SKILL_DIR/../.." && pwd)"
SCHEME_READINESS="$REPO_ROOT/docs/scheme-readiness.md"
REVIEW_VALIDATOR="$REPO_ROOT/scripts/validate_plot_review.py"
MATLAB_BIN="${MATLAB_BIN:-matlab}"
MP_MATLAB_TIMEOUT_SECONDS="${MP_MATLAB_TIMEOUT_SECONDS:-600}"
MP_MATLAB_COLD_START_BUDGET_SECONDS="${MP_MATLAB_COLD_START_BUDGET_SECONDS:-60}"
MP_PER_SCHEME_BUDGET_SECONDS="${MP_PER_SCHEME_BUDGET_SECONDS:-45}"
DATA_PATH=""
GOAL_TEXT=""
OUT_DIR="figures"
FORMATS="png,svg"
SMOKE_TEST=0
LIST_SCHEMES=0
LIST_SCHEMES_JSON=0
CHECK_ONLY=0
PLAN_ONLY=0
INSPECT_DATA=0
SCHEME_INFO=0
SCHEME_INFO_JSON=0
SHOW_STATUS=0
EXPLAIN=0
DOCTOR=0
DOCTOR_WITH_MATLAB=0
OUT_DIR_EXPLICIT=0
CANDIDATE_PACK=0
CANDIDATE_COUNT=3
FINALIZE_REVIEW=0
REVIEW_PATH=""
MANIFEST_PATH=""
SCHEME_NAME=""
SCHEME_INFO_NAME=""
MAT_VARIABLE=""

usage() {
  cat <<'USAGE'
Usage:
  render_with_matlab.sh --data <file> --goal "<text>" [--scheme <name>] [--var <mat-variable>] [--out <dir>] [--formats png,svg]
  render_with_matlab.sh --smoke-test [--out <dir>] [--formats png]
  render_with_matlab.sh --list-schemes [--status]
  render_with_matlab.sh --list-schemes-json [--status]
  render_with_matlab.sh --scheme-info <name> [--status]
  render_with_matlab.sh --scheme-info-json <name> [--status]
  render_with_matlab.sh --doctor --out <dir> [--data <file>] [--with-matlab]
  render_with_matlab.sh --check
  render_with_matlab.sh --inspect-data --data <csv|xls|xlsx|mat> [--var <mat-variable>]
  render_with_matlab.sh --plan-only --data <file> --goal "<text>" [--scheme <name>] [--var <mat-variable>]
  render_with_matlab.sh --explain --data <file> --goal "<text>" [--scheme <name>] [--var <mat-variable>]
  render_with_matlab.sh --candidate-pack --data <file> --goal "<text>" [--candidate-count 3] [--out <dir>] [--formats png,svg]
  render_with_matlab.sh --finalize-review <review.json> --candidate-manifest <manifest.json> --data <file> --goal "<text>" [--out <dir>] [--formats png,svg]

Environment:
  MATLAB_BIN=/path/to/matlab
  MP_MATLAB_TIMEOUT_SECONDS=600
  MP_MATLAB_COLD_START_BUDGET_SECONDS=60
  MP_PER_SCHEME_BUDGET_SECONDS=45
USAGE
}

require_value() {
  local option="$1"
  local value="${2:-}"

  if [[ -z "$value" || "$value" == --* ]]; then
    echo "$option requires a value." >&2
    usage >&2
    exit 2
  fi
}

validate_formats() {
  local raw="$1"
  local found=0
  local format

  IFS=',' read -r -a requested_formats <<<"$raw"
  for format in "${requested_formats[@]}"; do
    format="${format#"${format%%[![:space:]]*}"}"
    format="${format%"${format##*[![:space:]]}"}"
    if [[ -z "$format" ]]; then
      continue
    fi
    if [[ ! "$format" =~ ^(png|svg|pdf)$ ]]; then
      echo "Invalid --formats entry: $format" >&2
      echo "Use a comma-separated list containing png, svg, and/or pdf." >&2
      exit 2
    fi
    found=1
  done

  if [[ "$found" -eq 0 ]]; then
    echo "--formats must include at least one of: png, svg, pdf." >&2
    exit 2
  fi
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --data)
      require_value "$1" "${2:-}"
      DATA_PATH="$2"
      shift 2
      ;;
    --goal)
      require_value "$1" "${2:-}"
      GOAL_TEXT="$2"
      shift 2
      ;;
    --out)
      if [[ "$#" -lt 2 || "${2:-}" == --* ]]; then
        require_value "$1" "${2:-}"
      fi
      if [[ -z "$2" ]]; then
        echo "--out must not be empty." >&2
        exit 2
      fi
      if [[ "$2" =~ [[:cntrl:]] ]]; then
        echo "--out may not contain control characters." >&2
        exit 2
      fi
      OUT_DIR="$2"
      OUT_DIR_EXPLICIT=1
      shift 2
      ;;
    --formats)
      require_value "$1" "${2:-}"
      FORMATS="$2"
      shift 2
      ;;
    --scheme)
      require_value "$1" "${2:-}"
      SCHEME_NAME="$2"
      shift 2
      ;;
    --var)
      require_value "$1" "${2:-}"
      MAT_VARIABLE="$2"
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
    --list-schemes-json)
      LIST_SCHEMES_JSON=1
      shift
      ;;
    --status)
      SHOW_STATUS=1
      shift
      ;;
    --explain)
      EXPLAIN=1
      shift
      ;;
    --doctor)
      DOCTOR=1
      shift
      ;;
    --with-matlab)
      DOCTOR_WITH_MATLAB=1
      shift
      ;;
    --scheme-info)
      require_value "$1" "${2:-}"
      SCHEME_INFO=1
      SCHEME_INFO_NAME="$2"
      shift 2
      ;;
    --scheme-info-json)
      require_value "$1" "${2:-}"
      SCHEME_INFO_JSON=1
      SCHEME_INFO_NAME="$2"
      shift 2
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
    --candidate-pack)
      CANDIDATE_PACK=1
      shift
      ;;
    --candidate-count)
      require_value "$1" "${2:-}"
      CANDIDATE_COUNT="$2"
      shift 2
      ;;
    --finalize-review)
      require_value "$1" "${2:-}"
      FINALIZE_REVIEW=1
      REVIEW_PATH="$2"
      shift 2
      ;;
    --candidate-manifest)
      require_value "$1" "${2:-}"
      MANIFEST_PATH="$2"
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

validate_formats "$FORMATS"

if [[ ! "$CANDIDATE_COUNT" =~ ^[2-5]$ ]]; then
  echo "--candidate-count must be an integer from 2 to 5." >&2
  exit 2
fi

if [[ "$DOCTOR_WITH_MATLAB" -eq 1 && "$DOCTOR" -ne 1 ]]; then
  echo "--with-matlab is only valid with --doctor." >&2
  usage >&2
  exit 2
fi

if [[ "$DOCTOR" -eq 1 ]]; then
  if [[ "$OUT_DIR_EXPLICIT" -ne 1 ]]; then
    echo "--doctor requires --out <dir>." >&2
    usage >&2
    exit 2
  fi

  doctor_args=(--out "$OUT_DIR")
  if [[ -n "$DATA_PATH" ]]; then
    doctor_args+=(--data "$DATA_PATH")
  fi
  if [[ "$DOCTOR_WITH_MATLAB" -eq 1 ]]; then
    doctor_args+=(--with-matlab)
  fi
  exec "$SKILL_DIR/scripts/doctor.sh" "${doctor_args[@]}"
fi

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

run_with_timeout() {
  local seconds="$1"
  shift

  if [[ ! "$seconds" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
    echo "Invalid timeout seconds: $seconds" >&2
    return 2
  fi

  if [[ "$seconds" =~ ^0+([.]0+)?$ ]]; then
    "$@"
    return
  fi

  if ! command -v python3 >/dev/null 2>&1; then
    echo "python3 not found; running MATLAB command without timeout guard." >&2
    "$@"
    return
  fi

  python3 - "$seconds" "$@" <<'PY'
import os
import signal
import subprocess
import sys
import time

seconds = float(sys.argv[1])
command = sys.argv[2:]

try:
    process = subprocess.Popen(command, start_new_session=True)
except OSError as exc:
    print(f"Failed to start command: {exc}", file=sys.stderr)
    sys.exit(127)

try:
    sys.exit(process.wait(timeout=seconds))
except subprocess.TimeoutExpired:
    print(f"Command timed out after {seconds:g}s.", file=sys.stderr)
    try:
        os.killpg(process.pid, signal.SIGTERM)
    except ProcessLookupError:
        pass
    try:
        process.wait(timeout=5)
    except subprocess.TimeoutExpired:
        try:
            os.killpg(process.pid, signal.SIGKILL)
        except ProcessLookupError:
            pass
        process.wait()
    time.sleep(0.1)
    sys.exit(124)
PY
}

count_catalog_schemes() {
  if [[ ! -f "$SCHEME_CATALOG" ]]; then
    echo "Scheme catalog not found: $SCHEME_CATALOG" >&2
    return 1
  fi

  python3 - "$SCHEME_CATALOG" <<'PY'
import re
import sys
from pathlib import Path

catalog = Path(sys.argv[1])
pattern = re.compile(r"^\| `[^`]+` \|")
count = sum(1 for line in catalog.read_text(encoding="utf-8").splitlines() if pattern.match(line))
print(count)
PY
}

smoke_timeout_budget() {
  local scheme_count="$1"

  python3 - "$MP_MATLAB_TIMEOUT_SECONDS" "$MP_MATLAB_COLD_START_BUDGET_SECONDS" "$MP_PER_SCHEME_BUDGET_SECONDS" "$scheme_count" <<'PY'
import math
import sys

labels = [
    "MP_MATLAB_TIMEOUT_SECONDS",
    "MP_MATLAB_COLD_START_BUDGET_SECONDS",
    "MP_PER_SCHEME_BUDGET_SECONDS",
]
raw_base, raw_cold, raw_per, raw_count = sys.argv[1:]

def parse_number(raw, label):
    try:
        value = float(raw)
    except ValueError:
        print(f"Invalid {label}: {raw}", file=sys.stderr)
        raise SystemExit(2)
    if value < 0 or not math.isfinite(value):
        print(f"Invalid {label}: {raw}", file=sys.stderr)
        raise SystemExit(2)
    return value

base = parse_number(raw_base, labels[0])
cold = parse_number(raw_cold, labels[1])
per_scheme = parse_number(raw_per, labels[2])
scheme_count = int(raw_count)

if base == 0:
    print("0")
else:
    budget = max(base, cold + per_scheme * scheme_count)
    print(f"{budget:g}")
PY
}

scheme_info() {
  local scheme_name="$1"
  local output_mode="$2"
  local show_status="$3"

  if [[ -z "$scheme_name" ]]; then
    echo "Scheme name is required." >&2
    exit 2
  fi

  if [[ ! -f "$SCHEME_CATALOG" ]]; then
    echo "Scheme catalog not found: $SCHEME_CATALOG" >&2
    exit 1
  fi

  python3 - "$SCHEME_CATALOG" "$SCHEME_READINESS" "$scheme_name" "$output_mode" "$show_status" <<'PY'
import json
import re
import sys
from pathlib import Path

catalog = Path(sys.argv[1])
readiness_path = Path(sys.argv[2])
scheme_name = sys.argv[3]
output_mode = sys.argv[4]
show_status = sys.argv[5] == "1"
pattern = re.compile(r"^\| `(?P<scheme>[^`]+)` \| (?P<family>[^|]+) \| (?P<best_for>[^|]+) \| (?P<palette>[^|]+) \|")
readiness_pattern = re.compile(r"^\| `(?P<scheme>[^`]+)` \| [^|]+ \| (?P<readiness>[^|]+) \| (?P<gallery>[^|]+) \|")

readiness = {}
if show_status and readiness_path.is_file():
    for line in readiness_path.read_text(encoding="utf-8").splitlines():
        match = readiness_pattern.match(line)
        if not match:
            continue
        item = {key: value.strip() for key, value in match.groupdict().items()}
        gallery = "preview" if item["gallery"].startswith("[preview]") else item["gallery"]
        readiness[item["scheme"]] = {"readiness": item["readiness"], "gallery": gallery}

for line in catalog.read_text(encoding="utf-8").splitlines():
    match = pattern.match(line)
    if not match:
        continue
    item = {key: value.strip() for key, value in match.groupdict().items()}
    if item["scheme"] != scheme_name:
        continue
    item["schema_version"] = "1.0"
    if show_status:
        item.update(readiness.get(item["scheme"], {"readiness": "unknown", "gallery": "unknown"}))
    if output_mode == "json":
        print(json.dumps(item, indent=2))
    else:
        print(f"Scheme: {item['scheme']}")
        print(f"Family: {item['family']}")
        print(f"Best for: {item['best_for']}")
        print(f"Default palette: {item['palette']}")
        if show_status:
            print(f"Readiness: {item['readiness']}")
            print(f"Gallery: {item['gallery']}")
    raise SystemExit(0)

print(f"Unknown scheme: {scheme_name}", file=sys.stderr)
raise SystemExit(67)
PY
}

if [[ "$LIST_SCHEMES" -eq 1 ]]; then
  if [[ ! -f "$SCHEME_CATALOG" ]]; then
    echo "Scheme catalog not found: $SCHEME_CATALOG" >&2
    exit 1
  fi
  python3 - "$SCHEME_CATALOG" "$SCHEME_READINESS" "$SHOW_STATUS" text <<'PY'
import re
import sys
from pathlib import Path

catalog = Path(sys.argv[1])
readiness_path = Path(sys.argv[2])
show_status = sys.argv[3] == "1"
mode = sys.argv[4]
catalog_pattern = re.compile(r"^\| `(?P<scheme>[^`]+)` \| (?P<family>[^|]+) \| (?P<best_for>[^|]+) \| (?P<palette>[^|]+) \|")
readiness_pattern = re.compile(r"^\| `(?P<scheme>[^`]+)` \| [^|]+ \| (?P<readiness>[^|]+) \| (?P<gallery>[^|]+) \|")

readiness = {}
if show_status and readiness_path.is_file():
    for line in readiness_path.read_text(encoding="utf-8").splitlines():
        match = readiness_pattern.match(line)
        if match:
            item = {key: value.strip() for key, value in match.groupdict().items()}
            gallery = "preview" if item["gallery"].startswith("[preview]") else item["gallery"]
            readiness[item["scheme"]] = {"readiness": item["readiness"], "gallery": gallery}

for line in catalog.read_text(encoding="utf-8").splitlines():
    match = catalog_pattern.match(line)
    if not match:
        continue
    item = {key: value.strip() for key, value in match.groupdict().items()}
    if show_status:
        status = readiness.get(item["scheme"], {"readiness": "unknown", "gallery": "unknown"})
        print(f"{item['scheme']:<28} {item['family']:<14} {status['readiness']:<20} {status['gallery']:<8} {item['best_for']} [{item['palette']}]")
    else:
        print(f"{item['scheme']:<28} {item['family']:<14} {item['best_for']} [{item['palette']}]")
PY
  exit 0
fi

if [[ "$LIST_SCHEMES_JSON" -eq 1 ]]; then
  if [[ ! -f "$SCHEME_CATALOG" ]]; then
    echo "Scheme catalog not found: $SCHEME_CATALOG" >&2
    exit 1
  fi
  python3 - "$SCHEME_CATALOG" "$SCHEME_READINESS" "$SHOW_STATUS" <<'PY'
import json
import re
import sys
from pathlib import Path

catalog = Path(sys.argv[1])
readiness_path = Path(sys.argv[2])
show_status = sys.argv[3] == "1"
rows = []
pattern = re.compile(r"^\| `(?P<scheme>[^`]+)` \| (?P<family>[^|]+) \| (?P<best_for>[^|]+) \| (?P<palette>[^|]+) \|")
readiness_pattern = re.compile(r"^\| `(?P<scheme>[^`]+)` \| [^|]+ \| (?P<readiness>[^|]+) \| (?P<gallery>[^|]+) \|")
readiness = {}
if show_status and readiness_path.is_file():
    for line in readiness_path.read_text(encoding="utf-8").splitlines():
        match = readiness_pattern.match(line)
        if match:
            item = {key: value.strip() for key, value in match.groupdict().items()}
            item["gallery"] = "preview" if item["gallery"].startswith("[preview]") else item["gallery"]
            readiness[item["scheme"]] = {"readiness": item["readiness"], "gallery": item["gallery"]}
for line in catalog.read_text(encoding="utf-8").splitlines():
    match = pattern.match(line)
    if match:
        item = {key: value.strip() for key, value in match.groupdict().items()}
        item["schema_version"] = "1.0"
        if show_status:
            item.update(readiness.get(item["scheme"], {"readiness": "unknown", "gallery": "unknown"}))
        rows.append(item)
print(json.dumps(rows, indent=2))
PY
  exit 0
fi

if [[ "$SCHEME_INFO" -eq 1 ]]; then
  scheme_info "$SCHEME_INFO_NAME" text "$SHOW_STATUS"
  exit 0
fi

if [[ "$SCHEME_INFO_JSON" -eq 1 ]]; then
  scheme_info "$SCHEME_INFO_NAME" json "$SHOW_STATUS"
  exit 0
fi

matlab_quote() {
  local value="$1"
  value="${value//\\/\\\\}"
  value="${value//\'/\'\'}"
  printf "'%s'" "$value"
}

formats_expr="split(string($(matlab_quote "$FORMATS")), ',')"

if [[ "$SMOKE_TEST" -eq 0 && "$CHECK_ONLY" -eq 0 ]]; then
  if [[ -z "$DATA_PATH" ]]; then
    echo "--data is required unless --smoke-test, --check, or metadata listing is used." >&2
    usage >&2
    exit 2
  fi

  if [[ "$INSPECT_DATA" -eq 0 && -z "$GOAL_TEXT" ]]; then
    echo "--goal is required unless --inspect-data, --smoke-test, --check, or metadata listing is used." >&2
    usage >&2
    exit 2
  fi
fi

if [[ "$EXPLAIN" -eq 1 ]]; then
  PLAN_ONLY=1
fi

if [[ -n "$DATA_PATH" && ! -f "$DATA_PATH" ]]; then
  echo "Data file not found: $DATA_PATH" >&2
  exit 66
fi

if [[ -n "$DATA_PATH" ]]; then
  data_extension=".${DATA_PATH##*.}"
  data_extension="$(printf '%s' "$data_extension" | tr '[:upper:]' '[:lower:]')"
  case "$data_extension" in
    .csv|.xls|.xlsx|.mat) ;;
    *)
      echo "Unsupported data file extension: $data_extension" >&2
      echo "Use a CSV, Excel, or MAT file." >&2
      exit 65
      ;;
  esac
fi

if [[ "$FINALIZE_REVIEW" -eq 1 ]]; then
  if [[ -z "$MANIFEST_PATH" ]]; then
    echo "--finalize-review requires --candidate-manifest <manifest.json>." >&2
    exit 2
  fi
  if [[ ! -f "$REVIEW_PATH" ]]; then
    echo "Review file not found: $REVIEW_PATH" >&2
    exit 66
  fi
  if [[ ! -f "$MANIFEST_PATH" ]]; then
    echo "Candidate manifest not found: $MANIFEST_PATH" >&2
    exit 66
  fi
  mkdir -p "$OUT_DIR"
  python3 "$REVIEW_VALIDATOR" --review "$REVIEW_PATH" --manifest "$MANIFEST_PATH" \
    --out "$OUT_DIR/validated_review.json"
fi

check_matlab_bin

if [[ "$CHECK_ONLY" -eq 1 ]]; then
  run_with_timeout "$MP_MATLAB_TIMEOUT_SECONDS" "$MATLAB_BIN" -batch "disp(version)"
  echo "MATLAB CLI check passed: $MATLAB_BIN"
  exit 0
fi

if [[ "$SMOKE_TEST" -eq 1 ]]; then
  mkdir -p "$OUT_DIR"
  scheme_count="$(count_catalog_schemes)"
  smoke_timeout="$(smoke_timeout_budget "$scheme_count")"
  if [[ "$smoke_timeout" == "0" ]]; then
    echo "Smoke test: $scheme_count schemes, timeout guard disabled (MP_MATLAB_TIMEOUT_SECONDS=0)."
  else
    echo "Smoke test: $scheme_count schemes, budget ${smoke_timeout}s (cold_start=${MP_MATLAB_COLD_START_BUDGET_SECONDS}s + per_scheme=${MP_PER_SCHEME_BUDGET_SECONDS}s * $scheme_count; floor=${MP_MATLAB_TIMEOUT_SECONDS}s)."
  fi
  run_with_timeout "$smoke_timeout" "$MATLAB_BIN" -batch "addpath(genpath($(matlab_quote "$MATLAB_DIR"))); mpSmokeTest($(matlab_quote "$OUT_DIR"), $formats_expr);"
  exit 0
fi

if [[ "$INSPECT_DATA" -eq 1 ]]; then
  run_with_timeout "$MP_MATLAB_TIMEOUT_SECONDS" "$MATLAB_BIN" -batch "addpath(genpath($(matlab_quote "$MATLAB_DIR"))); inspection = mpInspectData($(matlab_quote "$DATA_PATH"), $(matlab_quote "$MAT_VARIABLE")); disp(jsonencode(inspection));"
  exit 0
fi

if [[ "$PLAN_ONLY" -eq 1 ]]; then
  if [[ "$EXPLAIN" -eq 1 ]]; then
    run_with_timeout "$MP_MATLAB_TIMEOUT_SECONDS" "$MATLAB_BIN" -batch "addpath(genpath($(matlab_quote "$MATLAB_DIR"))); plan = mpPlan($(matlab_quote "$DATA_PATH"), $(matlab_quote "$GOAL_TEXT"), $(matlab_quote "$SCHEME_NAME"), $(matlab_quote "$MAT_VARIABLE")); disp(mpFormatPlanExplanation(plan));"
  else
    run_with_timeout "$MP_MATLAB_TIMEOUT_SECONDS" "$MATLAB_BIN" -batch "addpath(genpath($(matlab_quote "$MATLAB_DIR"))); plan = mpPlan($(matlab_quote "$DATA_PATH"), $(matlab_quote "$GOAL_TEXT"), $(matlab_quote "$SCHEME_NAME"), $(matlab_quote "$MAT_VARIABLE")); disp(jsonencode(plan));"
  fi
  exit 0
fi

if [[ "$CANDIDATE_PACK" -eq 1 ]]; then
  mkdir -p "$OUT_DIR"
  run_with_timeout "$MP_MATLAB_TIMEOUT_SECONDS" "$MATLAB_BIN" -batch "addpath(genpath($(matlab_quote "$MATLAB_DIR"))); result = mpBuildCandidatePack($(matlab_quote "$DATA_PATH"), $(matlab_quote "$GOAL_TEXT"), $(matlab_quote "$OUT_DIR"), $formats_expr, $CANDIDATE_COUNT, $(matlab_quote "$MAT_VARIABLE")); disp(result.ManifestPath);"
  exit 0
fi

if [[ "$FINALIZE_REVIEW" -eq 1 ]]; then
  run_with_timeout "$MP_MATLAB_TIMEOUT_SECONDS" "$MATLAB_BIN" -batch "addpath(genpath($(matlab_quote "$MATLAB_DIR"))); result = mpFinalizeReviewPack($(matlab_quote "$DATA_PATH"), $(matlab_quote "$GOAL_TEXT"), $(matlab_quote "$MANIFEST_PATH"), $(matlab_quote "$OUT_DIR/validated_review.json"), $(matlab_quote "$OUT_DIR"), $formats_expr, $(matlab_quote "$MAT_VARIABLE")); disp(result.EvidenceMarkdownPath);"
  exit 0
fi

mkdir -p "$OUT_DIR"
run_with_timeout "$MP_MATLAB_TIMEOUT_SECONDS" "$MATLAB_BIN" -batch "addpath(genpath($(matlab_quote "$MATLAB_DIR"))); result = mpRun($(matlab_quote "$DATA_PATH"), $(matlab_quote "$GOAL_TEXT"), $(matlab_quote "$OUT_DIR"), $formats_expr, $(matlab_quote "$SCHEME_NAME"), $(matlab_quote "$MAT_VARIABLE")); disp(result.SelectedScheme);"
