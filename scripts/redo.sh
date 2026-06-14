#!/usr/bin/env bash
# Step forward again after an undo — like Redo in a writing app. Partner to undo.sh.
# Usage: redo.sh [n]

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$HERE/lib/common.sh"
require_project

target="$(work_target)"
branch="$(git -C "$target" rev-parse --abbrev-ref HEAD 2>/dev/null)"
redo_ref="refs/gitless/redo/$branch"

fwd="$(git -C "$target" rev-parse -q --verify "$redo_ref" 2>/dev/null || true)"
if [ -z "$fwd" ]; then
  oops "There's nothing to redo."
  exit 1
fi
# The forward point must still be ahead of where we are.
if ! git -C "$target" merge-base --is-ancestor HEAD "$fwd" 2>/dev/null \
   || [ "$(git -C "$target" rev-parse HEAD)" = "$fwd" ]; then
  git -C "$target" update-ref -d "$redo_ref" >/dev/null 2>&1 || true
  oops "You're already at the latest — nothing to redo."
  exit 1
fi

steps="${1:-1}"
if ! [[ "$steps" =~ ^[0-9]+$ ]] || [ "$steps" -lt 1 ]; then
  oops "Tell me how many steps to go forward, e.g. \"redo\" or \"redo 2\"."
  exit 1
fi

mapfile -t fwds < <(git -C "$target" rev-list --reverse --first-parent "HEAD..$fwd")
n="${#fwds[@]}"
[ "$steps" -gt "$n" ] && steps="$n"
dest="${fwds[$((steps-1))]}"
when="$(git -C "$target" log -1 --date=relative --format='%ad' "$dest")"
git -C "$target" reset --hard "$dest" >/dev/null 2>&1
force_sync "$target" "$branch"

ok "↷ Redone — back to where you were ($when)."
if [ "$dest" = "$fwd" ]; then
  info "That's the latest."
else
  info "Say \"redo\" again to go further, or \"undo\" to step back."
fi
