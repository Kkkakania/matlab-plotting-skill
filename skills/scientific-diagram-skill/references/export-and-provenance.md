# Export And Provenance

Use this when a diagram will be committed, published, or attached to a release.

## Repository Layout

Recommended layout:

```text
docs/diagrams/
  method-flow.drawio
  method-flow.svg
  method-flow.png
  provenance.md
```

Commit `.drawio` when the source is clean and useful for later edits. Commit SVG
for documentation. Commit PNG only when GitHub rendering or social preview needs
it.

## What To Avoid

- full slide decks
- screenshots used as source material
- copied paper figures
- private logos, email addresses, student ids, local paths, or hidden watermarks
- binary source bundles that cannot be reviewed in a diff

## Provenance Note

For public repositories, add a short note:

```markdown
# Diagram Provenance

- Source: clean-room diagram created for this repository.
- Inputs: public method description and synthetic labels.
- Private data: none.
- Exports: SVG and PNG generated from the committed `.drawio` source.
```

Run `mfigci` or the repository's privacy/provenance checks before publishing:

```bash
mfigci check --config mfigci.yml --report mfigci-report.md
```

The check does not prove copyright ownership. It helps catch private traces,
risky extensions, and obvious provenance markers before the diagram reaches a
public repository.
