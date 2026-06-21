#!/usr/bin/env python3
from __future__ import annotations

import pathlib
import re
import sys


ROOT = pathlib.Path(__file__).resolve().parents[1]
SKILL = ROOT / "skills" / "matlab-plotting-skill"
DIAGRAM_SKILL = ROOT / "skills" / "scientific-diagram-skill"


def fail(message: str) -> None:
    print(f"validate_skill: {message}", file=sys.stderr)
    sys.exit(1)


def main() -> None:
    skill_md = SKILL / "SKILL.md"
    if not skill_md.is_file():
        fail("missing SKILL.md")

    text = skill_md.read_text(encoding="utf-8")
    if not text.startswith("---\n"):
        fail("SKILL.md missing YAML frontmatter")
    match = re.match(r"---\n(.*?)\n---\n", text, re.S)
    if not match:
        fail("SKILL.md frontmatter is malformed")
    frontmatter = match.group(1)
    if "name: matlab-plotting-skill" not in frontmatter:
        fail("frontmatter name is wrong")
    if "description:" not in frontmatter or "TODO" in text:
        fail("description missing or TODO remains")

    required = [
        SKILL / "agents" / "openai.yaml",
        SKILL / "scripts" / "render_with_matlab.sh",
        SKILL / "references" / "scheme-catalog.md",
        SKILL / "references" / "data-contract.md",
        SKILL / "references" / "matlab-cli.md",
        SKILL / "references" / "example-prompts.md",
        SKILL / "assets" / "matlab" / "mpRun.m",
        SKILL / "assets" / "matlab" / "mpPlan.m",
        SKILL / "assets" / "matlab" / "mpInspectData.m",
        SKILL / "assets" / "matlab" / "mpSchemeCatalog.m",
        SKILL / "assets" / "matlab" / "mpRenderScheme.m",
    ]
    missing = [str(path.relative_to(ROOT)) for path in required if not path.is_file()]
    if missing:
        fail("missing required files: " + ", ".join(missing))

    catalog = (SKILL / "references" / "scheme-catalog.md").read_text(encoding="utf-8")
    schemes = re.findall(r"\| `([a-z0-9_]+)` \|", catalog)
    if len(schemes) != 51:
        fail(f"expected 51 schemes in catalog, found {len(schemes)}")

    diagram_skill_md = DIAGRAM_SKILL / "SKILL.md"
    if not diagram_skill_md.is_file():
        fail("missing scientific-diagram-skill/SKILL.md")
    diagram_text = diagram_skill_md.read_text(encoding="utf-8")
    if "name: scientific-diagram-skill" not in diagram_text:
        fail("scientific diagram skill frontmatter name is wrong")
    if "draw.io" not in diagram_text or "diagrams.net" not in diagram_text:
        fail("scientific diagram skill must mention draw.io and diagrams.net")
    diagram_required = [
        DIAGRAM_SKILL / "agents" / "openai.yaml",
        DIAGRAM_SKILL / "references" / "drawio-workflow.md",
        DIAGRAM_SKILL / "references" / "diagram-quality-checklist.md",
        DIAGRAM_SKILL / "references" / "export-and-provenance.md",
        DIAGRAM_SKILL / "assets" / "examples" / "research-method-flow.drawio",
        DIAGRAM_SKILL / "assets" / "examples" / "research-method-flow.svg",
        DIAGRAM_SKILL / "assets" / "examples" / "provenance.md",
    ]
    diagram_missing = [
        str(path.relative_to(ROOT)) for path in diagram_required if not path.is_file()
    ]
    if diagram_missing:
        fail("missing required diagram skill files: " + ", ".join(diagram_missing))

    print("Skill validation passed.")


if __name__ == "__main__":
    main()
