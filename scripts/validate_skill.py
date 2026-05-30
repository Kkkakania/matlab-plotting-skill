#!/usr/bin/env python3
from __future__ import annotations

import pathlib
import re
import sys


ROOT = pathlib.Path(__file__).resolve().parents[1]
SKILL = ROOT / "skills" / "matlab-plotting-skill"


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
        SKILL / "assets" / "matlab" / "mpSchemeCatalog.m",
        SKILL / "assets" / "matlab" / "mpRenderScheme.m",
    ]
    missing = [str(path.relative_to(ROOT)) for path in required if not path.is_file()]
    if missing:
        fail("missing required files: " + ", ".join(missing))

    catalog = (SKILL / "references" / "scheme-catalog.md").read_text(encoding="utf-8")
    schemes = re.findall(r"\| `([a-z0-9_]+)` \|", catalog)
    if len(schemes) != 50:
        fail(f"expected 50 schemes in catalog, found {len(schemes)}")

    print("Skill validation passed.")


if __name__ == "__main__":
    main()
