# Private Data Handling

Use bundled fixtures for public examples and issue reports whenever possible.
They are synthetic, small, and safe to share.

## Safe To Share

- Commands that use `examples/data/*.csv`
- MATLAB version and operating system
- Selected scheme name
- Redacted error messages
- `render_report.md` snippets after removing private file names
- Column names when they are generic, such as `time`, `value`, `group`, `x`, or `y`

## Do Not Share

- Raw research, company, school, hospital, finance, or personal datasets
- Private MAT, Excel, CSV, FIG, PDF, DOCX, PPTX, or screenshot files
- Local absolute paths that reveal account names, project names, or private folders
- Email addresses, phone numbers, student IDs, employee IDs, addresses, or credentials
- Copied paper figures or third-party plotting code with unclear provenance

## Good First-Use Report Shape

Prefer this pattern:

```text
MATLAB: R2025a
OS: macOS
Command sequence: --check, --inspect-data, --plan-only, render
Data shape: 120 rows, columns are time/value/group
Goal text: compare methods over time
Selected scheme: multi_line_comparison
Issue: SVG export failed, PNG succeeded
Private details redacted: yes
```

Avoid attaching the original dataset. If a maintainer needs a reproducible
example, create a small synthetic CSV with the same column names and rough value
shape.

## Before Committing Outputs

Run:

```bash
./scripts/check_privacy.sh
./scripts/check_forbidden_files.sh
```

Generated reports should contain file names, not absolute paths. If you see a
private path in output, treat it as a bug and redact it before sharing.
