#!/usr/bin/env bash
set -euo pipefail

OUT_DIR=""
DOCTOR_DIR=""
COMMAND_TEXT=""
MATLAB_VERSION=""
OS_NAME=""
COMMIT_REF=""
GOAL_TEXT=""
DATA_SHAPE=""

usage() {
  cat <<'USAGE'
Usage:
  collect_first_use_feedback.sh --out <render-output-dir> [options]

Options:
  --command <text>  Command sequence to include in the draft.
  --doctor <dir>    Directory containing first_use_doctor.md/json.
  --matlab <text>   MATLAB version or launch detail.
  --os <text>       Operating system.
  --commit <text>   Commit or branch tested.
  --goal <text>     Goal text passed to --goal.
  --data-shape <text>
                    Redacted data-shape summary, such as rows/columns/role hints.

Creates a redacted Markdown draft that can be pasted into issue #11.
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
    --command)
      require_value "$1" "${2:-}"
      COMMAND_TEXT="$2"
      shift 2
      ;;
    --doctor)
      require_value "$1" "${2:-}"
      DOCTOR_DIR="$2"
      shift 2
      ;;
    --matlab)
      require_value "$1" "${2:-}"
      MATLAB_VERSION="$2"
      shift 2
      ;;
    --os)
      require_value "$1" "${2:-}"
      OS_NAME="$2"
      shift 2
      ;;
    --commit)
      require_value "$1" "${2:-}"
      COMMIT_REF="$2"
      shift 2
      ;;
    --goal)
      require_value "$1" "${2:-}"
      GOAL_TEXT="$2"
      shift 2
      ;;
    --data-shape)
      require_value "$1" "${2:-}"
      DATA_SHAPE="$2"
      shift 2
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      if [[ -z "$OUT_DIR" && "$1" != --* ]]; then
        OUT_DIR="$1"
        shift
      else
        echo "Unknown argument: $1" >&2
        usage >&2
        exit 2
      fi
      ;;
  esac
done

if [[ -z "$OUT_DIR" ]]; then
  echo "--out is required." >&2
  usage >&2
  exit 2
fi

if [[ ! -d "$OUT_DIR" ]]; then
  echo "Output directory not found: $OUT_DIR" >&2
  exit 2
fi

REPORT_MD="$OUT_DIR/render_report.md"
REPORT_JSON="$OUT_DIR/render_report.json"
DOCTOR_SUMMARY="not provided"

if [[ ! -f "$REPORT_MD" && ! -f "$REPORT_JSON" ]]; then
  echo "Expected render_report.md or render_report.json in: $OUT_DIR" >&2
  exit 2
fi

if [[ -n "$DOCTOR_DIR" ]]; then
  if [[ ! -d "$DOCTOR_DIR" ]]; then
    echo "Doctor output directory not found: $DOCTOR_DIR" >&2
    exit 2
  fi
  DOCTOR_MD="$DOCTOR_DIR/first_use_doctor.md"
  DOCTOR_JSON="$DOCTOR_DIR/first_use_doctor.json"
  if [[ ! -f "$DOCTOR_MD" && ! -f "$DOCTOR_JSON" ]]; then
    echo "Expected first_use_doctor.md or first_use_doctor.json in: $DOCTOR_DIR" >&2
    exit 2
  fi
fi

redact() {
  python3 -c 'import re, sys
text = sys.stdin.read()
patterns = [
    r"C:\\" + "Users" + r"\\[^;\n\r`\"'\'')]+?matlab\.exe",
    r"C:\\" + "Users" + r"\\[^;\n\r`\"'\'')]+?\.(?:csv|xlsx|xls|mat|json|md|txt|png|svg|pdf|fig|m)",
    r"/" + "Users" + r"/[^;\n\r`\"'\'')]+?\.(?:csv|xlsx|xls|mat|json|md|txt|png|svg|pdf|fig|m)",
    r"/" + "home" + r"/[^;\n\r`\"'\'')]+?\.(?:csv|xlsx|xls|mat|json|md|txt|png|svg|pdf|fig|m)",
    r"/" + "Users" + r"/[^\s\"'\'')]+",
    r"/" + "home" + r"/[^\s\"'\'')]+",
    r"C:\\" + "Users" + r"\\[^\s\"'\'')]+",
    r"[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}",
]
for pattern in patterns:
    text = re.sub(pattern, "<redacted-path>", text)
print(text, end="")'
}

