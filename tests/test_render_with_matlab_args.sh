#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT="$ROOT_DIR/scripts/render_with_matlab.sh"
INNER_SCRIPT="$ROOT_DIR/skills/matlab-plotting-skill/scripts/render_with_matlab.sh"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

wrapper_nonblank_lines="$(grep -cv '^[[:space:]]*$' "$SCRIPT")"
if [[ "$wrapper_nonblank_lines" -ne 4 ]]; then
  echo "top-level render_with_matlab.sh should remain a thin wrapper around the skill script" >&2
  exit 1
fi
grep -Fxq '#!/usr/bin/env bash' "$SCRIPT"
grep -Fxq 'set -euo pipefail' "$SCRIPT"
grep -Fxq 'exec "$ROOT_DIR/skills/matlab-plotting-skill/scripts/render_with_matlab.sh" "$@"' "$SCRIPT"
grep -q -- "--doctor --out <dir>" "$INNER_SCRIPT"
grep -q -- "--explain --data <file> --goal" "$INNER_SCRIPT"
grep -q -- "ElapsedSeconds" "$ROOT_DIR/skills/matlab-plotting-skill/assets/matlab/mpSmokeTest.m"

if [[ ! -x "$INNER_SCRIPT" ]]; then
  echo "inner render_with_matlab.sh is not executable" >&2
  exit 1
fi

check_missing_value() {
  local option="$1"
  local out_file="$TMP_DIR/${option#--}.out"
  local err_file="$TMP_DIR/${option#--}.err"
  local status

  set +e
  "$SCRIPT" "$option" >"$out_file" 2>"$err_file"
  status=$?
  set -e

  if [[ "$status" -eq 0 ]]; then
    echo "expected $option without a value to fail" >&2
    exit 1
  fi

  if [[ "$status" -ne 2 ]]; then
    echo "expected $option without a value to exit 2, got $status" >&2
    cat "$err_file" >&2
    exit 1
  fi

  if ! grep -q -- "$option requires a value" "$err_file"; then
    echo "expected clear missing-value message for $option" >&2
    cat "$err_file" >&2
    exit 1
  fi
}

check_missing_value --data
check_missing_value --goal
check_missing_value --out
check_missing_value --formats
check_missing_value --scheme
check_missing_value --var
check_missing_value --scheme-info
check_missing_value --scheme-info-json

check_bad_formats() {
  local formats="$1"
  local expected="$2"
  local out_file="$TMP_DIR/formats.out"
  local err_file="$TMP_DIR/formats.err"
  local status

  set +e
  "$SCRIPT" --list-schemes --formats "$formats" >"$out_file" 2>"$err_file"
  status=$?
  set -e

  if [[ "$status" -ne 2 ]]; then
    echo "expected --formats '$formats' to exit 2, got $status" >&2
    cat "$err_file" >&2
    exit 1
  fi

  if ! grep -q -- "$expected" "$err_file"; then
    echo "expected clear format validation message for '$formats'" >&2
    cat "$err_file" >&2
    exit 1
  fi
}

check_bad_formats "png,jpg" "Invalid --formats entry: jpg"
check_bad_formats "," "--formats must include at least one"

check_empty_out_dir() {
  local out_file="$TMP_DIR/outdir.out"
  local err_file="$TMP_DIR/outdir.err"
  local status

  set +e
  "$SCRIPT" --list-schemes --out "" >"$out_file" 2>"$err_file"
  status=$?
  set -e

  if [[ "$status" -ne 2 ]]; then
    echo "expected empty --out to exit 2, got $status" >&2
    cat "$err_file" >&2
    exit 1
  fi

  if ! grep -q -- "--out must not be empty" "$err_file"; then
    echo "expected clear empty --out validation message" >&2
    cat "$err_file" >&2
    exit 1
  fi
}

check_empty_out_dir

check_control_char_out_dir() {
  local out_file="$TMP_DIR/outdir-control.out"
  local err_file="$TMP_DIR/outdir-control.err"
  local status

  set +e
  "$SCRIPT" --list-schemes --out $'bad\npath' >"$out_file" 2>"$err_file"
  status=$?
  set -e

  if [[ "$status" -ne 2 ]]; then
    echo "expected control-character --out to exit 2, got $status" >&2
    cat "$err_file" >&2
    exit 1
  fi

  if ! grep -q -- "--out may not contain control characters" "$err_file"; then
    echo "expected clear control-character --out validation message" >&2
    cat "$err_file" >&2
    exit 1
  fi
}

