# skills

> Moved: this repository is archived in favor of
> [chrispalmo/agent-config](https://github.com/chrispalmo/agent-config).
> Agent skills now live under `agent-config/skills/`; use that repo's root
> installer for skills and rules.

Central repository of Agent Skills (`SKILL.md`) for **Cursor**, **Claude Code**,
and **OpenAI Codex**.

## Layout

```text
skills/
├── skills.manifest          # every installable skill
├── packages.manifest        # members of cross-linked packages
├── bundled-skills.manifest  # vendor reserved names (best-effort)
├── scripts/
│   ├── install.sh
│   ├── uninstall.sh
│   └── test-install.sh
└── skills/
    ├── project-management/ # cross-linked package
    ├── interview/          # cross-linked package
    ├── design-tool/        # independent skill
    ├── github-init/        # independent skill
    ├── pause-for-review/   # independent skill
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

The default `--all` writes to `~/.agents/skills` and `~/.claude/skills`. Cursor already reads `~/.agents/skills`, so the default does not write to `~/.cursor/skills`. `--cursor` is an opt-in if you want Cursor's native root instead.

### Install options

```bash
./scripts/install.sh --all
./scripts/install.sh --cursor
./scripts/install.sh --claude
./scripts/install.sh --agents
./scripts/install.sh --package project-management
./scripts/install.sh --package interview --cursor
./scripts/test-install.sh
```

`test-install.sh` uses temporary roots and does not write to home skill directories.

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

The installer backfills the chosen targets. Links already created from this clone are left as-is, or relinked if they still point into this clone at an old path. It aborts if a destination folder already exists and is not a symlink into this clone, and never overwrites that folder.

If a skill name matches a vendor bundled or system skill, install still links and exits `2`:

- `"ingest" skill will override Claude Code's bundled /ingest`
- `"loop" skill may hide or share /loop with Cursor's built-in`
- `"plan" skill may appear alongside Codex's system /plan`

Claude names come from `bundled-skills.manifest` (best-effort; refresh from Claude Code docs monthly). Cursor also scans `~/.cursor/skills-cursor`. Codex also scans `$CODEX_HOME/skills/.system` and `/etc/codex/skills`. Exit `0` means no overlap. Exit `1` is a hard failure.

Uninstall removes a destination only when `SKILL.md` is a symlink into this clone. Name matches alone are not enough. If an older install left this repo's links in `~/.cursor/skills`, remove them with `./scripts/uninstall.sh --cursor`.

### Cloud agents

This repository is archived. Use
[chrispalmo/agent-config](https://github.com/chrispalmo/agent-config) for cloud
agent setup. Its `scripts/cloud/README.md` contains the environment stub for
Cursor, Claude Code, and Codex.

### Windows

Use **WSL** or **Git Bash**. The installer requires a Unix shell and symlink support; native Windows may require Developer Mode.

## Adding skills and packages

- All new and changed skills, references, scripts, manifests, and documentation must support Cursor, Claude Code, and OpenAI Codex. Keep shared behavior vendor-neutral; explicitly scope unavoidable vendor-specific behavior and provide equivalent instructions for the other supported agents where applicable.
- Add every skill path to `skills.manifest`.
- Put an independent skill at `skills/<skill-name>/SKILL.md`.
- Use `skills/<package>/` only for cross-linked skills and shared references.
- Add every package member to `packages.manifest` and maintain its package
  README.
