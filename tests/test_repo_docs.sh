#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

required=(
  "CONTRIBUTING.md"
  "SECURITY.md"
  "CODE_OF_CONDUCT.md"
  "CHANGELOG.md"
)

for file in "${required[@]}"; do
  if [[ ! -s "$ROOT_DIR/$file" ]]; then
    echo "missing required repository document: $file" >&2
    exit 1
  fi
done

grep -q "clean-room" "$ROOT_DIR/CONTRIBUTING.md"
grep -q "MATLAB" "$ROOT_DIR/CONTRIBUTING.md"
grep -q "private data" "$ROOT_DIR/SECURITY.md"
grep -q "v0.1.5" "$ROOT_DIR/CHANGELOG.md"
grep -q "Works without MATLAB" "$ROOT_DIR/README.md"
grep -q "Requires MATLAB" "$ROOT_DIR/README.md"
grep -q "Invalid entries fail before MATLAB starts" "$ROOT_DIR/README.md"
grep -q -- "--list-schemes" "$ROOT_DIR/README.md"
grep -q -- "--plan-only" "$ROOT_DIR/README.md"
grep -q "docs/ci-coverage.md" "$ROOT_DIR/README.md"
grep -q "docs/scheme-readiness.md" "$ROOT_DIR/README.md"
grep -q "docs/first-render-walkthrough.md" "$ROOT_DIR/README.md"
grep -q "docs/ecosystem-status.md" "$ROOT_DIR/README.md"
grep -q "docs/maintenance-cadence.md" "$ROOT_DIR/README.md"
grep -q "## Release Status" "$ROOT_DIR/README.md"
grep -q "Early bootstrap tags were intentionally" "$ROOT_DIR/README.md"
grep -q "The catalog contains 50 plotting schemes" "$ROOT_DIR/README.md"
grep -q "gallery-backed schemes as the most stable" "$ROOT_DIR/README.md"
grep -q "Cataloged-only schemes are" "$ROOT_DIR/README.md"
grep -q "long-horizon scheme backlog" "$ROOT_DIR/README.md"
grep -q "without turning every task into a release" "$ROOT_DIR/README.md"
grep -q "first-use feedback issue template" "$ROOT_DIR/README.md"
grep -q "# First Render Walkthrough" "$ROOT_DIR/docs/first-render-walkthrough.md"
grep -q -- "--inspect-data" "$ROOT_DIR/docs/first-render-walkthrough.md"
grep -q -- "--plan-only" "$ROOT_DIR/docs/first-render-walkthrough.md"
grep -q "render_report.md" "$ROOT_DIR/docs/first-render-walkthrough.md"
grep -q "rejects unknown format names before MATLAB starts" "$ROOT_DIR/docs/first-render-walkthrough.md"
grep -q "matlab-plotting-skill/issues/11" "$ROOT_DIR/docs/first-render-walkthrough.md"
grep -q "Redact private paths" "$ROOT_DIR/docs/first-render-walkthrough.md"
grep -q "Copy this template when reporting a first-use result" "$ROOT_DIR/docs/first-render-walkthrough.md"
grep -q "Command sequence:" "$ROOT_DIR/docs/first-render-walkthrough.md"
grep -q "Private details redacted: yes/no" "$ROOT_DIR/docs/first-render-walkthrough.md"
grep -q "The public workflow does not render figures with MATLAB" "$ROOT_DIR/docs/ci-coverage.md"
grep -q "MATLAB release gate" "$ROOT_DIR/docs/ci-coverage.md"
grep -q "# Maintenance Cadence" "$ROOT_DIR/docs/maintenance-cadence.md"
grep -q "## Release History Boundary" "$ROOT_DIR/docs/maintenance-cadence.md"
grep -q "not the normal maintenance rhythm" "$ROOT_DIR/docs/maintenance-cadence.md"
grep -q "Do not tag a release only because one task-board row moved to" "$ROOT_DIR/docs/maintenance-cadence.md"
grep -q "Review new issues and first-use feedback weekly" "$ROOT_DIR/docs/maintenance-cadence.md"
grep -q "# Ecosystem Status" "$ROOT_DIR/docs/ecosystem-status.md"
grep -q "matlab-scientific-figures#9" "$ROOT_DIR/docs/ecosystem-status.md"
grep -q "matlab-figure-ci#1" "$ROOT_DIR/docs/ecosystem-status.md"
grep -q "claim broad adoption" "$ROOT_DIR/docs/ecosystem-status.md"
grep -q "# Scheme Readiness" "$ROOT_DIR/docs/scheme-readiness.md"
grep -q "| gallery-backed | 9 |" "$ROOT_DIR/docs/scheme-readiness.md"

echo "repository docs test passed."