check_control_char_out_dir

set +e
"$SCRIPT" --doctor >"$TMP_DIR/doctor-missing-out.out" 2>"$TMP_DIR/doctor-missing-out.err"
doctor_missing_out_status=$?
set -e

if [[ "$doctor_missing_out_status" -ne 2 ]]; then
  echo "expected --doctor without explicit --out to exit 2, got $doctor_missing_out_status" >&2
  cat "$TMP_DIR/doctor-missing-out.err" >&2
  exit 1
fi

if ! grep -q -- "--doctor requires --out <dir>" "$TMP_DIR/doctor-missing-out.err"; then
  echo "expected clear --doctor missing --out message" >&2
  cat "$TMP_DIR/doctor-missing-out.err" >&2
  exit 1
fi

"$SCRIPT" --doctor --out "$TMP_DIR/doctor" >"$TMP_DIR/doctor.out"
grep -q "first_use_doctor.md" "$TMP_DIR/doctor.out"
grep -q "first_use_doctor.json" "$TMP_DIR/doctor.out"

if [[ ! -s "$TMP_DIR/doctor/first_use_doctor.md" || ! -s "$TMP_DIR/doctor/first_use_doctor.json" ]]; then
  echo "--doctor should write first-use diagnostic reports" >&2
  exit 1
fi

grep -q "metadata-only" "$TMP_DIR/doctor/first_use_doctor.md"
if grep -q "$ROOT_DIR" "$TMP_DIR/doctor/first_use_doctor.md" "$TMP_DIR/doctor/first_use_doctor.json"; then
  echo "--doctor reports should not leak the absolute repository path" >&2
  exit 1
fi

check_missing_required_data_before_matlab() {
  local out_file="$TMP_DIR/missing-data.out"
  local err_file="$TMP_DIR/missing-data.err"
  local status

  set +e
  env MATLAB_BIN=/no/such/matlab "$SCRIPT" --plan-only --goal "show trend" >"$out_file" 2>"$err_file"
  status=$?
  set -e

  if [[ "$status" -ne 2 ]]; then
    echo "expected missing --data to exit 2 before MATLAB lookup, got $status" >&2
    cat "$err_file" >&2
    exit 1
  fi

  if ! grep -q -- "--data is required" "$err_file"; then
    echo "expected clear missing --data validation message" >&2
    cat "$err_file" >&2
    exit 1
  fi
}

check_missing_required_data_before_matlab

FAKE_MATLAB="$TMP_DIR/fake_matlab"
cat >"$FAKE_MATLAB" <<'SH'
#!/usr/bin/env bash
exit 0
SH
chmod +x "$FAKE_MATLAB"

set +e
env MP_MATLAB_TIMEOUT_SECONDS=bad MATLAB_BIN="$FAKE_MATLAB" "$SCRIPT" --check >"$TMP_DIR/timeout.out" 2>"$TMP_DIR/timeout.err"
timeout_status=$?
set -e

if [[ "$timeout_status" -ne 2 ]]; then
  echo "expected invalid timeout to exit 2, got $timeout_status" >&2
  cat "$TMP_DIR/timeout.err" >&2
  exit 1
fi

if ! grep -q -- "Invalid timeout seconds" "$TMP_DIR/timeout.err"; then
  echo "expected clear invalid timeout message" >&2
  cat "$TMP_DIR/timeout.err" >&2
  exit 1
fi

ZERO_TIMEOUT_FAKE="$TMP_DIR/fake_zero_timeout_matlab"
cat >"$ZERO_TIMEOUT_FAKE" <<'SH'
#!/usr/bin/env bash
sleep 0.1
exit 0
SH
chmod +x "$ZERO_TIMEOUT_FAKE"

set +e
env MP_MATLAB_TIMEOUT_SECONDS=0.0 MATLAB_BIN="$ZERO_TIMEOUT_FAKE" "$SCRIPT" --check >"$TMP_DIR/zero-timeout.out" 2>"$TMP_DIR/zero-timeout.err"
zero_timeout_status=$?
set -e

