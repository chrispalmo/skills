#!/usr/bin/env bash
# Isolated checks for install.sh and uninstall.sh. Never writes to home skill roots.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INSTALL="$REPO_ROOT/scripts/install.sh"
UNINSTALL="$REPO_ROOT/scripts/uninstall.sh"
MANIFEST="$REPO_ROOT/skills.manifest"

WORKDIR="$(mktemp -d "${TMPDIR:-/tmp}/skills-install-test.XXXXXX")"
export AGENTS_SKILLS="$WORKDIR/agents"
export CLAUDE_SKILLS="$WORKDIR/claude"
export CURSOR_SKILLS="$WORKDIR/cursor"
export CURSOR_BUNDLED_SKILLS="$WORKDIR/bundled-cursor"
export CLAUDE_BUNDLED_SKILLS="$WORKDIR/bundled-claude"
export CODEX_BUNDLED_SKILLS="$WORKDIR/bundled-codex"
export CODEX_HOME="$WORKDIR/codex-home"
trap 'rm -rf "$WORKDIR"' EXIT

SKILLS=()
while IFS= read -r line || [[ -n "$line" ]]; do
  line="${line%%#*}"
  line="${line#"${line%%[![:space:]]*}"}"
  line="${line%"${line##*[![:space:]]}"}"
  [[ -z "$line" ]] && continue
  SKILLS+=("$line")
done < "$MANIFEST"

fail() { echo "test-install: FAIL: $*" >&2; exit 1; }
ok() { echo "test-install: ok $*"; }

reset_roots() {
  rm -rf "$AGENTS_SKILLS" "$CLAUDE_SKILLS" "$CURSOR_SKILLS" \
    "$CURSOR_BUNDLED_SKILLS" "$CLAUDE_BUNDLED_SKILLS" "$CODEX_BUNDLED_SKILLS" \
    "$CODEX_HOME"
  mkdir -p "$AGENTS_SKILLS" "$CLAUDE_SKILLS" "$CURSOR_SKILLS" \
    "$CURSOR_BUNDLED_SKILLS" "$CLAUDE_BUNDLED_SKILLS" "$CODEX_BUNDLED_SKILLS" \
    "$CODEX_HOME"
}

plant_bundled() {
  local root="$1" name="$2"
  mkdir -p "$root/$name"
  echo bundled >"$root/$name/SKILL.md"
}

dir_count() {
  local root="$1" n=0 d
  for d in "$root"/*; do
    [[ -e "$d" || -L "$d" ]] || continue
    n=$((n + 1))
  done
  echo "$n"
}

assert_link() {
  local dest="$1" expected="$2"
  [[ -L "$dest" ]] || fail "not a symlink: $dest"
  [[ "$(readlink "$dest")" == "$expected" ]] ||
    fail "$dest -> $(readlink "$dest") (want $expected)"
}

assert_missing() {
  [[ ! -e "$1" && ! -L "$1" ]] || fail "should not exist: $1"
}

assert_count() {
  local root="$1" want="$2" got
  got="$(dir_count "$root")"
  [[ "$got" == "$want" ]] || fail "$root has $got entries (want $want)"
}

expect_exit() {
  local want="$1" label="$2"
  shift 2
  set +e
  "$@" >"$WORKDIR/out" 2>"$WORKDIR/err"
  local got=$?
  set -e
  [[ "$got" == "$want" ]] ||
    fail "$label: exit $got (want $want): $(tr '\n' ' ' <"$WORKDIR/err")"
}

assert_all_linked() {
  local root="$1" path name
  for path in "${SKILLS[@]}"; do
    name="${path##*/}"
    assert_link "$root/$name/SKILL.md" "$REPO_ROOT/$path/SKILL.md"
  done
}

# Empty targets: default install fills agents + claude, leaves cursor empty.
reset_roots
expect_exit 0 "empty targets" "$INSTALL"
assert_all_linked "$AGENTS_SKILLS"
assert_all_linked "$CLAUDE_SKILLS"
assert_count "$CURSOR_SKILLS" 0
ok "empty targets"

# Re-run is a no-op.
expect_exit 0 "idempotent re-run" "$INSTALL"
assert_all_linked "$AGENTS_SKILLS"
assert_all_linked "$CLAUDE_SKILLS"
assert_count "$CURSOR_SKILLS" 0
ok "idempotent re-run"

# Backfill: only missing names are created.
rm -rf "$AGENTS_SKILLS/pause-for-review" "$CLAUDE_SKILLS/github-init"
expect_exit 0 "backfill" "$INSTALL"
assert_link "$AGENTS_SKILLS/pause-for-review/SKILL.md" \
  "$REPO_ROOT/skills/pause-for-review/SKILL.md"
assert_link "$CLAUDE_SKILLS/github-init/SKILL.md" \
  "$REPO_ROOT/skills/github-init/SKILL.md"
ok "backfill"

# Foreign destination aborts the whole run; no other links are written.
reset_roots
mkdir -p "$AGENTS_SKILLS/proofread"
echo foreign >"$AGENTS_SKILLS/proofread/SKILL.md"
expect_exit 1 "foreign dest" "$INSTALL"
[[ -f "$AGENTS_SKILLS/proofread/SKILL.md" ]] || fail "foreign proofread was changed"
assert_count "$AGENTS_SKILLS" 1
assert_count "$CLAUDE_SKILLS" 0
ok "foreign dest abort"

