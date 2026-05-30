#!/usr/bin/env bash
set -euo pipefail

bad=$(find . -type f \( \
  -name '*.p' -o -name '*.fig' -o -name '*.mat' -o -name '*.doc' -o \
  -name '*.docx' -o -name '*.vsd' -o -name '*.pdf' -o -name '*.xlsx' -o \
  -name '*.xls' \) -not -path './.git/*' -print)

if [[ -n "$bad" ]]; then
  echo "Forbidden public files found:" >&2
  echo "$bad" >&2
  exit 1
fi

echo "Forbidden-file check passed."

