#!/usr/bin/env bash
set -euo pipefail

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RENDER_SCRIPT="$SKILL_DIR/scripts/render_with_matlab.sh"
REPO_ROOT="$(cd "$SKILL_DIR/../.." && pwd)"
OUT_DIR=""
DATA_PATH=""
WITH_MATLAB=0

usage() {
  cat <<'USAGE'
Usage:
  doctor.sh --out <dir> [--data <file>] [--with-matlab]

Runs a first-use diagnostic without rendering figures.

Default mode is metadata-only:
  - skill file checks
  - scheme catalog count
  - reference document checks
  - MATLAB asset checks
  - optional repository checks when running from a full checkout
  - optional data file existence and extension check

Options:
  --out <dir>       Directory for first_use_doctor.md/json.
  --data <file>     Optional CSV, Excel, or MAT file to check lightly.
  --with-matlab     Also run the MATLAB CLI check.

Environment:
  MATLAB_BIN=/path/to/matlab
  MP_MATLAB_TIMEOUT_SECONDS=600
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

while [[ $# -gt 0 ]]; do
  case "$1" in
    --out)
      require_value "$1" "${2:-}"
      OUT_DIR="$2"
      shift 2
      ;;
    --data)
      require_value "$1" "${2:-}"
      DATA_PATH="$2"
      shift 2
      ;;
    --with-matlab)
      WITH_MATLAB=1
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

if [[ -z "$OUT_DIR" ]]; then
  echo "--out is required." >&2
  usage >&2
  exit 2
fi

if [[ -n "$DATA_PATH" && ! -f "$DATA_PATH" ]]; then
  echo "Data file not found: $DATA_PATH" >&2
  exit 2
fi

mkdir -p "$OUT_DIR"

CHECKS_FILE="$(mktemp)"
trap 'rm -f "$CHECKS_FILE"' EXIT
OVERALL_STATUS="pass"

add_check() {
  local name="$1"
  local status="$2"
  local detail="$3"

  printf '%s\t%s\t%s\n' "$name" "$status" "$detail" >>"$CHECKS_FILE"
  if [[ "$status" == "fail" ]]; then
    OVERALL_STATUS="fail"
  elif [[ "$status" == "warn" && "$OVERALL_STATUS" == "pass" ]]; then
    OVERALL_STATUS="warn"
  fi
}

run_repo_check_if_available() {
  local name="$1"
  local command="$2"

  if [[ -d "$REPO_ROOT/.git" && -x "$REPO_ROOT/$command" ]]; then
    if (cd "$REPO_ROOT" && "$REPO_ROOT/$command" >/dev/null 2>&1); then
      add_check "$name" "pass" "passed"
    else
      add_check "$name" "fail" "failed; run $command for details"
    fi
  else
    add_check "$name" "skip" "not available outside a full repository checkout"
  fi
}

if [[ -s "$SKILL_DIR/SKILL.md" && -x "$RENDER_SCRIPT" ]]; then
  add_check "skill skeleton" "pass" "SKILL.md and render script found"
else
  add_check "skill skeleton" "fail" "SKILL.md or render script is missing"
fi

if [[ -d "$SKILL_DIR/assets/matlab" ]]; then
  MATLAB_ASSET_COUNT="$(find "$SKILL_DIR/assets/matlab" -maxdepth 1 -type f -name 'mp*.m' | wc -l | tr -d '[:space:]')"
else
  MATLAB_ASSET_COUNT="0"
fi

if [[ "$MATLAB_ASSET_COUNT" -ge 10 ]]; then
  add_check "MATLAB assets" "pass" "$MATLAB_ASSET_COUNT MATLAB asset files found"
else
  add_check "MATLAB assets" "fail" "$MATLAB_ASSET_COUNT MATLAB asset files found; expected at least 10"
fi

REFERENCE_MISSING=()
for reference in data-contract.md example-prompts.md matlab-cli.md scheme-catalog.md; do
  if [[ ! -s "$SKILL_DIR/references/$reference" ]]; then
    REFERENCE_MISSING+=("$reference")
  fi
done

if [[ "${#REFERENCE_MISSING[@]}" -eq 0 ]]; then
  add_check "reference docs" "pass" "data contract, prompts, MATLAB CLI, and scheme catalog found"
else
  add_check "reference docs" "fail" "missing: ${REFERENCE_MISSING[*]}"
fi

SCHEME_COUNT="$("$RENDER_SCRIPT" --list-schemes | grep -Ec '^[A-Za-z0-9_]+[[:space:]]' || true)"
if [[ "$SCHEME_COUNT" -eq 50 ]]; then
  add_check "scheme catalog count" "pass" "50 schemes listed"
else
  add_check "scheme catalog count" "fail" "$SCHEME_COUNT schemes listed; expected 50"
fi

if [[ -s "$REPO_ROOT/docs/scheme-readiness.md" ]] && grep -q "| gallery-backed |" "$REPO_ROOT/docs/scheme-readiness.md"; then
  READINESS_DETAIL="$(python3 - "$REPO_ROOT/docs/scheme-readiness.md" <<'PY'
import re
import sys

text = open(sys.argv[1], encoding="utf-8").read().splitlines()
counts = {}
pattern = re.compile(r"^\| ([^|]+?) \| ([0-9]+) \|$")
for line in text:
    match = pattern.match(line.strip())
    if match:
        counts[match.group(1).strip()] = int(match.group(2))
