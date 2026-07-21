# Plot Review Contract

This workflow lets Codex compare several rendered MATLAB figures before a
final artifact is selected. The model writes evidence; it never writes or
executes MATLAB code. The finalizer accepts only a small repair allowlist.

## Generate Candidates

```bash
./scripts/render_with_matlab.sh --candidate-pack --candidate-count 3 \
  --data <file> --goal "<communication goal>" --out <directory> \
  --formats png,svg
```

Read `<directory>/candidate_manifest.json`, then inspect every PNG listed in
`candidates`. Review the image together with the manifest's data summary,
scheme name, task, score, and the user's stated goal.

Do not infer uncertainty bounds, categories, units, or causal claims from
column order alone. A candidate with a high rule score can still be
semantically wrong. Prefer the candidate that communicates the supplied data
honestly, even when it is not ranked first.

## Write The Review

Write JSON with exactly these top-level fields:

```json
{
  "schema_version": "1.0",
  "selected_candidate": "candidate-02",
  "verdict": "repair",
  "reviewer": {"surface": "codex", "model": "gpt-5.6-terra"},
  "summary": "Why this candidate best supports the stated goal.",
  "scores": {
    "claim_support": 5,
    "legibility": 4,
    "accessibility": 4,
    "honesty": 5,
    "reproducibility": 5
  },
  "findings": [{
    "code": "short_machine_readable_code",
    "severity": "medium",
    "evidence": "What is visible in the candidate.",
    "recommendation": "What should change."
  }],
  "repair_actions": [{"action": "increase_font_size", "value": 12}]
}
```

Use `accept`, `repair`, or `reject` for `verdict`. Scores are integers from 1
to 5. The supported reviewer models are GPT-5.6 Terra, Sol, and Luna in Codex.
Only claim the model actually used in the current review session.

Allowed repairs:

- `increase_font_size`, with a numeric value from 8 to 24
- `enable_grid`
- `enforce_zero_baseline`
- `high_contrast_palette`
- `legend_best`

Use `enforce_zero_baseline` only when a zero baseline is semantically required,
such as magnitude bars. It is not a general rule for trend plots.

## Validate And Finalize

```bash
./scripts/render_with_matlab.sh \
  --finalize-review <review.json> \
  --candidate-manifest <directory>/candidate_manifest.json \
  --data <file> --goal "<same communication goal>" \
  --out <directory> --formats png,svg
```

The command validates the review before MATLAB starts. It writes
`validated_review.json`, final PNG/SVG files, `before_after.png`, and
`review_evidence.md/json`. Unknown fields, candidates, models, scores, or repair
actions fail closed with exit code 2.

## Build And Verify The Evidence Bundle

After finalization, create one offline review surface and its integrity record:

```bash
python3 scripts/build_review_bundle.py \
  --evidence <directory>/review_evidence.json \
  --candidate-manifest <directory>/candidate_manifest.json \
  --out <directory>/review_report.html \
  --manifest-out <directory>/review_bundle_manifest.json

python3 scripts/verify_review_bundle.py \
  --manifest <directory>/review_bundle_manifest.json \
  --root <directory>
```

`review_report.html` is self-contained HTML: candidate and comparison images
are embedded as data URIs, all review text is HTML-escaped, and no JavaScript or
network resource is required. The manifest hashes the review, candidate
manifest, validated review, candidate images, final exports, and comparison.
Both commands reject absolute paths, traversal outside the evidence directory,
missing files, duplicate manifest entries, and changed bytes.

The bundled review fixture is a deterministic judge demo, not a substitute for
a fresh visual review when the input data or goal changes.
