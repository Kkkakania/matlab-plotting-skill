#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

FAKE_MATLAB="$TMP_DIR/matlab"
cat > "$FAKE_MATLAB" <<'FAKE'
#!/usr/bin/env bash
if [[ "$1" != "-batch" ]]; then
  echo "expected -batch as first argument" >&2
  exit 4
fi
echo "fake MATLAB R2025a"
FAKE
chmod +x "$FAKE_MATLAB"

output="$(MATLAB_BIN="$FAKE_MATLAB" "$ROOT_DIR/scripts/render_with_matlab.sh" --check)"

if [[ "$output" != *"MATLAB CLI check passed"* ]]; then
  echo "check output should report success" >&2
  exit 1
fi

if [[ "$output" != *"fake MATLAB R2025a"* ]]; then
  echo "check output should include MATLAB command output" >&2
  exit 1
fi

echo "MATLAB check test passed."
