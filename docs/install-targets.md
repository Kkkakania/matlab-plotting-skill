# Install Targets

`matlab-plotting-skill` is a portable skill folder. The repository keeps Codex
as the default because that was the first supported workflow, but the installed
artifact is just:

```text
matlab-plotting-skill/
  SKILL.md
  assets/
  references/
  scripts/
```

That folder can be linked or copied into any agent runtime that can load
`SKILL.md`-style skills.

## Supported Targets

| Target | Command | Resulting location |
|---|---|---|
| Codex | `./scripts/install_skill.sh --target codex` | `${CODEX_HOME:-$HOME/.codex}/skills/matlab-plotting-skill` |
| Claude Code | `./scripts/install_skill.sh --target claude-code` | `${CLAUDE_HOME:-$HOME/.claude}/skills/matlab-plotting-skill` |
| Explicit directory | `./scripts/install_skill.sh --target dir --path ./skills` | `./skills/matlab-plotting-skill` |
| Legacy path form | `./scripts/install_skill.sh --target ./skills` | `./skills/matlab-plotting-skill` |

The default command is still equivalent to the Codex target:

```bash
./scripts/install_skill.sh
```

## Preview Before Installing

Use `--dry-run` to inspect the destination without creating files:

```bash
./scripts/install_skill.sh --target claude-code --dry-run
./scripts/install_skill.sh --target dir --path ./skills --dry-run
```

The preview prints the source folder, final target folder, and whether the
script will create a symlink or a copy.

## Copy Instead Of Symlink

The default install creates a symlink so local edits are reflected immediately.
Use `--copy` when the target runtime should receive an independent copy:

```bash
./scripts/install_skill.sh --target dir --path ./skills --copy
```

## Verification

After installation, verify that the runtime can see `SKILL.md`.

For Codex:

```bash
test -f "${CODEX_HOME:-$HOME/.codex}/skills/matlab-plotting-skill/SKILL.md"
```

For Claude Code:

```bash
test -f "${CLAUDE_HOME:-$HOME/.claude}/skills/matlab-plotting-skill/SKILL.md"
```

For an explicit directory:

```bash
test -f ./skills/matlab-plotting-skill/SKILL.md
```

## Boundaries

The installer only places the skill folder on disk. It does not edit agent
configuration files, install MATLAB, create API keys, or register the skill with
remote services. If an agent runtime needs a plugin manifest or project-level
configuration, keep that setup in the consuming project and point it at the
installed skill folder.