extract_json_field() {
  local field="$1"
  if [[ ! -f "$REPORT_JSON" ]]; then
    return 0
  fi
  python3 - "$REPORT_JSON" "$field" <<'PY'
import json
import sys

path, field = sys.argv[1], sys.argv[2]
try:
    data = json.loads(open(path, encoding="utf-8").read())
except Exception:
    sys.exit(0)

def as_text(value):
    if value is None:
        return ""
    if isinstance(value, list):
        return ", ".join(str(item) for item in value)
    return str(value)

if field == "selected":
    print(as_text(data.get("selectedScheme") or data.get("scheme") or data.get("selected_scheme")))
elif field == "formats":
    print(as_text(data.get("outputFormats") or data.get("formats") or data.get("output_formats")))
elif field == "alternatives":
    explanation = data.get("selectionExplanation") or data.get("selection_explanation") or {}
    print(as_text(explanation.get("topAlternatives") or explanation.get("top_alternatives") or data.get("topAlternatives")))
PY
}

extract_markdown_value() {
  local label="$1"
  if [[ ! -f "$REPORT_MD" ]]; then
    return 0
  fi
  grep -Ei "^[*-]?[[:space:]]*$label:" "$REPORT_MD" | head -n 1 | sed -E "s/^[*-]?[[:space:]]*$label:[[:space:]]*//I"
}

extract_doctor_summary() {
  if [[ -z "$DOCTOR_DIR" ]]; then
    printf 'not provided\n'
    return 0
  fi

  if [[ -f "$DOCTOR_JSON" ]]; then
    python3 - "$DOCTOR_JSON" <<'PY'
import json
import sys

try:
    data = json.loads(open(sys.argv[1], encoding="utf-8").read())
except Exception:
    sys.exit(0)

overall = data.get("overall_status") or "unknown"
mode = data.get("mode") or "unknown"
print(f"Overall status: {overall}")
print(f"Mode: {mode}")

checks = [
    item for item in data.get("checks", [])
    if item.get("status") in {"warn", "fail"}
]
if checks:
    print("Failed or warn checks:")
    for item in checks:
        name = item.get("name", "unknown check")
        status = item.get("status", "unknown")
        detail = item.get("detail", "")
        if detail:
            print(f"- {name}: {status} - {detail}")
        else:
            print(f"- {name}: {status}")
else:
    print("Failed or warn checks: none")
PY
    return 0
  fi

  if [[ -f "$DOCTOR_MD" ]]; then
    sed -n '1,60p' "$DOCTOR_MD"
  fi
}

SELECTED_SCHEME="$(extract_json_field selected)"
TOP_ALTERNATIVES="$(extract_json_field alternatives)"
OUTPUT_FORMATS="$(extract_json_field formats)"

if [[ -z "$SELECTED_SCHEME" ]]; then
  SELECTED_SCHEME="$(extract_markdown_value "Selected scheme")"
fi
if [[ -z "$TOP_ALTERNATIVES" ]]; then
  TOP_ALTERNATIVES="$(extract_markdown_value "Top alternatives")"
fi
if [[ -z "$OUTPUT_FORMATS" ]]; then
  OUTPUT_FORMATS="$(extract_markdown_value "Output formats")"
fi

REPORT_SUMMARY=""
if [[ -f "$REPORT_MD" ]]; then
  REPORT_SUMMARY="$(sed -n '1,40p' "$REPORT_MD")"
fi
DOCTOR_SUMMARY="$(extract_doctor_summary)"

cat <<REPORT | redact
# First-use feedback draft

OS: ${OS_NAME:-unknown}
MATLAB: ${MATLAB_VERSION:-unknown}
Commit: ${COMMIT_REF:-unknown}
Command sequence:
\`\`\`bash
${COMMAND_TEXT:-not provided}
\`\`\`
Goal text: ${GOAL_TEXT:-not provided}
Data shape: ${DATA_SHAPE:-not provided}
Selected scheme: ${SELECTED_SCHEME:-unknown}
Top alternatives: ${TOP_ALTERNATIVES:-unknown}
Output formats: ${OUTPUT_FORMATS:-unknown}

first_use_doctor.md/json summary:
\`\`\`text
${DOCTOR_SUMMARY:-not available}
\`\`\`

render_report.md summary:
\`\`\`text
${REPORT_SUMMARY:-not available}
\`\`\`

Expected result:

Actual result:

Private details redacted: yes
REPORT
