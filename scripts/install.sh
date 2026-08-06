#!/usr/bin/env bash
# Link all registered skills, or one complete cross-linked package.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_MANIFEST="$REPO_ROOT/skills.manifest"
PACKAGES_MANIFEST="$REPO_ROOT/packages.manifest"

CURSOR_SKILLS="${CURSOR_SKILLS:-$HOME/.cursor/skills}"
CLAUDE_SKILLS="${CLAUDE_SKILLS:-$HOME/.claude/skills}"
AGENTS_SKILLS="${AGENTS_SKILLS:-$HOME/.agents/skills}"

die() { echo "install: error: $*" >&2; exit 1; }
info() { echo "install: $*"; }

usage() {
  cat <<'EOF'
Usage: ./scripts/install.sh [--all|--cursor|--claude|--agents]
                            [--package <name>] [-h|--help]

Link all skills (default), or one complete cross-linked package.

  --all       ~/.agents/skills + ~/.claude/skills (default; all three agents)
  --cursor    ~/.cursor/skills (Cursor only)
  --claude    ~/.claude/skills (Claude Code only)
  --agents    ~/.agents/skills (Codex and Cursor)
  --codex     alias for --agents
  --package   install only a package listed in packages.manifest

Do not combine --cursor with --agents: Cursor reads both roots.
Set CURSOR_SKILLS, CLAUDE_SKILLS, or AGENTS_SKILLS to override a root.
EOF
}

TARGETS=()
SKILLS=()
PACKAGE=""
TARGET_FLAGS=0
ALL_TARGETS=0
WANTS_CURSOR=0
WANTS_AGENTS=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --all) ALL_TARGETS=1 ;;
    --cursor)
      TARGETS+=("$CURSOR_SKILLS")
      TARGET_FLAGS=$((TARGET_FLAGS + 1))
      WANTS_CURSOR=1
      ;;
    --claude)
      TARGETS+=("$CLAUDE_SKILLS")
      TARGET_FLAGS=$((TARGET_FLAGS + 1))
      ;;
    --agents|--codex)
      TARGETS+=("$AGENTS_SKILLS")
      TARGET_FLAGS=$((TARGET_FLAGS + 1))
      WANTS_AGENTS=1
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
[[ $WANTS_CURSOR -eq 0 || $WANTS_AGENTS -eq 0 ]] ||
  die "--cursor and --agents would expose duplicate skills to Cursor"

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

[[ ${#SKILLS[@]} -gt 0 ]] || die "package $PACKAGE contains no registered skills"

# Preflight every source and destination before creating any link.
for dest_root in "${TARGETS[@]}"; do
  [[ ( ! -e "$dest_root" && ! -L "$dest_root" ) || -d "$dest_root" ]] ||
    die "$dest_root exists and is not a directory"

  for path in "${SKILLS[@]}"; do
    skill_name="${path##*/}"
    src="$REPO_ROOT/$path/SKILL.md"
    dest_dir="$dest_root/$skill_name"
    dest="$dest_dir/SKILL.md"
    [[ -f "$src" ]] || die "missing $src (check skills.manifest)"

    if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then
      :
    elif [[ -e "$dest_dir" || -L "$dest_dir" ]]; then
      die "$dest_dir already exists and is not this repo's installation"
    fi

    other_root=""
    [[ "$dest_root" == "$AGENTS_SKILLS" ]] && other_root="$CURSOR_SKILLS"
    [[ "$dest_root" == "$CURSOR_SKILLS" ]] && other_root="$AGENTS_SKILLS"
    if [[ -n "$other_root" && "$other_root" != "$dest_root" &&
          ( -e "$other_root/$skill_name" || -L "$other_root/$skill_name" ) ]]; then
      die "$skill_name already exists in Cursor's other user skill root: $other_root"
    fi
  done
done

for dest_root in "${TARGETS[@]}"; do
  info "target $dest_root"
  mkdir -p "$dest_root"
  for path in "${SKILLS[@]}"; do
    skill_name="${path##*/}"
    src="$REPO_ROOT/$path/SKILL.md"
    dest_dir="$dest_root/$skill_name"
    dest="$dest_dir/SKILL.md"
    if [[ ! -L "$dest" ]]; then
      mkdir -p "$dest_dir"
      ln -s "$src" "$dest"
      info "linked $skill_name -> $dest"
    fi
  done
done

info "done (${PACKAGE:-all skills}; ${#TARGETS[@]} target(s))"
