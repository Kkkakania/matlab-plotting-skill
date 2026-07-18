# Three-Minute Demo Script

Target length: 2:45-2:55. Record in English at 1080p. Keep the terminal font
large and use the bundled synthetic dataset.

## 0:00-0:15 - Show The Result

Screen: open `docs/build-week/before_after.png`.

Voiceover:

> Scientific plotting tools usually optimize for making a chart. This tool
> optimizes for catching the wrong chart before it reaches a paper. Here the
> highest-ranked option was semantically misleading; GPT-5.6 caught it,
> selected the honest alternative, and produced review evidence.

## 0:15-0:35 - State The User And Problem

Screen: briefly show the synthetic CSV headers `time`, `baseline`, and
`candidate`.

> Researchers and engineers often have many plausible MATLAB visualizations,
> but a visually polished chart can still assign the wrong meaning to columns.
> A confidence band is not valid when two columns are two methods rather than
> lower and upper uncertainty bounds.

## 0:35-1:10 - Generate Real Candidates

Screen: run the candidate command, then open the three generated PNGs.

```bash
MATLAB_BIN=/Applications/MATLAB_R2025a.app/bin/matlab \
  ./scripts/render_with_matlab.sh --candidate-pack --candidate-count 3 \
  --data examples/data/multi_series.csv \
  --goal "Compare the baseline and candidate methods over time and make uncertainty or overlap easy to inspect without inventing error bounds" \
  --out /tmp/matlab-plot-review-demo --formats png,svg
```

> The existing MATLAB engine reads the data and renders three ranked
> candidates. The manifest records their schemes, scores, and relative output
> paths without exposing the user's local path.

## 1:10-1:45 - Show GPT-5.6 Reasoning

Screen: candidate 01, candidate 02, candidate 03, then the checked review JSON.

> Candidate one scores highest because the goal mentions uncertainty, but it
> silently reinterprets baseline and candidate as interval bounds. Candidate
> three loses the series identities. GPT-5.6 Sol in Codex selects candidate
> two and records evidence across claim support, legibility, accessibility,
> honesty, and reproducibility.

## 1:45-2:20 - Validate And Repair

Screen: run finalization, then show `review_evidence.md`.

```bash
MATLAB_BIN=/Applications/MATLAB_R2025a.app/bin/matlab \
  ./scripts/render_with_matlab.sh \
  --finalize-review examples/review/multi_series_review.json \
  --candidate-manifest /tmp/matlab-plot-review-demo/candidate_manifest.json \
  --data examples/data/multi_series.csv \
  --goal "Compare the baseline and candidate methods over time and make uncertainty or overlap easy to inspect without inventing error bounds" \
  --out /tmp/matlab-plot-review-demo --formats png,svg
```

> Before MATLAB starts, a strict validator checks the candidate, model,
> five scores, findings, and repair actions. Unknown actions fail closed. The
> model never supplies executable MATLAB code. Only five controlled figure
> repairs are available.

## 2:20-2:45 - Prove Reproducibility

Screen: show final PNG/SVG, `before_after.png`, and `review_evidence.json`, then
the green test summary.

> The result includes publication-ready raster and vector files, a before and
> after comparison, and machine-readable evidence. The full release gate runs
> real MATLAB tests, visual fixtures, privacy checks, and contract tests.

## 2:45-2:55 - Close

Screen: final comparison image.

> This is not AI that draws one more chart. It is a Codex-native review loop
> that makes scientific visualization choices inspectable, repairable, and
> reproducible.
