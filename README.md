# skills

Central repository of Agent Skills (`SKILL.md`) for **Cursor**, **Claude Code**,
and **OpenAI Codex**.

## Layout

```text
skills/
├── skills.manifest        # every installable skill
├── packages.manifest      # members of cross-linked packages
├── scripts/
│   ├── install.sh
│   └── uninstall.sh
└── skills/
    ├── project-management/ # cross-linked package
    ├── interview/          # cross-linked package
    ├── design-tool/        # independent skill
    ├── plaintext/          # independent skill
    └── proofread/          # independent skill
```

Folders that group multiple skills are packages, not categories. Independent skills live directly under `skills/`.

## Install

```bash
./scripts/install.sh
```

This symlinks every registered skill for all three supported agents. Keep the clone on disk because the links point back to it.

| User skill directory | Popular agents that read it | Installer option        |
| -------------------- | --------------------------- | ----------------------- |
| `~/.agents/skills/`  | OpenAI Codex and Cursor     | `--agents` or `--codex` |
| `~/.claude/skills/`  | Claude Code                 | `--claude`              |
| `~/.cursor/skills/`  | Cursor                      | `--cursor`              |

The default `--all` writes to `~/.agents/skills` and `~/.claude/skills`. Cursor already reads `~/.agents/skills`, so writing the same skills to `~/.cursor/skills` as well would expose duplicates.

### Install options

```bash
./scripts/install.sh --all
./scripts/install.sh --cursor
./scripts/install.sh --claude
./scripts/install.sh --agents
./scripts/install.sh --package project-management
./scripts/install.sh --package interview --cursor
```

Installation is intentionally either **all skills** or a complete
**cross-linked package**. Arbitrary single-skill installation is not supported: it would make package dependencies unclear and turn the installer into a dependency resolver.

Uninstall uses the same target and package options:

```bash
./scripts/uninstall.sh
./scripts/uninstall.sh --package interview --cursor
```

Custom roots:

```bash
CURSOR_SKILLS=/other/skills ./scripts/install.sh --cursor
CLAUDE_SKILLS=/other/skills ./scripts/install.sh --claude
AGENTS_SKILLS=/other/skills ./scripts/install.sh --agents
```

### Existing and built-in skills

The installer preflights the whole operation before creating links. It is idempotent for links already created from this clone, but aborts on an existing directory or foreign symlink instead of overwriting another skill.

Bundled skills are managed separately and are never modified. Name collisions can still be ambiguous: Claude Code user skills override bundled skills with the same name, while Codex can show user and system skills side by side. Cursor's duplicate-name precedence is not documented.

### Windows

Use **WSL** or **Git Bash**. The installer requires a Unix shell and symlink support; native Windows may require Developer Mode.

## Adding skills and packages

- Add every skill path to `skills.manifest`.
- Put an independent skill at `skills/<skill-name>/SKILL.md`.
- Use `skills/<package>/` only for cross-linked skills and shared references.
- Add every package member to `packages.manifest` and maintain its package
  README.
