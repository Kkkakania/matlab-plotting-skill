# MATLAB CLI Notes

The skill renders figures through MATLAB batch mode.

```bash
MATLAB_BIN=/Applications/MATLAB_R2025a.app/bin/matlab \
  skills/matlab-plotting-skill/scripts/render_with_matlab.sh \
  --data examples/data/time_series.csv \
  --goal "show a time trend" \
  --out figures \
  --formats png,svg
```

Use a specific scheme when the user already knows the chart type:

```bash
MATLAB_BIN=/Applications/MATLAB_R2025a.app/bin/matlab \
  skills/matlab-plotting-skill/scripts/render_with_matlab.sh \
  --data examples/data/method_scores.csv \
  --scheme grouped_bar \
  --out figures
```

If `MATLAB_BIN` is not set, the script tries `matlab` on `PATH`.

Use `--explain` when you want to inspect why a scheme was selected without
rendering a figure. It still requires MATLAB because data loading, schema
inference, and scoring run in the bundled MATLAB code.

Use `--scheme-info <name> --status` or `--scheme-info-json <name> --status`
when you need readiness for one scheme without scanning the full matrix.

Common failures:

| Symptom | Cause | Fix |
|---|---|---|
| `MATLAB executable not found` | MATLAB is not on `PATH` | Set `MATLAB_BIN` to the full executable path |
| `Unsupported data file` | File extension is not CSV/XLS/XLSX/MAT | Convert data or write a local adapter |
| `MAT file is ambiguous` | Several variables could be plotted | Ask the user to name one variable |
| Empty output directory | MATLAB failed before export | Inspect command output and `render_report.md` |
| SVG export fails | Older MATLAB or renderer issue | Render PNG/PDF first, then retry SVG |
