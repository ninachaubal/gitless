#!/usr/bin/env bash
# Apply the user's choice for one overlapping file during a hand-off.
# Usage: resolve.sh <file> <mine|project>
#   mine    = keep the version the user just built
#   project = keep the version already in the real project

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$HERE/lib/common.sh"
require_project

root="$(project_root)"
file="${1:-}"
choice="${2:-}"

if ! git -C "$root" rev-parse -q --verify MERGE_HEAD >/dev/null 2>&1; then
  oops "There's nothing waiting on a choice right now."
  exit 1
fi
if [ -z "$file" ] || [ -z "$choice" ]; then
  oops "Usage: resolve.sh <file> <mine|project>"
  exit 1
fi

case "$choice" in
  mine)    git -C "$root" checkout --theirs -- "$file" >/dev/null 2>&1
           git -C "$root" add -- "$file"
           ok "Kept the version you just built for $file." ;;
  project) git -C "$root" checkout --ours   -- "$file" >/dev/null 2>&1
           git -C "$root" add -- "$file"
           ok "Kept your project's existing version of $file." ;;
  *) oops "Choose 'mine' (what you built) or 'project' (what was already there)."; exit 1 ;;
esac

remaining="$(git -C "$root" diff --name-only --diff-filter=U)"
if [ -z "$remaining" ]; then
  say ""
  ok "All overlaps sorted. Finishing up…"
  bash "$HERE/feature-ship.sh" continue
fi
