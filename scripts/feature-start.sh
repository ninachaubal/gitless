#!/usr/bin/env bash
# Open a separate space to build a feature, so the real project stays untouched.
# Usage: feature-start.sh <description of the feature>

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$HERE/lib/common.sh"
require_project

desc="$*"
if [ -z "$desc" ]; then
  oops "What are we building? (e.g. /feature add a dark mode)"
  exit 1
fi

root="$(project_root)"
slug="$(slugify "$desc")"
[ -n "$slug" ] || slug="feature"

# Avoid colliding with an existing space.
path="$root/.worktrees/$slug"
n=2
while [ -e "$path" ] || git -C "$root" show-ref --verify --quiet "refs/heads/$slug"; do
  slug="$(slugify "$desc")-$n"; path="$root/.worktrees/$slug"; n=$((n+1))
done

# Pull the real project up to date with GitHub *before* branching or committing
# anything locally (a local commit first can block the fast-forward).
sync_main "$root"

# Never let feature spaces get tracked — even on projects we didn't create.
if ! git -C "$root" check-ignore -q .worktrees 2>/dev/null; then
  bash "$HERE/update-gitignore.sh" base >/dev/null 2>&1 || true
  if [ -n "$(git -C "$root" status --porcelain .gitignore 2>/dev/null)" ]; then
    git -C "$root" add .gitignore >/dev/null 2>&1 || true
    git -C "$root" commit -m "Keep feature spaces out of the project" >/dev/null 2>&1 || true
  fi
fi

if git -C "$root" worktree add "$path" -b "$slug" >/dev/null 2>&1; then
  ok "Opened a separate space to build: \"$desc\""
  info "Your real project stays untouched while we work here."
  say  ""
  say  "WORKSPACE: $path"
else
  oops "Couldn't open a separate space. Is the project set up yet? (try /status)"
  exit 1
fi
