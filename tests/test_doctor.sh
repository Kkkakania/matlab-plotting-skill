#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT="$ROOT_DIR/scripts/doctor.sh"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

if [[ ! -x "$SCRIPT" ]]; then
  echo "missing executable doctor script: $SCRIPT" >&2
  exit 1
fi

wrapper_nonblank_lines="$(grep -cv '^[[:space:]]*$' "$SCRIPT")"
if [[ "$wrapper_nonblank_lines" -ne 4 ]]; then
  echo "top-level doctor.sh should remain a thin wrapper around the skill-local doctor" >&2
  exit 1
fi
grep -Fxq '#!/usr/bin/env bash' "$SCRIPT"
grep -Fxq 'set -euo pipefail' "$SCRIPT"
grep -Fxq 'exec "$ROOT_DIR/skills/matlab-plotting-skill/scripts/doctor.sh" "$@"' "$SCRIPT"

help_output="$("$SCRIPT" --help)"
grep -q "doctor.sh" <<<"$help_output"
grep -q -- "--with-matlab" <<<"$help_output"
grep -q -- "--data <file>" <<<"$help_output"

OUT_DIR="$TMP_DIR/doctor-output"
"$SCRIPT" --out "$OUT_DIR" --data "$ROOT_DIR/examples/data/time_series.csv" >"$TMP_DIR/stdout.txt"

grep -q "first_use_doctor.md" "$TMP_DIR/stdout.txt"
grep -q "first_use_doctor.json" "$TMP_DIR/stdout.txt"

REPORT_MD="$OUT_DIR/first_use_doctor.md"
REPORT_JSON="$OUT_DIR/first_use_doctor.json"

if [[ ! -s "$REPORT_MD" || ! -s "$REPORT_JSON" ]]; then
  echo "doctor should write Markdown and JSON reports" >&2
  exit 1
fi

grep -q "# First-use Doctor" "$REPORT_MD"
grep -q "metadata-only" "$REPORT_MD"
grep -q "scheme catalog count" "$REPORT_MD"
grep -q "MATLAB check: not requested" "$REPORT_MD"
grep -q "Data file: time_series.csv" "$REPORT_MD"

if grep -q "$ROOT_DIR" "$REPORT_MD" "$REPORT_JSON"; then
  echo "doctor report should not leak the absolute repository path" >&2
  exit 1
fi

python3 - "$REPORT_JSON" <<'PY'
import json
import sys

data = json.load(open(sys.argv[1], encoding="utf-8"))
assert data["schema_version"] == "1.0"
assert data["mode"] == "metadata-only"
assert data["matlab"]["status"] == "not requested"
assert data["data"]["file"] == "time_series.csv"
assert data["data"]["extension"] == ".csv"
assert data["data"]["supported"] is True
checks = {item["name"]: item for item in data["checks"]}
assert checks["scheme catalog count"]["status"] == "pass"
assert checks["readiness matrix"]["status"] == "pass"
assert checks["privacy scan"]["status"] == "pass"
assert checks["forbidden-file scan"]["status"] == "pass"
PY

missing_status=0
"$SCRIPT" --out "$TMP_DIR/missing-out" --data "$TMP_DIR/nope.csv" >/tmp/mp-doctor-missing.out 2>/tmp/mp-doctor-missing.err || missing_status=$?
if [[ "$missing_status" -ne 2 ]]; then
  echo "missing data file should exit 2, got $missing_status" >&2
  cat /tmp/mp-doctor-missing.err >&2
  exit 1
fi

grep -q "Data file not found" /tmp/mp-doctor-missing.err

unsupported="$TMP_DIR/data.unsupported"
printf 'x,y\n1,2\n' >"$unsupported"
"$SCRIPT" --out "$TMP_DIR/unsupported-output" --data "$unsupported" >/dev/null
python3 - "$TMP_DIR/unsupported-output/first_use_doctor.json" <<'PY'
import json
import sys

data = json.load(open(sys.argv[1], encoding="utf-8"))
assert data["data"]["file"] == "data.unsupported"
assert data["data"]["supported"] is False
checks = {item["name"]: item for item in data["checks"]}
assert checks["data extension"]["status"] == "warn"
PY

private_marker="person"
private_marker+="@example.com"
sensitive_data="$TMP_DIR/${private_marker}.csv"
printf 'x,y\n1,2\n' >"$sensitive_data"
"$SCRIPT" --out "$TMP_DIR/sensitive-output" --data "$sensitive_data" >/dev/null
if grep -R "$private_marker" "$TMP_DIR/sensitive-output"; then
  echo "doctor report should redact private markers from data filenames" >&2
  exit 1
fi
python3 - "$TMP_DIR/sensitive-output/first_use_doctor.json" <<'PY'
import json
import sys

data = json.load(open(sys.argv[1], encoding="utf-8"))
assert data["data"]["file"] == "redacted-data-file.csv"
assert data["data"]["extension"] == ".csv"
assert data["data"]["supported"] is True
PY

FAKE_MATLAB="$TMP_DIR/fake-matlab"
cat >"$FAKE_MATLAB" <<'SH'
#!/usr/bin/env bash
echo "R2025a"
exit 0
SH
chmod +x "$FAKE_MATLAB"

MATLAB_BIN="$FAKE_MATLAB" "$SCRIPT" --out "$TMP_DIR/with-matlab-output" --with-matlab >/dev/null
python3 - "$TMP_DIR/with-matlab-output/first_use_doctor.json" <<'PY'
import json
import sys

data = json.load(open(sys.argv[1], encoding="utf-8"))
assert data["mode"] == "metadata+matlab"
assert data["matlab"]["status"] == "pass"
checks = {item["name"]: item for item in data["checks"]}
assert checks["MATLAB check"]["status"] == "pass"
PY

echo "doctor test passed."
