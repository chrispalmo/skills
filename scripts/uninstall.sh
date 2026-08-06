#!/usr/bin/env bash
# Remove links created by install.sh for all skills or one complete package.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_MANIFEST="$REPO_ROOT/skills.manifest"
PACKAGES_MANIFEST="$REPO_ROOT/packages.manifest"

CURSOR_SKILLS="${CURSOR_SKILLS:-$HOME/.cursor/skills}"
CLAUDE_SKILLS="${CLAUDE_SKILLS:-$HOME/.claude/skills}"
AGENTS_SKILLS="${AGENTS_SKILLS:-$HOME/.agents/skills}"

die() { echo "uninstall: error: $*" >&2; exit 1; }
info() { echo "uninstall: $*"; }

usage() {
  cat <<'EOF'
Usage: ./scripts/uninstall.sh [--all|--cursor|--claude|--agents]
                              [--package <name>] [-h|--help]

Remove this clone's links for all skills (default), or one complete package.

  --all       ~/.agents/skills + ~/.claude/skills (default)
  --cursor    ~/.cursor/skills
  --claude    ~/.claude/skills
  --agents    ~/.agents/skills
  --codex     alias for --agents
  --package   uninstall only a package listed in packages.manifest
EOF
}

TARGETS=()
SKILLS=()
PACKAGE=""
TARGET_FLAGS=0
ALL_TARGETS=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --all) ALL_TARGETS=1 ;;
    --cursor)
      TARGETS+=("$CURSOR_SKILLS")
      TARGET_FLAGS=$((TARGET_FLAGS + 1))
      ;;
    --claude)
      TARGETS+=("$CLAUDE_SKILLS")
      TARGET_FLAGS=$((TARGET_FLAGS + 1))
      ;;
    --agents|--codex)
      TARGETS+=("$AGENTS_SKILLS")
      TARGET_FLAGS=$((TARGET_FLAGS + 1))
      ;;
    --package)
      shift
      [[ $# -gt 0 ]] || die "--package requires a name"
      [[ -z "$PACKAGE" ]] || die "--package may be specified only once"
      PACKAGE="$1"
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *) die "unknown option: $1 (try --help)" ;;
  esac
  shift
done

[[ -f "$SKILLS_MANIFEST" ]] || die "missing $SKILLS_MANIFEST"
[[ -f "$PACKAGES_MANIFEST" ]] || die "missing $PACKAGES_MANIFEST"
[[ $ALL_TARGETS -eq 0 || $TARGET_FLAGS -eq 0 ]] ||
  die "--all cannot be combined with an agent target"

if [[ $ALL_TARGETS -eq 1 || $TARGET_FLAGS -eq 0 ]]; then
  TARGETS=("$AGENTS_SKILLS" "$CLAUDE_SKILLS")
fi

package_contains() {
  local wanted_path="$1"
  local name path extra
  while read -r name path extra || [[ -n "${name:-}" ]]; do
    [[ -z "${name:-}" || "$name" == \#* ]] && continue
    [[ "$name" == "$PACKAGE" && "$path" == "$wanted_path" ]] && return 0
  done < "$PACKAGES_MANIFEST"
  return 1
}

if [[ -n "$PACKAGE" ]]; then
  [[ "$PACKAGE" =~ ^[a-z0-9-]+$ ]] || die "invalid package name: $PACKAGE"
  if ! awk -v package="$PACKAGE" '$1 == package { found=1 } END { exit !found }' \
    "$PACKAGES_MANIFEST"; then
    die "unknown package: $PACKAGE"
  fi
fi

while IFS= read -r line || [[ -n "$line" ]]; do
  line="${line%%#*}"
  line="${line#"${line%%[![:space:]]*}"}"
  line="${line%"${line##*[![:space:]]}"}"
  [[ -z "$line" ]] && continue
  [[ -z "$PACKAGE" ]] || package_contains "$line" || continue
  SKILLS+=("$line")
done < "$SKILLS_MANIFEST"

for dest_root in "${TARGETS[@]}"; do
  info "target $dest_root"
  for path in "${SKILLS[@]}"; do
    skill_name="${path##*/}"
    expected="$REPO_ROOT/$path/SKILL.md"
    dest_dir="$dest_root/$skill_name"
    dest="$dest_dir/SKILL.md"
    if [[ -L "$dest" && "$(readlink "$dest")" == "$expected" ]]; then
      rm "$dest"
      rmdir "$dest_dir" 2>/dev/null || true
      info "removed $skill_name from $dest_root"
    fi
  done
done

info "done (${PACKAGE:-all skills})"
