#!/usr/bin/env bash
# Write/refresh the gitless section of a project's CLAUDE.md, so every session in
# the project operates in gitless mode (the global skill alone isn't a reliable
# per-project signal). Managed block; the user's own notes outside it are kept.
# Usage: write-claude-md.sh [project-root]

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$HERE/lib/common.sh"

enter_project   # land in the project even if the session's cwd didn't follow
root="${1:-$(project_root 2>/dev/null || echo "$PWD")}"
file="$root/CLAUDE.md"
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
`/gitless:feature <short description>`, and do the work in the space it opens.
**Do not write or change project code directly on the real version for new work.**
If you're already inside a feature, just keep working there — don't ask again.

What to do for common requests:
- "set up backups" / "get me started" → /gitless:setup
- "save" / "save my work" → /gitless:save  (also save quietly at natural stops)
- "let's add / build / make X" (new work) → confirm once, then /gitless:feature X
- "done" / "it's finished" / "ship it" → /gitless:done
- "undo" / "go back" / "redo" → /gitless:undo, /gitless:redo  (by time, not names)
- "remove the X feature" / "get rid of X" → /gitless:remove-feature X
- "where are we?" / "is it backed up?" → /gitless:status
- "how do I use this?" / "what can I do?" / "remind me" → /gitless:help

Invoke the **gitless** skill for the full guidance and exact wording.
EOF
}

touch "$file"
tmp="$(mktemp)"
if grep -qF "$BEGIN" "$file"; then
  # Replace the existing managed block, keep everything else.
  awk -v b="$BEGIN" -v e="$END" '$0==b{skip=1} skip&&$0==e{skip=0;next} !skip' "$file" > "$tmp"
else
  cat "$file" > "$tmp"
  [ -s "$tmp" ] && printf '\n' >> "$tmp"
fi
{ printf '%s\n' "$BEGIN"; gitless_block; printf '%s\n' "$END"; } >> "$tmp"
mv "$tmp" "$file"