# Stale symlink into this clone is relinked to the current skill path.
reset_roots
mkdir -p "$AGENTS_SKILLS/design-tool"
ln -s "$REPO_ROOT/README.md" "$AGENTS_SKILLS/design-tool/SKILL.md"
expect_exit 0 "stale ours relink" "$INSTALL"
assert_link "$AGENTS_SKILLS/design-tool/SKILL.md" \
  "$REPO_ROOT/skills/design-tool/SKILL.md"
ok "stale ours relink"

# Same names already in the cursor root do not block default install.
reset_roots
mkdir -p "$CURSOR_SKILLS/project-bootstrap"
echo leftover >"$CURSOR_SKILLS/project-bootstrap/SKILL.md"
expect_exit 0 "cursor leftovers ignored" "$INSTALL"
assert_all_linked "$AGENTS_SKILLS"
[[ -f "$CURSOR_SKILLS/project-bootstrap/SKILL.md" ]] ||
  fail "cursor leftover was changed"
ok "cursor leftovers ignored"

# --cursor and --agents together are rejected.
reset_roots
expect_exit 1 "cursor+agents" "$INSTALL" --cursor --agents
assert_count "$AGENTS_SKILLS" 0
assert_count "$CURSOR_SKILLS" 0
ok "--cursor --agents rejected"

# --package interview installs only that package.
reset_roots
expect_exit 0 "--package interview" "$INSTALL" --package interview --agents
assert_link "$AGENTS_SKILLS/interview/SKILL.md" \
  "$REPO_ROOT/skills/interview/SKILL.md"
assert_link "$AGENTS_SKILLS/reverse-brief/SKILL.md" \
  "$REPO_ROOT/skills/interview/reverse-brief/SKILL.md"
assert_count "$AGENTS_SKILLS" 2
assert_missing "$AGENTS_SKILLS/pause-for-review"
assert_count "$CLAUDE_SKILLS" 0
ok "--package interview"

# Uninstall removes current and stale ours, leaves foreign files and extras.
reset_roots
expect_exit 0 "uninstall setup" "$INSTALL" --agents
echo keep >"$AGENTS_SKILLS/proofread/extra.txt"
rm "$AGENTS_SKILLS/plaintext/SKILL.md"
ln -s "$REPO_ROOT/README.md" "$AGENTS_SKILLS/plaintext/SKILL.md"
mkdir -p "$AGENTS_SKILLS/not-ours"
echo foreign >"$AGENTS_SKILLS/not-ours/SKILL.md"
"$UNINSTALL" --agents >/dev/null
assert_missing "$AGENTS_SKILLS/pause-for-review"
assert_missing "$AGENTS_SKILLS/plaintext"
[[ -f "$AGENTS_SKILLS/proofread/extra.txt" ]] || fail "extra file was removed"
assert_missing "$AGENTS_SKILLS/proofread/SKILL.md"
[[ -f "$AGENTS_SKILLS/not-ours/SKILL.md" ]] || fail "foreign folder was removed"
ok "uninstall identity"

# Claude reserved name from a scannable bundled dir: warn, exit 2, still link.
reset_roots
plant_bundled "$CLAUDE_BUNDLED_SKILLS" ingest
expect_exit 2 "claude override warning" "$INSTALL" --claude
assert_link "$CLAUDE_SKILLS/ingest/SKILL.md" \
  "$REPO_ROOT/skills/project-management/ingest/SKILL.md"
grep -F '"ingest" skill will override Claude Code'\''s bundled /ingest' \
  "$WORKDIR/err" >/dev/null || fail "missing Claude override wording"
ok "claude override warning"

# Cursor built-in name: warn, exit 2, still link.
reset_roots
plant_bundled "$CURSOR_BUNDLED_SKILLS" github-init
expect_exit 2 "cursor may-hide warning" "$INSTALL" --agents
assert_link "$AGENTS_SKILLS/github-init/SKILL.md" \
  "$REPO_ROOT/skills/github-init/SKILL.md"
grep -F '"github-init" skill may hide or share /github-init with Cursor'\''s built-in' \
  "$WORKDIR/err" >/dev/null || fail "missing Cursor may-hide wording"
ok "cursor may-hide warning"

# Codex system name: warn, exit 2, still link.
reset_roots
plant_bundled "$CODEX_BUNDLED_SKILLS" plaintext
expect_exit 2 "codex alongside warning" "$INSTALL" --agents
assert_link "$AGENTS_SKILLS/plaintext/SKILL.md" \
  "$REPO_ROOT/skills/plaintext/SKILL.md"
grep -F '"plaintext" skill may appear alongside Codex'\''s system /plaintext' \
  "$WORKDIR/err" >/dev/null || fail "missing Codex alongside wording"
ok "codex alongside warning"

# Warnings are scoped to the targets being written.
reset_roots
plant_bundled "$CURSOR_BUNDLED_SKILLS" github-init
plant_bundled "$CODEX_BUNDLED_SKILLS" plaintext
expect_exit 0 "claude-only ignores cursor/codex" "$INSTALL" --claude
grep -q 'may hide or share' "$WORKDIR/err" && fail "Claude-only emitted a Cursor warning"
grep -q 'alongside Codex' "$WORKDIR/err" && fail "Claude-only emitted a Codex warning"
ok "claude-only ignores cursor/codex"

reset_roots
plant_bundled "$CLAUDE_BUNDLED_SKILLS" ingest
expect_exit 0 "agents-only ignores claude" "$INSTALL" --agents
grep -q 'will override Claude Code' "$WORKDIR/err" &&
  fail "agents-only emitted a Claude warning"
ok "agents-only ignores claude"

echo "test-install: all passed"