if [[ "$zero_timeout_status" -ne 0 ]]; then
  echo "expected MP_MATLAB_TIMEOUT_SECONDS=0.0 to disable the timeout guard, got $zero_timeout_status" >&2
  cat "$TMP_DIR/zero-timeout.err" >&2
  exit 1
fi

if ! grep -q -- "MATLAB CLI check passed" "$TMP_DIR/zero-timeout.out"; then
  echo "expected successful MATLAB check output when decimal zero disables timeout" >&2
  cat "$TMP_DIR/zero-timeout.out" >&2
  exit 1
fi

DATA_FILE="$TMP_DIR/data.csv"
printf 'x,y\n1,2\n' >"$DATA_FILE"

set +e
env MATLAB_BIN="$FAKE_MATLAB" "$SCRIPT" --plan-only --data "$DATA_FILE" >"$TMP_DIR/missing-goal.out" 2>"$TMP_DIR/missing-goal.err"
missing_goal_status=$?
set -e

if [[ "$missing_goal_status" -ne 2 ]]; then
  echo "expected missing --goal to exit 2, got $missing_goal_status" >&2
  cat "$TMP_DIR/missing-goal.err" >&2
  exit 1
fi

if ! grep -q -- "--goal is required" "$TMP_DIR/missing-goal.err"; then
  echo "expected clear missing --goal validation message" >&2
  cat "$TMP_DIR/missing-goal.err" >&2
  exit 1
fi

(cd "$TMP_DIR" && env MATLAB_BIN="$FAKE_MATLAB" "$SCRIPT" --plan-only --data "$DATA_FILE" --goal "show trend" >/dev/null)
if [[ -d "$TMP_DIR/figures" ]]; then
  echo "expected --plan-only not to create the default figures directory" >&2
  exit 1
fi

(cd "$TMP_DIR" && env MATLAB_BIN="$FAKE_MATLAB" "$SCRIPT" --inspect-data --data "$DATA_FILE" >/dev/null)
if [[ -d "$TMP_DIR/figures" ]]; then
  echo "expected --inspect-data not to create the default figures directory" >&2
  exit 1
fi

SMOKE_FAKE="$TMP_DIR/fake_smoke_matlab"
cat >"$SMOKE_FAKE" <<'SH'
#!/usr/bin/env bash
echo "$*" >"${MP_FAKE_MATLAB_ARGS_FILE:?}"
exit 0
SH
chmod +x "$SMOKE_FAKE"

MP_FAKE_MATLAB_ARGS_FILE="$TMP_DIR/smoke.args" env MATLAB_BIN="$SMOKE_FAKE" MP_MATLAB_TIMEOUT_SECONDS=10 "$SCRIPT" --smoke-test --out "$TMP_DIR/smoke" --formats png >"$TMP_DIR/smoke.out"
if ! grep -q -- "Smoke test:" "$TMP_DIR/smoke.out"; then
  echo "smoke-test should report the applied timeout budget" >&2
  cat "$TMP_DIR/smoke.out" >&2
  exit 1
fi
if ! grep -q -- "budget 2355s" "$TMP_DIR/smoke.out"; then
  echo "smoke-test should auto-scale timeout from scheme count" >&2
  cat "$TMP_DIR/smoke.out" >&2
  exit 1
fi

MP_FAKE_MATLAB_ARGS_FILE="$TMP_DIR/smoke-no-guard.args" env MATLAB_BIN="$SMOKE_FAKE" MP_MATLAB_TIMEOUT_SECONDS=0 "$SCRIPT" --smoke-test --out "$TMP_DIR/smoke-no-guard" --formats png >"$TMP_DIR/smoke-no-guard.out"
if ! grep -q -- "timeout guard disabled" "$TMP_DIR/smoke-no-guard.out"; then
  echo "smoke-test should preserve MP_MATLAB_TIMEOUT_SECONDS=0 as disabled guard" >&2
  cat "$TMP_DIR/smoke-no-guard.out" >&2
  exit 1
fi

echo "render_with_matlab argument test passed."
