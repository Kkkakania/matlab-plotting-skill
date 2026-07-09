#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT="$ROOT_DIR/scripts/check_forbidden_files.sh"

if [[ ! -x "$SCRIPT" ]]; then
  echo "missing executable forbidden-file checker: $SCRIPT" >&2
  exit 1
fi

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

mkdir -p "$tmp_dir/docs" "$tmp_dir/private" "$tmp_dir/.git"
printf '# public note\n' > "$tmp_dir/docs/notes.md"
printf 'ignored git artifact\n' > "$tmp_dir/.git/ignored.mat"

(
  cd "$tmp_dir"
  "$SCRIPT" >/tmp/mp-forbidden-ok.out
)
grep -q "Forbidden-file check passed." /tmp/mp-forbidden-ok.out

printf 'private matlab data\n' > "$tmp_dir/private/source.mat"
if (
  cd "$tmp_dir"
  "$SCRIPT" >/tmp/mp-forbidden-bad.out 2>/tmp/mp-forbidden-bad.err
); then
  echo "expected forbidden-file checker to reject .mat data" >&2
  exit 1
fi

grep -q "Forbidden public files found:" /tmp/mp-forbidden-bad.err
grep -q "./private/source.mat" /tmp/mp-forbidden-bad.err

echo "forbidden-file checker test passed."
