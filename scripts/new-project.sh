#!/usr/bin/env bash
# Start a brand-new project: a folder, a backup on GitHub, sensible ignore
# rules, and a first saved checkpoint. Usage: new-project.sh <name> [--public]

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$HERE/lib/common.sh"

name="${1:-}"
visibility="--private"
[ "${2:-}" = "--public" ] && visibility="--public"

if [ -z "$name" ]; then
  oops "What should the project be called? (e.g. /new-project my-app)"
  exit 1
fi

# Resolve where it lives (absolute path or a folder under the current one).
case "$name" in
  /*) dir="$name"; name="$(basename "$name")" ;;
  *)  dir="$PWD/$name" ;;
esac

if [ -e "$dir" ] && [ -n "$(ls -A "$dir" 2>/dev/null)" ]; then
  oops "There's already something at '$dir'. Pick a different name or folder."
  exit 1
fi

mkdir -p "$dir"
cd "$dir"
set_active_project "$dir"   # so commands work even if the session stays in the parent folder

gitq init -b main || git init >/dev/null 2>&1
git symbolic-ref HEAD refs/heads/main 2>/dev/null || true
git config gitless.managed true 2>/dev/null || true   # marks this as a gitless project

# A friendly starting point.
printf '# %s\n\nA project kept safe with gitless.\n' "$name" > README.md

# Base ignore rules + the managed block the plugin keeps up to date.
bash "$HERE/update-gitignore.sh" base >/dev/null 2>&1

mkdir -p .worktrees   # separate spaces for features live here

gitq add -A
gitq commit -m "Start $name" || true
ok "Created your project '$name' at $dir"

# Back it up to GitHub.
if command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
  if gh repo create "$name" "$visibility" --source=. --remote=origin --push >/dev/null 2>&1; then
    url="$(gh repo view --json url -q .url 2>/dev/null)"
    ok "Backed it up to GitHub${url:+ at $url}"
  else
    oops "Couldn't create the GitHub backup automatically."
    info "It might already exist there, or the name's taken. I can retry with a different name."
  fi
else
  info "Not signed in to GitHub yet, so I made the project locally only."
  info "Run /setup to connect it for cloud backup whenever you're ready."
fi

say ""
say "PROJECT: $dir"
ok "You're all set. Just start building — I'll keep everything saved and safe."
