#!/usr/bin/env bash
# Link skills from skills.manifest into global skill directories for
# Cursor, Claude Code, and OpenAI Codex (agents).
# Additive — does not remove or overwrite other skills already there.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MANIFEST="$REPO_ROOT/skills.manifest"

CURSOR_SKILLS="${CURSOR_SKILLS:-$HOME/.cursor/skills}"
CLAUDE_SKILLS="${CLAUDE_SKILLS:-$HOME/.claude/skills}"
AGENTS_SKILLS="${AGENTS_SKILLS:-$HOME/.agents/skills}"

die() { echo "install: error: $*" >&2; exit 1; }
info() { echo "install: $*"; }

usage() {
  cat <<'EOF'
Usage: ./scripts/install.sh [--cursor] [--claude] [--agents] [--all] [-h|--help]

Link every skill in skills.manifest into one or more global skill roots.

Defaults (no flags): --all — Cursor, Claude Code, and Codex/agents.

  --cursor   ~/.cursor/skills   (or $CURSOR_SKILLS)
  --claude   ~/.claude/skills   (or $CLAUDE_SKILLS)
  --agents   ~/.agents/skills   (or $AGENTS_SKILLS)
  --all      all three (default)

Overrides: set CURSOR_SKILLS, CLAUDE_SKILLS, and/or AGENTS_SKILLS to use
custom destinations (e.g. skills stored outside the default home paths).
EOF
}

TARGETS=()
parse_args() {
  if [[ $# -eq 0 ]]; then
    TARGETS=("$CURSOR_SKILLS" "$CLAUDE_SKILLS" "$AGENTS_SKILLS")
    return
  fi
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --cursor) TARGETS+=("$CURSOR_SKILLS") ;;
      --claude) TARGETS+=("$CLAUDE_SKILLS") ;;
      --agents) TARGETS+=("$AGENTS_SKILLS") ;;
      --all)
        TARGETS=("$CURSOR_SKILLS" "$CLAUDE_SKILLS" "$AGENTS_SKILLS")
        shift
        return
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        die "unknown option: $1 (try --help)"
        ;;
    esac
    shift
  done
  [[ ${#TARGETS[@]} -gt 0 ]] || die "no install targets selected"
}

# Deduplicate while preserving order
unique_targets() {
  local -a out=()
  local t u seen
  for t in "${TARGETS[@]}"; do
    seen=0
    for u in "${out[@]+"${out[@]}"}"; do
      [[ "$u" == "$t" ]] && { seen=1; break; }
    done
    [[ $seen -eq 0 ]] && out+=("$t")
  done
  TARGETS=("${out[@]}")
}

link_skill() {
  local line="$1"
  local dest_root="$2"
  local skill_name="${line##*/}"
  local src="$REPO_ROOT/$line/SKILL.md"
  local dest_dir="$dest_root/$skill_name"
  local dest="$dest_dir/SKILL.md"

  [[ -f "$src" ]] || die "missing $src (check skills.manifest)"

  mkdir -p "$dest_dir"

  if [[ -e "$dest" && ! -L "$dest" ]]; then
    die "$dest is a regular file — move it aside first"
  fi

  ln -sf "$src" "$dest"
  info "linked $skill_name -> $dest"
}

read_manifest_into() {
  local dest_root="$1"
  info "target $dest_root"
  mkdir -p "$dest_root"
  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line%%#*}"
    line="${line#"${line%%[![:space:]]*}"}"
    line="${line%"${line##*[![:space:]]}"}"
    [[ -z "$line" ]] && continue
    link_skill "$line" "$dest_root"
  done < "$MANIFEST"
}

[[ -f "$MANIFEST" ]] || die "missing $MANIFEST"

parse_args "$@"
unique_targets

for dest_root in "${TARGETS[@]}"; do
  read_manifest_into "$dest_root"
done

info "done (${#TARGETS[@]} target(s))"
