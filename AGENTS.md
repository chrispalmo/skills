# Agent guide — skills

Central repository of Agent Skills (`SKILL.md`) and the install registry that
publishes them to Cursor, Claude Code, and OpenAI Codex.

## Startup checklist

1. Read `README.md` for layout and install
2. Read this file for operating procedures
3. Independent skill: `skills/<skill-name>/SKILL.md`
4. Package skill: `skills/<package>/<skill-name>/SKILL.md`
5. Package overview and shared files: `skills/<package>/README.md` and
   `skills/<package>/references/`

## Documentation authority

| Question | Source of truth |
| -------- | --------------- |
| What skills exist? | `skills.manifest` |
| What skills form a package? | `packages.manifest` + package README |
| Skill instructions | each skill's `SKILL.md` |
| Templates and rubrics | `skills/<package>/references/` |

## Adding or removing a skill

1. Create or remove the skill directory under `skills/`
2. Add or remove its path in **`skills.manifest`**
3. If it belongs to a cross-linked group, keep **`packages.manifest`** in sync
4. Update the package README when applicable
5. Run `./scripts/install.sh` (or `./scripts/uninstall.sh` if removing)

Do not edit skill lists inside `scripts/` — the manifests are the registry.
Nested grouping folders under `skills/` are package roots, never categories;
independent skills are top-level `skills/<name>/`. Single-skill install is not
supported.

## Installing skills

```bash
./scripts/install.sh            # all → agents + claude
./scripts/install.sh --package project-management
./scripts/install.sh --cursor   # Cursor native root only
./scripts/install.sh --agents
./scripts/install.sh --claude   # ~/.claude/skills only
```

Default targets are `~/.agents/skills` (Cursor + Codex) and `~/.claude/skills`
(Claude Code). Do not combine `--cursor` and `--agents`. Symlinks point back at
this clone.

```bash
CURSOR_SKILLS=/path/to/skills ./scripts/install.sh --cursor
CLAUDE_SKILLS=/path/to/skills ./scripts/install.sh --claude
AGENTS_SKILLS=/path/to/skills ./scripts/install.sh --agents
```

## Session workflow

- Prefer changes under `skills/`, the manifests, `scripts/`, and root docs
- Register every shippable skill in `skills.manifest`
- Register cross-linked groups in `packages.manifest`
- Keep package skill bodies resolving shared files via this repo
  (e.g. `skills/<package>/references/...`), not home paths

## Safety

- No client secrets in skills or references
- Do not push to unrelated repositories
- Do not update git config
- Installer must abort on foreign clashes; never overwrite existing skills
