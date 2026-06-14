#!/usr/bin/env bash
# PostToolUse hook: when a dependency/manifest file is written in a gitless
# project, quietly add sensible ignore rules for that stack — so the user never
# has to think about it. Scoped to gitless-managed projects; never blocks the
# tool call (always exits 0).

PLUGIN_DIR="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
payload="$(cat 2>/dev/null || true)"

# Fast bail: the payload doesn't mention any manifest we care about.
printf '%s' "$payload" | grep -qE 'package\.json|package-lock|pnpm-lock|yarn\.lock|tsconfig\.json|requirements\.txt|pyproject\.toml|Pipfile|setup\.py|setup\.cfg|Cargo\.toml|go\.mod|pom\.xml|build\.gradle' || exit 0

# The path of the file that was written/edited.
file=""
if command -v jq >/dev/null 2>&1; then
  file="$(printf '%s' "$payload" | jq -r '.tool_input.file_path // empty' 2>/dev/null || true)"
fi
if [ -z "$file" ]; then
  file="$(printf '%s' "$payload" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed -E 's/.*:[[:space:]]*"//; s/"$//')"
fi
[ -n "$file" ] || exit 0

# Which stack does that file imply?
case "$(basename "$file")" in
  package.json|package-lock.json|pnpm-lock.yaml|yarn.lock|tsconfig.json) stack=node ;;
  requirements.txt|pyproject.toml|Pipfile|setup.py|setup.cfg)            stack=python ;;
  Cargo.toml)                                                            stack=rust ;;
  go.mod)                                                                stack=go ;;
  pom.xml|build.gradle|build.gradle.kts)                                 stack=java ;;
  *) exit 0 ;;
esac

dir="$(dirname "$file")"
[ -d "$dir" ] || exit 0
root="$(git -C "$dir" worktree list --porcelain 2>/dev/null | sed -n 's/^worktree //p' | head -n1)"
[ -n "$root" ] || exit 0

# Only touch projects gitless manages (never the user's other repos).
managed="$(git -C "$root" config --get gitless.managed 2>/dev/null || true)"
if [ "$managed" != "true" ]; then
  if ! { { [ -f "$root/CLAUDE.md" ] && grep -q 'gitless:begin' "$root/CLAUDE.md"; } || [ -d "$root/.worktrees" ]; }; then
    exit 0
  fi
fi

( cd "$root" && bash "$PLUGIN_DIR/scripts/update-gitignore.sh" "$stack" >/dev/null 2>&1 ) || true
exit 0
