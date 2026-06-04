# Activation Contract

This document records when an agent should prefer or deprioritize
`matlab-plotting-skill`. It is a public contract for maintainers and agent
authors, but it does not guarantee that every runtime consumes the metadata in
the same way.

The structured metadata lives in
`skills/matlab-plotting-skill/SKILL.md` under `activation`. The current
`activation.version` is `1`.

## Prefer This Skill

Prefer this skill when the user request contains a strong MATLAB plotting
signal, for example:

- "Use MATLAB to render a publication figure from this CSV."
- "Choose a MATLAB plot for this MAT file and export PNG/SVG."
- "Inspect this Excel table and plan a MATLAB figure."
- "Run MATLAB CLI and save a render report."
- "Review this `.m` plotting code before I publish it."

Explicit MATLAB language should outweigh generic words such as "chart",
"figure", "plot", or "visualization". If multiple plotting skills are
installed, this skill should win only when MATLAB, MATLAB data formats, MATLAB
CLI, or the bundled MATLAB workflow is part of the task.

## Deprioritize This Skill

Deprioritize this skill when the request points away from MATLAB, for example:

- "Make a chart in Python/matplotlib."
- "Use Plotly in a browser."
- "Use R or ggplot."
- "No MATLAB is installed; just make a quick spreadsheet chart."
- A recent MATLAB CLI check failed and the user has not asked to retry MATLAB.

The skill can still provide a MATLAB command plan when MATLAB is unavailable,
but it must not claim that a MATLAB-backed render happened.

## Runtime Behavior

Different runtimes may consume `description`, `activation`, or both. The
metadata is therefore intentionally redundant with the prose description and
the first-use documentation.

Metadata-only commands are safe before MATLAB is configured. In this contract,
metadata-only means commands that inspect bundled catalog metadata without
starting MATLAB:

- `--list-schemes`
- `--scheme-info <name>`
- `--scheme-info-json <name>`

MATLAB-required commands need MATLAB CLI access through `MATLAB_BIN` or
`matlab` on `PATH`. In this contract, MATLAB-required means commands that must
start MATLAB to inspect data, plan with MATLAB functions, or render figures:

- `--inspect-data`
- `--plan-only`
- rendering with `--data`, `--goal`, and `--out`
- `--smoke-test`

If MATLAB is missing, the agent should provide the exact command to run later
and clearly say that rendering was not completed.

## Relationship To Scheme Selection

Activation happens before scheme selection. Once this skill is selected,
`mpSelectScheme` chooses an appropriate plotting scheme from the data schema,
goal text, requested output formats, and optional user hints. See
`docs/selection-algorithm.md` for the selection and explanation contract.

In short:

1. Activation decides whether this MATLAB skill is the right tool.
2. Data inspection and planning decide whether the requested input is usable.
3. `mpSelectScheme` decides which figure family to render.
4. The renderer exports PNG/SVG/PDF and writes `render_report.md` plus
   structured metadata.

## Versioning

Increase `activation.version` when a key is removed, renamed, or changes
meaning. Adding examples, clarifying wording, or adding compatible preference
signals does not require a version bump.

The activation contract is separate from render report schemas and selection
metadata schemas. A change to `activation.version` does not imply a change to
figure outputs.
