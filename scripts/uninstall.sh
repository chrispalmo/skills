#!/usr/bin/env bash
# Remove symlinks created by scripts/install.sh (reads skills.manifest).
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MANIFEST="$REPO_ROOT/skills.manifest"

CURSOR_SKILLS="${CURSOR_SKILLS:-$HOME/.cursor/skills}"
CLAUDE_SKILLS="${CLAUDE_SKILLS:-$HOME/.claude/skills}"
AGENTS_SKILLS="${AGENTS_SKILLS:-$HOME/.agents/skills}"

die() { echo "uninstall: error: $*" >&2; exit 1; }
info() { echo "uninstall: $*"; }

usage() {
  cat <<'EOF'
Usage: ./scripts/uninstall.sh [--cursor] [--claude] [--agents] [--all] [-h|--help]

Remove symlinks this repo installed into one or more global skill roots.
Only removes a link when it points at this clone's SKILL.md.

Defaults (no flags): --all — Cursor, Claude Code, and Codex/agents.

  --cursor   ~/.cursor/skills   (or $CURSOR_SKILLS)
  --claude   ~/.claude/skills   (or $CLAUDE_SKILLS)
  --agents   ~/.agents/skills   (or $AGENTS_SKILLS)
  --all      all three (default)
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
  [[ ${#TARGETS[@]} -gt 0 ]] || die "no uninstall targets selected"
}

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

unlink_skill() {
  local line="$1"
  local dest_root="$2"
  local skill_name="${line##*/}"
  local expected="$REPO_ROOT/$line/SKILL.md"
  local dest_dir="$dest_root/$skill_name"
  local dest="$dest_dir/SKILL.md"

  if [[ -L "$dest" ]] && [[ "$(readlink "$dest")" == "$expected" ]]; then
    rm "$dest"
    info "removed $skill_name from $dest_root"
  fi
  rmdir "$dest_dir" 2>/dev/null || true
}

[[ -f "$MANIFEST" ]] || die "missing $MANIFEST"

parse_args "$@"
unique_targets

for dest_root in "${TARGETS[@]}"; do
  info "target $dest_root"
  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line%%#*}"
    line="${line#"${line%%[![:space:]]*}"}"
    line="${line%"${line##*[![:space:]]}"}"
    [[ -z "$line" ]] && continue
    unlink_skill "$line" "$dest_root"
  done < "$MANIFEST"
done

info "done"
