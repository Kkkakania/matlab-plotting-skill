# Contributing

Thanks for taking a look. This project is small on purpose: a plotting skill
should be easy to inspect, easy to run, and careful with provenance.

## Good First Contributions

- Improve scheme selection rules in `mpSelectScheme.m`.
- Add a renderer branch in `mpRenderScheme.m` for an existing scheme.
- Add a small synthetic example to `mpDemoDataForScheme.m`.
- Tighten README or reference wording when a step is confusing.
- Add a regression test for a broken plot, input type, or CLI path.

## Plotting Scheme Changes

When adding or changing a scheme:

1. Keep the code clean-room. Do not copy private template archives, article
   screenshots, proprietary color packs, or code from another plotting library.
2. Update `skills/matlab-plotting-skill/references/scheme-catalog.md`.
3. Update `mpSchemeCatalog.m`.
4. Add or update synthetic demo data in `mpDemoDataForScheme.m`.
5. Add a test when behavior changes.
6. Run the checks below before opening a pull request.

## Local Checks

```bash
bash -n scripts/*.sh skills/matlab-plotting-skill/scripts/*.sh tests/*.sh
tests/test_install_script.sh
tests/test_check_gallery_outputs.sh
tests/test_list_schemes.sh
tests/test_repo_docs.sh
tests/test_docs_voice.sh
python3 scripts/validate_skill.py
scripts/check_forbidden_files.sh
scripts/check_privacy.sh
scripts/release_check.sh
```

With MATLAB available:

```bash
MATLAB_BIN=/Applications/MATLAB_R2025a.app/bin/matlab ./scripts/render_with_matlab.sh --smoke-test --out figures/smoke --formats png
./scripts/check_gallery_outputs.sh --dir figures/smoke --format png
MATLAB_BIN=/Applications/MATLAB_R2025a.app/bin/matlab ./scripts/run_visual_fixtures.sh
MATLAB_BIN=/Applications/MATLAB_R2025a.app/bin/matlab ./scripts/release_check.sh --with-matlab
```

`run_visual_fixtures.sh` writes to `/tmp/matlab-plotting-skill-visual-fixtures`
by default. Use `--out <directory>` when you intentionally want to keep the
fixture images.

## Documentation Voice

When editing README, walkthrough, or Skill wording, follow
`docs/writing-style.md`. Keep the text practical: say what works today, name the
MATLAB boundary, and avoid claims about adoption or external program approval
unless there is public evidence in the repository.

## Pull Request Notes

Please include:

- What changed.
- Which schemes are affected.
- What checks were run.
- Whether any generated images need manual inspection.
