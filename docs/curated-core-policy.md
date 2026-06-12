# Curated Core Policy

`matlab-plotting-skill` is not a full template archive. Its job is to help an
agent choose and render a reliable MATLAB figure from user data, then explain
that choice in a report.

The public skill should stay small enough to audit. A scheme only belongs here
when it improves the data-to-figure workflow, not merely because a similar plot
exists in a private folder or a larger reference library.

## What Belongs Here

A scheme can be promoted into the skill when it has:

- a clear data contract that can be checked before MATLAB rendering starts;
- deterministic synthetic examples that do not come from private data;
- a bundled MATLAB renderer using public helper code;
- PNG/SVG export behavior that works through the CLI;
- a Markdown and JSON report explaining the selected scheme and alternatives;
- gallery provenance and privacy checks;
- first-use documentation that tells users when the scheme is appropriate.

The first priority is the stable first-use set: trend, comparison,
uncertainty, relationship, matrix, and common bar/area views. Specialized
schemes should be added only when they solve a recurring user task and can pass
the same reporting and safety standards.

## What Stays Out

Do not publish:

- private plotting folders or course-resource collections;
- copied MATLAB helper functions, author-marked code, watermarked examples, or
  journal screenshots;
- binary or closed files such as `.fig`, `.mat`, `.p`, `.mltbx`, `.opju`, or
  `.opj`;
- large gallery dumps whose schemes cannot be selected, explained, and checked
  by the agent workflow;
- palettes or examples copied from third-party projects without a clear license
  review.

Large reference libraries can still be useful. They can inform taxonomy,
palette vocabulary, test ideas, and backlog grouping. They should not become
bulk source material for this skill.

## Promotion Rule

Use this decision rule before adding a new scheme:

```text
Can the agent inspect user data, choose this scheme, render it, and explain the
choice without exposing private material?
```

If the answer is no, keep the idea in the backlog.

If the answer is yes, add the scheme in this order:

1. data contract
2. selection signals
3. MATLAB renderer
4. synthetic fixture
5. gallery preview
6. report fields
7. release check coverage
8. first-use documentation

This keeps the repository useful without turning it into an unreviewable
resource dump.
