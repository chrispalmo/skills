# Agent guide — skills

Central repository of Agent Skills (`SKILL.md`) and the install registry that
publishes them to Cursor, Claude Code, and OpenAI Codex.

## Startup checklist

1. Read `README.md` for layout and install
2. Read this file for operating procedures
3. Skill source: `skills/<domain>/<skill-name>/SKILL.md`
4. Domain overview: `skills/<domain>/README.md`
5. Shared templates/rubrics (when present): `skills/<domain>/references/`

## Documentation authority

| Question | Source of truth |
| -------- | --------------- |
| What skills exist? | `skills.manifest` + domain READMEs |
| Skill instructions | `skills/<domain>/<skill>/SKILL.md` |
| Templates and rubrics | `skills/<domain>/references/` |
| Why was X decided? | `skills/<domain>/references/decisions.md` (when present) |

## Adding or removing a skill

1. Create or remove `skills/<domain>/<skill-name>/SKILL.md`
2. Add or remove the path line in **`skills.manifest`**
3. Update `skills/<domain>/README.md`
4. Run `./scripts/install.sh` (or `./scripts/uninstall.sh` if removing)

Do not edit skill lists inside `scripts/` — the manifest is the single registry.

## Installing skills

```bash
./scripts/install.sh            # Cursor + Claude Code + Codex/agents
./scripts/install.sh --cursor   # ~/.cursor/skills only
./scripts/install.sh --claude   # ~/.claude/skills only
./scripts/install.sh --agents   # ~/.agents/skills only
```

Symlinks each registered `SKILL.md` into the chosen global skill root(s).
Source of truth remains this clone. Custom destinations:

```bash
CURSOR_SKILLS=/path/to/skills ./scripts/install.sh --cursor
CLAUDE_SKILLS=/path/to/skills ./scripts/install.sh --claude
AGENTS_SKILLS=/path/to/skills ./scripts/install.sh --agents
```

## Session workflow

- Prefer changes under `skills/`, `skills.manifest`, `scripts/`, and root docs
- Register every shippable skill in `skills.manifest`
- New domains go under `skills/<domain>/` with a domain `README.md`
- Keep skill bodies portable: resolve references relative to this repo
  (e.g. `skills/<domain>/references/...`), not machine-specific home paths

## Safety

- No client secrets in skills or references
- Do not push to unrelated repositories
- Do not update git config
