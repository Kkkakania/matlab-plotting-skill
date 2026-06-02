#!/usr/bin/env bash
set -euo pipefail

bad=$(find . -type f \( \
  -name '*.p' -o -name '*.fig' -o -name '*.mat' -o -name '*.doc' -o \
  -name '*.docx' -o -name '*.vsd' -o -name '*.pdf' -o -name '*.xlsx' -o \
  -name '*.xls' -o -name '*.zip' -o -name '*.rar' -o -name '*.7z' -o \
  -name '.DS_Store' -o -name 'Thumbs.db' -o -name 'desktop.ini' \) \
  -not -path './.git/*' -print)
bad_dirs=$(find . -type d \( \
  -name '__MACOSX' -o -name '.ipynb_checkpoints' -o -name '.pytest_cache' -o \
  -name '__pycache__' \) \
  -not -path './.git/*' -print)

if [[ -n "$bad" || -n "$bad_dirs" ]]; then
  echo "Forbidden public files found:" >&2
  if [[ -n "$bad" ]]; then
    echo "$bad" >&2
  fi
  if [[ -n "$bad_dirs" ]]; then
    echo "$bad_dirs" >&2
  fi
  exit 1
fi

echo "Forbidden-file check passed."
