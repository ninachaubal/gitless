#!/usr/bin/env bash
# Turn the current folder into a gitless project — for a folder that already has
# work, or an existing git project you want gitless to manage in plain language.
# Usage: adopt.sh [--public]

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$HERE/lib/common.sh"

dir="$PWD"
name="$(basename "$dir")"
visibility="--private"
[ "${1:-}" = "--public" ] && visibility="--public"

if ! git rev-parse --git-dir >/dev/null 2>&1; then
  gitq init -b main || git init >/dev/null 2>&1
  git symbolic-ref HEAD refs/heads/main 2>/dev/null || true
  ok "Started keeping '$name' safe with version tracking."
else
  info "Adding gitless to your existing project '$name'."
fi

git config gitless.managed true 2>/dev/null || true   # marks this as a gitless project
set_active_project "$dir"
bash "$HERE/update-gitignore.sh" base >/dev/null 2>&1
mkdir -p .worktrees

if [ -z "$(git rev-parse -q --verify HEAD 2>/dev/null)" ] || have_changes; then
  gitq add -A
  gitq commit -m "Set up gitless for $name" || true
fi
ok "This is a gitless project now."

# Offer cloud backup if signed in and not already connected.
if ! has_remote && command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
  if gh repo create "$name" "$visibility" --source=. --remote=origin --push >/dev/null 2>&1; then
    url="$(gh repo view --json url -q .url 2>/dev/null)"
    ok "Backed it up to GitHub${url:+ at $url}"
  fi
elif ! has_remote; then
  info "Run /setup to connect GitHub for cloud backup whenever you're ready."
fi

say ""
say "PROJECT: $dir"
ok "You're set — I'll keep your work saved and safe from here."
