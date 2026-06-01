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

DATA_FILE="$TMP_DIR/data.csv"
printf 'x,y\n1,2\n' >"$DATA_FILE"

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

echo "render_with_matlab argument test passed."
