#!/usr/bin/env bash
# Write/refresh the gitless section of a project's notes, so every agent session
# in the project operates in gitless mode (the global skill alone isn't a reliable
# per-project signal). The section lives in AGENTS.md, which both Codex and Claude
# Code read. Claude Code skips AGENTS.md when a CLAUDE.md exists, so an existing
# CLAUDE.md gets a one-line import of it (no CLAUDE.md is created). Managed
# blocks; the user's own notes outside them are kept.
# Usage: write-project-notes.sh [project-root]

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$HERE/lib/common.sh"

enter_project   # land in the project even if the session's cwd didn't follow
root="${1:-$(project_root 2>/dev/null || echo "$PWD")}"
BEGIN="<!-- gitless:begin (managed by the gitless plugin — keep your own notes outside this block) -->"
END="<!-- gitless:end -->"

gitless_block() {
cat <<'EOF'
## This project uses gitless

This project is managed with **gitless** — version control in plain, everyday
language. Assume the user does not know or want to deal with git.

**For anything version-control-related — saving work; starting, finishing, or
removing a feature; undoing or redoing; backing up; or checking where things
stand — use the gitless skill and its commands. Never run raw `git`/`gh` in front
of the user, and never use git jargon** (commit, branch, merge, push, pull, PR…).
"GitHub" is fine to say — it's the user's backup service.

**Before building anything new, open a separate space first.** When you're on the
real project (not already inside a feature) and the user asks to add, build, make,
create, or change something — e.g. "let's add a dark mode", "can you build a login
page", "make the header sticky" — treat it as a **new feature**. Confirm once
("Want me to set this up as a separate feature so your project stays safe?"), run
the gitless `feature` command with a short description, and do the work in the
space it opens. **Do not write or change project code directly on the real
version for new work.** If you're already inside a feature, just keep working
there — don't ask again.

What to do for common requests (the commands are `/gitless:<name>` in Claude Code
and `$gitless:<name>` in Codex):
- "set up backups" / "get me started" → `setup`
- "save" / "save my work" → `save`  (also save quietly at natural stops)
- "let's add / build / make X" (new work) → confirm once, then `feature` X
- "done" / "it's finished" / "ship it" → `done`
- "undo" / "go back" / "redo" → `undo`, `redo`  (by time, not names)
- "remove the X feature" / "get rid of X" → `remove-feature` X
- "where are we?" / "is it backed up?" → `status`
- "how do I use this?" / "what can I do?" / "remind me" → `help`

Use the **gitless** skill for the full guidance and exact wording.
EOF
}

claude_import() { printf '%s\n' '@AGENTS.md'; }

# The file's content minus our managed block.
without_block() {
  awk -v b="$BEGIN" -v e="$END" '$0==b{skip=1} skip&&$0==e{skip=0;next} !skip' "$1"
}

# Replace the managed block in <file> with what <fn> prints (appending it if new).
put_block() {  # <file> <fn>
  local file="$1" tmp
  touch "$file"
  tmp="$(mktemp)"
  if grep -qF "$BEGIN" "$file"; then
    without_block "$file" > "$tmp"
  else
    cat "$file" > "$tmp"
    [ -s "$tmp" ] && printf '\n' >> "$tmp"
  fi
  { printf '%s\n' "$BEGIN"; "$2"; printf '%s\n' "$END"; } >> "$tmp"
  mv "$tmp" "$file"
}

put_block "$root/AGENTS.md" gitless_block

# An existing CLAUDE.md just imports AGENTS.md — unless the user's own notes
# already do.
claude="$root/CLAUDE.md"
if [ -f "$claude" ]; then
  if without_block "$claude" | grep -qxE '@(\./)?AGENTS\.md'; then
    tmp="$(mktemp)"
    without_block "$claude" > "$tmp" && mv "$tmp" "$claude"
  else
    put_block "$claude" claude_import
  fi
fi
