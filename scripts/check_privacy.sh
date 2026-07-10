#!/usr/bin/env bash
set -euo pipefail

patterns='(/Users/wi|/[Uu]sers/|/[Hh]ome/|/[Mm]nt/[A-Za-z]/|[A-Za-z]:\\[Uu]sers\\|%USERPROFILE%[\\/]|/workspaces/|/Volumes/|17 akun|akun|Nature论文|Science论文|Author:|Copyright The MathWorks|GPL|[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}|[0-9]{3}-[0-9]{3}-[0-9]{4})'

if grep -RInE "$patterns" . \
  --exclude-dir=.git \
  --exclude-dir=tests \
  --exclude='.git' \
  --exclude='collect_first_use_feedback.sh' \
  --exclude='check_privacy.sh' \
  --exclude='README.md'; then
  echo "Privacy or provenance-like trace found." >&2
  exit 1
fi

echo "Privacy check passed."
