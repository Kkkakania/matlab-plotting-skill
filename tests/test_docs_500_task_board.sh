#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BOARD="$ROOT_DIR/docs/500-task-board.md"

if [[ ! -s "$BOARD" ]]; then
  echo "missing committed 500-task board" >&2
  exit 1
fi

task_count="$(grep -Ec '^\| `TASK-[0-9]{3}-' "$BOARD")"
if [[ "$task_count" -ne 500 ]]; then
  echo "expected 500 committed task rows, found $task_count" >&2
  exit 1
fi

grep -q "Total tasks: 500" "$BOARD"
grep -q "TASK-001-line_trend-catalog" "$BOARD"
grep -q "TASK-500-annotated_callout-safety" "$BOARD"
grep -q "Command Hint" "$BOARD"
grep -q "| done | 18 |" "$BOARD"
grep -q '| `TASK-001-line_trend-catalog` | `line_trend` | catalog | Clarify catalog entry | Catalog entry names the scheme, family, best use, and palette. | `./scripts/render_with_matlab.sh --scheme-info line_trend` | done |' "$BOARD"
grep -q '| `TASK-002-line_trend-data-contract` | `line_trend` | data-contract | Document input shape | Data expectations are clear enough to choose the scheme without private examples. | `grep -n "line_trend" skills/matlab-plotting-skill/references/scheme-catalog.md docs/chart-selection-guide.md` | done |' "$BOARD"
grep -q '| `TASK-003-line_trend-demo-data` | `line_trend` | demo-data | Provide synthetic demo data | Synthetic data can exercise the scheme with no private files. | `MATLAB_BIN=/path/to/matlab ./scripts/render_with_matlab.sh --smoke-test --formats png` | done |' "$BOARD"
grep -q '| `TASK-004-line_trend-selection-rule` | `line_trend` | selection-rule | Route suitable data to the scheme | Plan-only output can explain when this scheme is selected or considered. | `./scripts/render_with_matlab.sh --plan-only --data <file> --goal <goal> --scheme line_trend` | done |' "$BOARD"
grep -q '| `TASK-005-line_trend-explicit-cli` | `line_trend` | explicit-cli | Support explicit CLI selection | The scheme can be requested with --scheme and receives a deterministic report. | `./scripts/render_with_matlab.sh --data <file> --goal <goal> --scheme line_trend --formats png` | done |' "$BOARD"
grep -q '| `TASK-006-line_trend-png-render` | `line_trend` | png-render | Render PNG output | PNG output is generated and non-empty for the scheme. | `./scripts/render_with_matlab.sh --data <file> --goal <goal> --scheme line_trend --formats png` | done |' "$BOARD"
grep -q '| `TASK-007-line_trend-vector-render` | `line_trend` | vector-render | Render vector output | SVG or PDF output is generated for paper/report workflows. | `./scripts/render_with_matlab.sh --data <file> --goal <goal> --scheme line_trend --formats svg,pdf` | done |' "$BOARD"
grep -q '| `TASK-008-line_trend-report` | `line_trend` | report | Explain output in reports | Markdown and JSON reports name the scheme and explain selection context. | `grep -R "line_trend" <output-dir>/render_report.md <output-dir>/render_report.json` | done |' "$BOARD"
grep -q '| `TASK-009-line_trend-gallery` | `line_trend` | gallery | Represent scheme in gallery | Gallery generation can include the rendered output and catalog metadata. | `python3 scripts/build_gallery_index.py --dir <render-dir> --catalog skills/matlab-plotting-skill/references/scheme-catalog.md --out <index.md>` | done |' "$BOARD"
grep -q '| `TASK-010-line_trend-safety` | `line_trend` | safety | Pass privacy and provenance checks | No private paths, forbidden files, or provenance-unclear assets are introduced. | `./scripts/check_privacy.sh && ./scripts/check_forbidden_files.sh` | done |' "$BOARD"
grep -q '| `TASK-011-multi_line_comparison-catalog` | `multi_line_comparison` | catalog | Clarify catalog entry | Catalog entry names the scheme, family, best use, and palette. | `./scripts/render_with_matlab.sh --scheme-info multi_line_comparison` | done |' "$BOARD"
grep -q '| `TASK-012-multi_line_comparison-data-contract` | `multi_line_comparison` | data-contract | Document input shape | Data expectations are clear enough to choose the scheme without private examples. | `grep -n "multi_line_comparison" skills/matlab-plotting-skill/references/scheme-catalog.md docs/chart-selection-guide.md` | done |' "$BOARD"
grep -q '| `TASK-013-multi_line_comparison-demo-data` | `multi_line_comparison` | demo-data | Provide synthetic demo data | Synthetic data can exercise the scheme with no private files. | `MATLAB_BIN=/path/to/matlab ./scripts/render_with_matlab.sh --smoke-test --formats png` | done |' "$BOARD"
grep -q '| `TASK-014-multi_line_comparison-selection-rule` | `multi_line_comparison` | selection-rule | Route suitable data to the scheme | Plan-only output can explain when this scheme is selected or considered. | `./scripts/render_with_matlab.sh --plan-only --data <file> --goal <goal> --scheme multi_line_comparison` | done |' "$BOARD"
grep -q '| `TASK-015-multi_line_comparison-explicit-cli` | `multi_line_comparison` | explicit-cli | Support explicit CLI selection | The scheme can be requested with --scheme and receives a deterministic report. | `./scripts/render_with_matlab.sh --data <file> --goal <goal> --scheme multi_line_comparison --formats png` | done |' "$BOARD"
grep -q '| `TASK-016-multi_line_comparison-png-render` | `multi_line_comparison` | png-render | Render PNG output | PNG output is generated and non-empty for the scheme. | `./scripts/render_with_matlab.sh --data <file> --goal <goal> --scheme multi_line_comparison --formats png` | done |' "$BOARD"
grep -q '| `TASK-017-multi_line_comparison-vector-render` | `multi_line_comparison` | vector-render | Render vector output | SVG or PDF output is generated for paper/report workflows. | `./scripts/render_with_matlab.sh --data <file> --goal <goal> --scheme multi_line_comparison --formats svg,pdf` | done |' "$BOARD"
grep -q '| `TASK-018-multi_line_comparison-report` | `multi_line_comparison` | report | Explain output in reports | Markdown and JSON reports name the scheme and explain selection context. | `grep -R "multi_line_comparison" <output-dir>/render_report.md <output-dir>/render_report.json` | done |' "$BOARD"
grep -q "Catalog entry names the scheme" "$BOARD"
grep -q "No private paths, forbidden files" "$BOARD"

echo "committed 500-task board test passed."
