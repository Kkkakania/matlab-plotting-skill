# Automation Manifest

The repository can generate a machine-readable check matrix for all bundled
plotting schemes:

```bash
python3 scripts/build_automation_manifest.py --out figures/automation-manifest.json
```

The current manifest expands 51 schemes into 1,122 audit checks. Each scheme
gets the same set of catalog, selection, render, report, and safety checks, so
coverage stays balanced as the catalog grows.

The manifest is not a replacement for MATLAB rendering tests. It is a coverage
map that helps maintainers see which checks should exist for each scheme and
which command is responsible for the check.

## Stages

- `catalog`: scheme listing and single-scheme lookup.
- `selection`: explicit scheme selection, plan-only output, and score context.
- `render`: renderer dispatch and PNG/SVG/PDF export paths.
- `report`: Markdown report, JSON report, gallery index, and output names.
- `safety`: privacy, forbidden-file, palette, and accessibility checks.

## Release Gate

`scripts/release_check.sh` runs `tests/test_automation_manifest.sh`. The test
checks that the generated manifest has:

- 51 schemes.
- At least 510 checks.
- Unique check IDs.
- Coverage for every required stage.
- A command hint for every check.
