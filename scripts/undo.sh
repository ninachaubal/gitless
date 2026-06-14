#!/usr/bin/env bash
# Step back through recent checkpoints — like Undo in a writing app. Linear and
# recoverable; pairs with redo.sh. Stays within the current work (a feature, or
# the project). To remove a whole finished feature instead, use feature-remove.sh.
# Usage: undo.sh [n]  |  undo.sh list

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$HERE/lib/common.sh"
require_project

target="$(work_target)"
branch="$(git -C "$target" rev-parse --abbrev-ref HEAD 2>/dev/null)"
base="$(base_branch)"
redo_ref="refs/gitless/redo/$branch"

# Orientation list — by TIME, never by checkpoint name (auto-saves have no
# meaningful names, so the user navigates by "how far back," not by label).
if [ "${1:-}" = "list" ]; then
  say "Your recent checkpoints (newest first):"
  i=0
  while IFS=$'\t' read -r when _subject; do
    [ "$i" -eq 0 ] && m="now" || m="$i back"
    printf '  %-7s %s\n' "$m" "$when"
    i=$((i+1))
  done < <(git -C "$target" log -n 8 --date=relative --format='%ad%x09%s')
  say ""
  info "Say \"undo\" to step back one, or \"undo 3\" to go further."
  exit 0
fi

steps="${1:-1}"
if ! [[ "$steps" =~ ^[0-9]+$ ]] || [ "$steps" -lt 1 ]; then
  oops "Tell me how many steps to go back, e.g. \"undo\" or \"undo 3\"."
  exit 1
fi

# How far back can we go without leaving this piece of work?
if [ "$branch" != "$base" ] && [ "$branch" != main ] && [ "$branch" != master ]; then
  max="$(git -C "$target" rev-list --count "$base..HEAD" 2>/dev/null || echo 0)"
  floor_msg="That's as far back as this feature goes. To drop the whole feature, say \"remove the ${branch//-/ } feature\"."
else
  total="$(git -C "$target" rev-list --count HEAD 2>/dev/null || echo 0)"
  max=$(( total > 1 ? total - 1 : 0 ))
  floor_msg="That's the very beginning of your project — there's nothing before it."
fi

if [ "$max" -le 0 ]; then
  oops "$floor_msg"
  exit 1
fi
clamped=0
if [ "$steps" -gt "$max" ]; then steps="$max"; clamped=1; fi

# A fresh, unsaved change means a new direction — any pending redo no longer
# applies. Save that work first (so it's never lost), and retire the redo line.
if [ -n "$(git -C "$target" status --porcelain 2>/dev/null)" ]; then
  clear_redo "$target" "$branch"
  git -C "$target" add -A
  git -C "$target" commit -m "Auto-save before undo" >/dev/null 2>&1 || true
fi

# Remember the point we can redo forward to (only when starting a fresh run).
git -C "$target" rev-parse -q --verify "$redo_ref" >/dev/null 2>&1 \
  || git -C "$target" update-ref "$redo_ref" HEAD

dest="$(git -C "$target" rev-parse "HEAD~$steps")"
when="$(git -C "$target" log -1 --date=relative --format='%ad' "$dest")"
git -C "$target" reset --hard "$dest" >/dev/null 2>&1
force_sync "$target" "$branch"

ok "↶ Undone — back to how things were $when."
[ "$clamped" -eq 1 ] && info "$floor_msg"
info "Changed your mind? Say \"redo\"."
