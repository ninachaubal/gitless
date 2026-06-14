#!/usr/bin/env bash
# Save a checkpoint of the current work and back it up. Works from anywhere in
# the project: it saves the feature you're building if there is one, otherwise
# the project itself. Used on demand (/save) and automatically at stopping points.
# Usage: save.sh [a short note]  |  save.sh --quiet [note]

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$HERE/lib/common.sh"
require_project

quiet=0
if [ "${1:-}" = "--quiet" ]; then quiet=1; shift; fi
note="$*"
[ -n "$note" ] || note="Checkpoint $(date '+%b %-d, %-I:%M%p')"

# Where is the work? The feature space we're standing in, or the one in
# progress, else the real project.
target="$(work_target)"

if [ -z "$(git -C "$target" status --porcelain 2>/dev/null)" ]; then
  [ "$quiet" -eq 1 ] || ok "Nothing new to save — you're all caught up."
  exit 0
fi

git -C "$target" add -A
git -C "$target" commit -m "$note" >/dev/null 2>&1
[ "$quiet" -eq 1 ] || ok "Saved a checkpoint: $note"

branch="$(git -C "$target" rev-parse --abbrev-ref HEAD 2>/dev/null)"

# A fresh save while a redo was pending means a new direction was taken — the
# redo line no longer applies (writing-app behavior). Retire it, recoverably.
redo_ref="refs/gitless/redo/$branch"
if git -C "$target" rev-parse -q --verify "$redo_ref" >/dev/null 2>&1; then
  fwd="$(git -C "$target" rev-parse "$redo_ref")"
  git -C "$target" merge-base --is-ancestor HEAD "$fwd" 2>/dev/null || clear_redo "$target" "$branch"
fi

# Back up to GitHub if we're connected.
if has_remote; then
  # Saving the real project directly? Pull the latest first so it stays in sync.
  case "$branch" in main|master) sync_main "$target";; esac
  if git -C "$target" push -u origin "$branch" >/dev/null 2>&1; then
    [ "$quiet" -eq 1 ] || ok "Backed up to GitHub."
  else
    [ "$quiet" -eq 1 ] || info "Saved locally. (Couldn't reach GitHub just now — I'll back up next time.)"
  fi
fi
