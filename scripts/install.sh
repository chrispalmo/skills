#!/usr/bin/env bash
# Link all registered skills, or one complete cross-linked package.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_MANIFEST="$REPO_ROOT/skills.manifest"
PACKAGES_MANIFEST="$REPO_ROOT/packages.manifest"
BUNDLED_MANIFEST="$REPO_ROOT/bundled-skills.manifest"

CURSOR_SKILLS="${CURSOR_SKILLS:-$HOME/.cursor/skills}"
CLAUDE_SKILLS="${CLAUDE_SKILLS:-$HOME/.claude/skills}"
AGENTS_SKILLS="${AGENTS_SKILLS:-$HOME/.agents/skills}"
CURSOR_BUNDLED_SKILLS="${CURSOR_BUNDLED_SKILLS:-$HOME/.cursor/skills-cursor}"
CLAUDE_BUNDLED_SKILLS="${CLAUDE_BUNDLED_SKILLS:-}"
CODEX_BUNDLED_SKILLS="${CODEX_BUNDLED_SKILLS:-}"
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"

die() { echo "install: error: $*" >&2; exit 1; }
info() { echo "install: $*"; }
warn() { echo "install: warning: $*" >&2; }

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
Set CURSOR_BUNDLED_SKILLS, CLAUDE_BUNDLED_SKILLS, or CODEX_BUNDLED_SKILLS
to point at extra bundled-skill directories (used by tests).

Exit 0 on a clean install, 2 if a name overlaps a vendor bundled/system
skill (links are still created), 1 on a hard failure.
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
[[ -f "$BUNDLED_MANIFEST" ]] || die "missing $BUNDLED_MANIFEST"
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

CLAUDE_RESERVED=()
CURSOR_RESERVED=()
CODEX_RESERVED=()

while read -r agent name extra || [[ -n "${agent:-}" ]]; do
  [[ -z "${agent:-}" || "$agent" == \#* ]] && continue
  case "$agent" in
    claude) CLAUDE_RESERVED+=("$name") ;;
    cursor) CURSOR_RESERVED+=("$name") ;;
    codex) CODEX_RESERVED+=("$name") ;;
  esac
done < "$BUNDLED_MANIFEST"

add_bundled_from_dir() {
  local dest_var="$1" root="$2" d name
  [[ -n "$root" && -d "$root" ]] || return 0
  for d in "$root"/*/SKILL.md "$root"/.system/*/SKILL.md; do
    [[ -e "$d" || -L "$d" ]] || continue
    name="$(basename "$(dirname "$d")")"
    eval "$dest_var+=(\"\$name\")"
  done
}

add_bundled_from_dir CURSOR_RESERVED "$CURSOR_BUNDLED_SKILLS"
add_bundled_from_dir CLAUDE_RESERVED "$CLAUDE_BUNDLED_SKILLS"
add_bundled_from_dir CODEX_RESERVED "$CODEX_BUNDLED_SKILLS"
add_bundled_from_dir CODEX_RESERVED "$CODEX_HOME/skills/.system"
add_bundled_from_dir CODEX_RESERVED "/etc/codex/skills"

name_listed() {
  local want="$1"
  shift
  local n
  for n in "$@"; do
    [[ "$n" == "$want" ]] && return 0
  done
  return 1
}

targets_include() {
  local want="$1" t
  for t in "${TARGETS[@]}"; do
    [[ "$t" == "$want" ]] && return 0
  done
  return 1
}

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

    if [[ -L "$dest" ]]; then
      target="$(readlink "$dest")"
      if [[ "$target" == "$src" || "$target" == "$REPO_ROOT"/* ]]; then
        :
      else
        die "$dest_dir already exists and is not this repo's installation"
      fi
    elif [[ -e "$dest_dir" || -L "$dest_dir" ]]; then
      die "$dest_dir already exists and is not this repo's installation"
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
    if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then
      :
    else
      if [[ -L "$dest" ]]; then
        rm "$dest"
        rmdir "$dest_dir" 2>/dev/null || true
        info "relinked $skill_name"
      fi
      mkdir -p "$dest_dir"
      ln -s "$src" "$dest"
      info "linked $skill_name -> $dest"
    fi
  done
done

WARNED=0
for path in "${SKILLS[@]}"; do
  skill_name="${path##*/}"
  if targets_include "$CLAUDE_SKILLS" &&
     name_listed "$skill_name" ${CLAUDE_RESERVED[@]+"${CLAUDE_RESERVED[@]}"}; then
    warn "\"$skill_name\" skill will override Claude Code's bundled /$skill_name"
    WARNED=1
  fi
  if { targets_include "$AGENTS_SKILLS" || targets_include "$CURSOR_SKILLS"; } &&
     name_listed "$skill_name" ${CURSOR_RESERVED[@]+"${CURSOR_RESERVED[@]}"}; then
    warn "\"$skill_name\" skill may hide or share /$skill_name with Cursor's built-in"
    WARNED=1
  fi
  if targets_include "$AGENTS_SKILLS" &&
     name_listed "$skill_name" ${CODEX_RESERVED[@]+"${CODEX_RESERVED[@]}"}; then
    warn "\"$skill_name\" skill may appear alongside Codex's system /$skill_name"
    WARNED=1
  fi
done

info "done (${PACKAGE:-all skills}; ${#TARGETS[@]} target(s))"
[[ $WARNED -eq 0 ]] || exit 2
