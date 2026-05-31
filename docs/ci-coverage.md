# CI Coverage

The public GitHub Actions workflow is designed to be useful on standard hosted
Linux runners without a MATLAB license. It checks the parts of the project that
can be verified everywhere, then leaves real rendering to the release gate that
runs on a machine with MATLAB installed.

## Public GitHub Actions

The `Quality` workflow checks:

- shell and Python syntax
- repository document requirements
- clean-room, forbidden-file, and privacy scans
- scheme catalog, task manifest, and gallery metadata consistency
- argument parsing and failure messages for the MATLAB wrapper
- a fake `MATLAB_BIN` shim for `--check`, so command construction is exercised

The public workflow does not render figures with MATLAB. A green public check
means the skill package, docs, manifests, and wrapper behavior are consistent.
It is not a substitute for inspecting real MATLAB output.

## MATLAB Release Gate

Before tagging a release that changes rendering behavior, run:

```bash
MATLAB_BIN=/Applications/MATLAB_R2025a.app/bin/matlab ./scripts/release_check.sh --with-matlab
```

That path adds:

- MATLAB unit tests
- MATLAB Code Analyzer checks
- representative visual fixture rendering
- gallery output checks for generated figures

Use the public workflow for fast review. Use the MATLAB release gate when the
change affects plotting, data loading, export behavior, or visual output.
