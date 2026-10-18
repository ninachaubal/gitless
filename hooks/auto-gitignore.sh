#!/usr/bin/env bash
# PostToolUse hook: when a dependency/manifest file is written in a gitless
# project, quietly add sensible ignore rules for that stack — so the user never
# has to think about it. Scoped to gitless-managed projects; never blocks the
# tool call (always exits 0).

PLUGIN_DIR="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
payload="$(cat 2>/dev/null || true)"

# Fast bail: the payload doesn't mention any manifest we care about.
printf '%s' "$payload" | grep -qE 'package\.json|package-lock|pnpm-lock|yarn\.lock|tsconfig\.json|requirements\.txt|pyproject\.toml|Pipfile|setup\.py|setup\.cfg|Cargo\.toml|go\.mod|pom\.xml|build\.gradle' || exit 0

# The path(s) of the file(s) that were written/edited. Claude Code reports
# `tool_input.file_path`. Codex edits through apply_patch: its patch text (in
# `tool_input.command`) names each file on an "*** Add File: <path>" or
# "*** Update File: <path>" line, relative to the session's `cwd`.
files="" patch="" cwd=""
if command -v jq >/dev/null 2>&1; then
  files="$(printf '%s' "$payload" | jq -r '.tool_input.file_path // empty' 2>/dev/null || true)"
  patch="$(printf '%s' "$payload" | jq -r '.tool_input.command // empty | if type == "array" then .[] else . end | strings' 2>/dev/null || true)"
  cwd="$(printf '%s' "$payload" | jq -r '.cwd // empty' 2>/dev/null || true)"
else
  files="$(printf '%s' "$payload" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed -E 's/.*:[[:space:]]*"//; s/"$//')"
  patch="$(printf '%s' "$payload" | grep -oE '\*\*\* (Add|Update) File: [^"\\]+' || true)"
  cwd="$(printf '%s' "$payload" | grep -o '"cwd"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed -E 's/.*:[[:space:]]*"//; s/"$//')"
fi
files="$files"$'\n'"$(printf '%s\n' "$patch" | sed -n -E 's/^\*\*\* (Add|Update) File: //p')"

# Which stack does that imply? The first file that names one decides.
file="" stack=""
while IFS= read -r f; do
  case "$(basename "$f")" in
    package.json|package-lock.json|pnpm-lock.yaml|yarn.lock|tsconfig.json) stack=node ;;
    requirements.txt|pyproject.toml|Pipfile|setup.py|setup.cfg)            stack=python ;;
    Cargo.toml)                                                            stack=rust ;;
    go.mod)                                                                stack=go ;;
    pom.xml|build.gradle|build.gradle.kts)                                 stack=java ;;
    *) continue ;;
  esac
  file="$f"; break
done <<<"$files"
[ -n "$stack" ] || exit 0
case "$file" in /*) ;; *) file="${cwd:-$PWD}/$file" ;; esac

dir="$(dirname "$file")"
[ -d "$dir" ] || exit 0
root="$(git -C "$dir" worktree list --porcelain 2>/dev/null | sed -n 's/^worktree //p' | head -n1)"
[ -n "$root" ] || exit 0

# Only touch projects gitless manages (never the user's other repos).
managed="$(git -C "$root" config --get gitless.managed 2>/dev/null || true)"
if [ "$managed" != "true" ]; then
  if ! { grep -qs 'gitless:begin' "$root/AGENTS.md" "$root/CLAUDE.md" || [ -d "$root/.worktrees" ]; }; then
    exit 0
  fi
fi

( cd "$root" && bash "$PLUGIN_DIR/scripts/update-gitignore.sh" "$stack" >/dev/null 2>&1 ) || true
exit 0
