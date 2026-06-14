#!/usr/bin/env bash
# Remove a whole finished feature from the real project — a bigger, named action
# than undo. Forward-only and reversible (it doesn't rewrite history, so the
# backup stays consistent with no force needed).
# Usage:
#   feature-remove.sh <feature name>           remove it
#   feature-remove.sh restore <feature name>   bring it back
#   feature-remove.sh list                     show what can be removed

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$HERE/lib/common.sh"
require_project

root="$(project_root)"
base="$(base_branch)"

# Features currently part of the project = "Add <slug>" entries that haven't been
# removed since.
list_added() {
  git -C "$root" log "$base" --format='%s' 2>/dev/null \
    | awk '/^Remove /{removed[$2]=1; next}
           /^Add /{ if (!($2 in removed) && !($2 in seen)) { seen[$2]=1; print $2 } }'
}

print_removable() {
  local any=0
  while read -r s; do [ -n "$s" ] && { printf '   - %s\n' "${s//-/ }"; any=1; }; done < <(list_added)
  [ "$any" -eq 0 ] && info "(none yet — features show up here after you finish them)"
}

if [ "${1:-}" = "list" ]; then
  say "Features in your project you could remove:"
  print_removable
  exit 0
fi

mode=remove
if [ "${1:-}" = "restore" ]; then mode=restore; shift; fi
name="$*"
if [ -z "$name" ]; then
  oops "Which feature? e.g. \"remove the dark mode feature\""
  exit 1
fi
slug="$(slugify "$name")"

revert_cleanly() {  # <commit> ; sets nothing, returns nonzero on clash
  local commit="$1" mflag=""
  # Merge commits (the normal case) need to know the mainline side.
  [ "$(git -C "$root" rev-list --parents -n1 "$commit" | wc -w)" -ge 3 ] && mflag="-m 1"
  if ! git -C "$root" revert -n $mflag "$commit" >/dev/null 2>&1 \
     || [ -n "$(git -C "$root" diff --name-only --diff-filter=U)" ]; then
    git -C "$root" reset --hard >/dev/null 2>&1
    return 1
  fi
  return 0
}

if [ "$mode" = remove ]; then
  commit="$(git -C "$root" log "$base" --grep="^Add $slug\$" --format=%H -n1)"
  if [ -z "$commit" ]; then
    oops "I couldn't find a feature called \"$name\" in your project."
    say ""; say "Ones you can remove:"; print_removable
    exit 1
  fi
  if ! revert_cleanly "$commit"; then
    oops "Other changes were built on top of \"$name\", so I can't remove it cleanly without affecting them. I left everything as-is."
    exit 1
  fi
  git -C "$root" add -A
  git -C "$root" commit -m "Remove $slug" >/dev/null 2>&1
  if git -C "$root" push origin "$base" >/dev/null 2>&1; then
    ok "Removed the \"$name\" feature, and backed up."
  else
    ok "Removed the \"$name\" feature."
    info "(Couldn't reach GitHub just now — I'll back up next time.)"
  fi
  info "Changed your mind later? Say \"bring back the $name feature\"."
else
  commit="$(git -C "$root" log "$base" --grep="^Remove $slug\$" --format=%H -n1)"
  if [ -z "$commit" ]; then
    oops "I don't see a removed feature called \"$name\" to bring back."
    exit 1
  fi
  if ! revert_cleanly "$commit"; then
    oops "Bringing \"$name\" back clashes with newer changes, so I left things as-is."
    exit 1
  fi
  git -C "$root" add -A
  git -C "$root" commit -m "Add $slug" >/dev/null 2>&1
  if git -C "$root" push origin "$base" >/dev/null 2>&1; then
    ok "Brought back the \"$name\" feature, and backed up."
  else
    ok "Brought back the \"$name\" feature."
  fi
fi
