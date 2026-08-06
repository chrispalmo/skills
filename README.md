# skills

Central repository of Agent Skills (`SKILL.md`) plus an install registry that publishes them to **Cursor**, **Claude Code**, and **OpenAI Codex**.

## Layout

```text
skills/
├── skills.manifest
├── scripts/install.sh
├── scripts/uninstall.sh
├── README.md
├── AGENTS.md
└── skills/
    ├── project-management/
    ├── interview/
    ├── web-design/
    └── writing/
```

## Quick start

```bash
./scripts/install.sh
```

Symlinks every registered skill into the default global roots:

| Agent                              | Default path        |
| ---------------------------------- | ------------------- |
| Cursor                             | `~/.cursor/skills/` |
| Claude Code                        | `~/.claude/skills/` |
| Codex (and Cursor also reads this) | `~/.agents/skills/` |

Keep this clone on disk — installs are symlinks back into the repo.

### Install options

```bash
./scripts/install.sh --cursor   # Cursor only
./scripts/install.sh --claude   # Claude Code only
./scripts/install.sh --agents   # ~/.agents/skills only
./scripts/uninstall.sh          # remove this repo's links from all three
```

Custom locations (skills stored somewhere else):

```bash
CURSOR_SKILLS=/other/skills ./scripts/install.sh --cursor
CLAUDE_SKILLS=/other/skills ./scripts/install.sh --claude
AGENTS_SKILLS=/other/skills ./scripts/install.sh --agents
```

### Windows

Use **WSL** or **Git Bash**. The installer needs a Unix shell and symlink  
support (Developer Mode or equivalent may be required on native Windows).

## Adding a skill domain

```text
skills/<domain>/
├── README.md
├── <skill-name>/SKILL.md
└── references/          # optional shared templates / rubrics
```

1. Add `skills/<domain>/<skill-name>` to `skills.manifest`
2. Update the domain README
3. Run `./scripts/install.sh`
