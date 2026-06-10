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

## Current Backlog Signals

The latest local review suggests these public, clean-room additions:

| Area | Candidate schemes |
|---|---|
| Signal processing | `fft_spectrum`, `welch_psd`, `spectrogram`, `coherence_plot`, `group_delay`, `hilbert_envelope` |
| Electrical engineering | `impedance_locus`, `harmonic_spectrum`, `three_phase_waveform`, `voltage_sag`, `thd_bars`, `smith_chart` |
| Model evaluation | `roc_curve`, `precision_recall`, `calibration_curve`, `confusion_matrix`, `residual_plot`, `learning_curve` |
| Distribution comparison | `raincloud`, `violin_split`, `swarm_plot`, `ecdf`, `qq_plot`, `ridgeline` |
| Directional and polar plots | `polar_rose`, `antenna_pattern_polar`, `polar_heatmap`, `compass_plot` |
| 3D views | `surface_3d`, `wireframe_3d`, `isosurface`, `slice_3d`, `quiver_3d` |
| Power and energy | `load_profile`, `power_quality_trend`, `energy_mix_bar`, `converter_efficiency_map` |
| Diagram-like outputs | `workflow_diagram`, `system_block_overview`, `data_flow_panel` |

The rule is the same for every row: new schemes need synthetic data, new MATLAB
code, gallery provenance, and tests. A chart name is allowed to become a task.
A local source file is not.

## Promotion Checklist

Before a private-resource signal becomes a public skill change, write the task
in maintainer language and check every item below:

- the task describes a communication need, not a copied file or screenshot;
- the scheme can be demonstrated with deterministic synthetic data;
- the MATLAB implementation is newly written against the public helpers;
- generated images live in reviewed output or gallery folders, not source
  folders;
- the docs explain when to use the scheme and what can go wrong;
- tests or static checks cover the new command, manifest row, or safety rule.

If any item is missing, keep the idea in the backlog instead of promoting it.

## Private Prototype Library Review

A separate private prototype pass first contained 216 plotting ideas with
Python and MATLAB counterparts, 27 palette families, and a small Origin
automation sketch. A later private index reports a broader 239-template map,
60 palette families, Go-side helper experiments, Origin scripting notes, and
color-science audit material. That is a useful map of user needs, but it is
still private workspace material.

The skill should only use that prototype in three ways:

- backlog grouping, such as electrical, signal, control, RF, ML, CFD,
  optimization, distribution, polar, and 3D;
- prompt and selection vocabulary, such as "I have an impedance curve" or "I
  need a calibration plot";
- quality-policy pressure, such as better palette documentation, stricter
  binary-file checks, clearer Origin interop notes, and better handling of
  generated preview assets from toolchains outside MATLAB.

The skill should not import the prototype functions, gallery images, palette
files, Go helpers, Origin scripts, audit outputs, or local README text. A future
public scheme still needs the normal path: data contract, synthetic demo data,
MATLAB implementation, report text, gallery provenance, and tests.

## Palette And Origin Boundary

Palette work is welcome, but it should be small and reviewable. Add palettes
only when the scheme needs them, document the intended use, and keep color
accessibility notes close to the gallery output.

Origin support is interoperability work, not a reason to publish Origin
workbooks. Public docs may explain how `originpro` or LabTalk could fit into a
workflow, but `.opju`, `.opj`, `.ogwu`, copied workbooks, and local Origin
gallery exports stay out of this repository.

## Agent Rule

If a user asks to open-source local plotting material, first separate:

- safe requirements: chart task, axis relationship, export need, report need;
- unsafe material: source code, copied images, binary files, private paths,
  named authors, license text, watermarks, and personal data.

Only the safe requirements can flow into this skill. Everything else stays
private unless the maintainer can prove authorship and redistribution rights.
