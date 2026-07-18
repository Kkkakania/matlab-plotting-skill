# Build Week Submission Checklist

Deadline: July 21, 2026 at 5:00 PM Pacific Time. Submit early enough to recover
from a YouTube upload or Devpost form failure.

## Project

- [x] Developer Tools track selected.
- [x] Public MIT-licensed repository available.
- [x] Pre-event and Build Week work separated in `docs/build-week-2026.md`.
- [x] Synthetic demo data contains no private research material.
- [x] One-command MATLAB demo works from a clean output directory.
- [x] Installation and supported platform information remains in the README.
- [x] Default and MATLAB-backed release gates pass.
- [x] Merge [Build Week PR #42](https://github.com/Kkkakania/matlab-plotting-skill/pull/42)
  into `main` before recording the final video.

## Devpost

- [ ] Join the challenge and start a draft submission now.
- [ ] Choose a final project name in the maintainer's own words.
- [ ] Write the project description in the maintainer's own voice. Use the
  factual points below, but do not paste AI-authored prose unchanged.
- [ ] Add the public GitHub repository URL.
- [ ] Add exact macOS/MATLAB R2025a testing instructions and the demo command.
- [ ] Retrieve the `/feedback` Codex Session ID from the primary build thread
  where the candidate-review implementation was created.
- [ ] Confirm the Devpost residence and eligibility fields are accurate.
- [ ] Submit before the deadline, then reopen the project page and verify every
  link while edits are still allowed.

## Video

- [ ] Record the flow in `docs/build-week-video-script.md` at 1080p.
- [ ] Keep the public YouTube video below three minutes.
- [ ] Include clear audio naming both Codex and GPT-5.6.
- [ ] Show live candidate generation, not only committed screenshots.
- [ ] Show the semantic rejection of the confidence-band candidate.
- [ ] Show `validated_review.json`, the repair allowlist, and final evidence.
- [ ] Remove desktop notifications, private paths, email addresses, and API
  keys from the recording.

## Factual Description Notes

- Audience: researchers, engineers, students, and technical authors using
  MATLAB for decision-facing figures.
- Gap: rule-based chart ranking can select a visually plausible but
  semantically invalid encoding.
- New mechanism: render alternatives, review every image with GPT-5.6 in Codex,
  validate the review, apply controlled repairs, and export evidence.
- Safety: no model-authored MATLAB is executed; repairs use a five-action
  allowlist; private local archives are excluded.
- Demonstrated result: the rule-ranked confidence band is rejected because the
  columns represent methods, then a labeled multi-line comparison is repaired.
- Reproducibility: bundled synthetic CSV, real MATLAB CLI execution, PNG/SVG,
  before/after comparison, Markdown/JSON evidence, and automated tests.
