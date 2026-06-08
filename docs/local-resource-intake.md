# Local Resource Intake

This skill can be used near private plotting folders, old course material, and
personal MATLAB examples, but those resources are only requirements signals.
They are not part of the public repository.

## Boundary

When a local resource suggests a useful plotting workflow, convert it into a
clean-room task:

1. Name the communication goal, such as trend comparison, spectral view,
   matrix overview, relationship plot, or publication panel.
2. Map the goal to an existing scheme or create a backlog candidate.
3. Generate synthetic data from scratch.
4. Implement with the bundled MATLAB helpers and documented data contract.
5. Add gallery provenance, safety checks, and report fields before publishing.

Do not copy code, comments, screenshots, data files, article images, private
paths, watermarks, or original labels from the local source.

## High-Risk Inputs

These inputs are useful as warnings for maintainers, not as material to publish:

| Input | Handling |
|---|---|
| Nature/Science figure collections or paper screenshots | Do not copy, trace, or use as gallery assets |
| MATLAB binary or closed files (`.mat`, `.fig`, `.p`, `.mltbx`) | Do not publish; treat as a reason to keep binary scans strict |
| Origin projects and add-ons (`.opju`, `.opj`, `.ogwu`, `.opx`) | Do not publish; treat as private/binary source material |
| Office files, archives, OCR batches, and copied tutorials | Keep out of the public skill repository |
| Third-party palettes, helper functions, or author-marked scripts | Require clear license review; otherwise do not use |

## Accepted Signals

Local resource review may influence the backlog at the task level. For example:

- add or improve signal-processing schemes such as FFT, Welch PSD, Bode/Nyquist,
  spectrogram, and step-response plots;
- add electrical-engineering demos only with deterministic synthetic data;
- improve `matlab-figure-ci` rules for Origin and MATLAB binary artifacts;
- improve first-use prompts that help users choose schemes without exposing
  private datasets.

These are maintenance signals, not usage claims or evidence of adoption.

## Agent Rule

If a user asks to open-source local plotting material, first separate:

- safe requirements: chart task, axis relationship, export need, report need;
- unsafe material: source code, copied images, binary files, private paths,
  named authors, license text, watermarks, and personal data.

Only the safe requirements can flow into this skill. Everything else stays
private unless the maintainer can prove authorship and redistribution rights.
