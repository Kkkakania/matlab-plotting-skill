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
- [x] [Build Week PR #42](https://github.com/Kkkakania/matlab-plotting-skill/pull/42)
  merged into `main` before the final video was recorded.

## Devpost

- [x] Joined the challenge and created the submission.
- [x] Chose the final project name in the maintainer's own words.
- [x] Edited and saved the project description in the maintainer's own voice.
- [x] Added the public GitHub repository URL.
- [x] Added exact macOS/MATLAB R2025a testing instructions and the demo command.
- [x] Retrieved the `/feedback` Codex Session ID from the primary build thread
  where the candidate-review implementation was created.
- [x] Confirmed the Devpost residence and eligibility fields are accurate.
- [x] Submitted before the deadline, reopened the public project page, and
  verified its repository, release, video, and test-path links.

## Video

- [x] Recorded the flow in `docs/build-week-video-script.md` at 1080p.
- [x] Kept the public YouTube video below three minutes.
- [x] Included clear audio naming both Codex and GPT-5.6.
- [x] Showed live candidate generation, not only committed screenshots.
- [x] Showed the semantic rejection of the confidence-band candidate.
- [x] Showed `validated_review.json`, the repair allowlist, and final evidence.
- [x] Removed desktop notifications, private paths, email addresses, and API
  keys from the recording.

## Final Verification

Verified on July 21, 2026, while submission edits were still open:

- Devpost status: submitted and publicly accessible as
  [PlotProof for MATLAB](https://devpost.com/software/plotproof-for-matlab).
- Demo video: [public YouTube upload](https://youtu.be/7w3rR0AiON8), 1080p,
  2 minutes 28 seconds, with voiceover and captions.
- Release: immutable
  [`build-week-2026.1`](https://github.com/Kkkakania/matlab-plotting-skill/releases/tag/build-week-2026.1)
  source archive and documented judge path.
- Repository: public, MIT licensed, and green on the latest `main` quality run.
- Codex evidence: the primary build thread's `/feedback` Session ID is entered
  in the private Devpost judging field; it is intentionally not repeated here.

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