if counts:
    print(", ".join(f"{key}: {value}" for key, value in counts.items()))
else:
    print("summary table present")
PY
)"
  add_check "readiness matrix" "pass" "$READINESS_DETAIL"
else
  add_check "readiness matrix" "skip" "not available outside a full repository checkout"
fi

run_repo_check_if_available "privacy scan" "scripts/check_privacy.sh"
run_repo_check_if_available "forbidden-file scan" "scripts/check_forbidden_files.sh"

DATA_FILE=""
DATA_EXTENSION=""
DATA_SUPPORTED="false"
if [[ -n "$DATA_PATH" ]]; then
  DATA_FILE="$(basename "$DATA_PATH")"
  DATA_EXTENSION=".$(printf '%s' "${DATA_FILE##*.}" | tr '[:upper:]' '[:lower:]')"
  case "$DATA_EXTENSION" in
    .csv|.xls|.xlsx|.mat)
      DATA_SUPPORTED="true"
      add_check "data extension" "pass" "$DATA_EXTENSION is supported"
      ;;
    *)
      DATA_SUPPORTED="false"
      add_check "data extension" "warn" "$DATA_EXTENSION is not supported by the renderer"
      ;;
  esac
else
  add_check "data extension" "skip" "no data file provided"
fi

MATLAB_STATUS="not requested"
MATLAB_DETAIL="not requested"
if [[ "$WITH_MATLAB" -eq 1 ]]; then
  MATLAB_OUTPUT_FILE="$(mktemp)"
  if "$RENDER_SCRIPT" --check >"$MATLAB_OUTPUT_FILE" 2>&1; then
    MATLAB_STATUS="pass"
    MATLAB_DETAIL="$(sed -n '1,3p' "$MATLAB_OUTPUT_FILE" | tr '\n' ' ' | sed 's/[[:space:]]*$//')"
    add_check "MATLAB check" "pass" "MATLAB CLI responded"
  else
    MATLAB_STATUS="fail"
    MATLAB_DETAIL="MATLAB CLI check failed"
    add_check "MATLAB check" "fail" "run render_with_matlab.sh --check for details"
  fi
  rm -f "$MATLAB_OUTPUT_FILE"
else
  add_check "MATLAB check" "skip" "not requested"
fi

MODE="metadata-only"
if [[ "$WITH_MATLAB" -eq 1 ]]; then
  MODE="metadata+matlab"
fi

COMMIT_REF="$(cd "$SKILL_DIR" && git rev-parse --short HEAD 2>/dev/null || printf 'unknown')"
REPORT_MD="$OUT_DIR/first_use_doctor.md"
REPORT_JSON="$OUT_DIR/first_use_doctor.json"

export CHECKS_FILE OVERALL_STATUS MODE COMMIT_REF DATA_FILE DATA_EXTENSION DATA_SUPPORTED MATLAB_STATUS MATLAB_DETAIL
python3 - "$REPORT_MD" "$REPORT_JSON" <<'PY'
import json
import os
import sys

report_md, report_json = sys.argv[1], sys.argv[2]
checks = []
with open(os.environ["CHECKS_FILE"], encoding="utf-8") as handle:
    for line in handle:
        name, status, detail = line.rstrip("\n").split("\t", 2)
        checks.append({"name": name, "status": status, "detail": detail})

data_file = os.environ.get("DATA_FILE", "")
data_extension = os.environ.get("DATA_EXTENSION", "")
data_supported = os.environ.get("DATA_SUPPORTED") == "true"
matlab_status = os.environ.get("MATLAB_STATUS", "not requested")
matlab_detail = os.environ.get("MATLAB_DETAIL", "not requested")

payload = {
    "schema_version": "1.0",
    "tool": "matlab-plotting-skill doctor",
    "mode": os.environ["MODE"],
    "commit": os.environ["COMMIT_REF"],
    "overall_status": os.environ["OVERALL_STATUS"],
    "data": {
        "file": data_file,
        "extension": data_extension,
        "supported": data_supported,
    },
    "matlab": {
        "status": matlab_status,
        "detail": matlab_detail,
    },
    "checks": checks,
}

with open(report_json, "w", encoding="utf-8") as handle:
    json.dump(payload, handle, indent=2)
    handle.write("\n")

with open(report_md, "w", encoding="utf-8") as handle:
    handle.write("# First-use Doctor\n\n")
    handle.write(f"- Mode: {payload['mode']}\n")
    handle.write(f"- Commit: {payload['commit']}\n")
    handle.write(f"- Overall status: {payload['overall_status']}\n")
    if data_file:
        handle.write(f"- Data file: {data_file}\n")
        handle.write(f"- Data extension supported: {'yes' if data_supported else 'no'}\n")
    else:
        handle.write("- Data file: not provided\n")
    handle.write(f"- MATLAB check: {matlab_status}\n\n")
    handle.write("## Checks\n\n")
    for check in checks:
        handle.write(f"- {check['name']}: {check['status']} - {check['detail']}\n")
    handle.write("\nThis diagnostic does not render figures. Use it before --plan-only or a full render.\n")
PY

echo "Wrote first_use_doctor.md: $REPORT_MD"
echo "Wrote first_use_doctor.json: $REPORT_JSON"
