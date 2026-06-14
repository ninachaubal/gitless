#!/usr/bin/env bash
# Add a finished feature to the real project and back it up. Works from anywhere
# in the project — it finds the feature in progress on its own.
# Usage:
#   feature-ship.sh [name]    finish the feature (names it if you have several)
#   feature-ship.sh continue  finish up after overlaps were sorted out

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$HERE/lib/common.sh"
require_project

root="$(project_root)"

finish_up() {
  local branch="$1"
  git -C "$root" push origin main >/dev/null 2>&1 \
    && ok "Backed up to GitHub." \
    || info "Added it locally. (Couldn't reach GitHub just now — I'll back up next time.)"
  # Remove the feature's separate space and the finished feature line.
  local wt
  wt="$(git -C "$root" worktree list --porcelain | awk -v b="$branch" '
    /^worktree /{p=substr($0,10)}
    /^branch /{br=$2; sub(/^refs\/heads\//,"",br); if (br==b) print p}')"
  [ -n "$wt" ] && git -C "$root" worktree remove --force "$wt" >/dev/null 2>&1 || true
  git -C "$root" branch -D "$branch" >/dev/null 2>&1 || true
  # Also remove the leftover backup branch on GitHub, so it doesn't pile up.
  git -C "$root" push origin --delete "$branch" >/dev/null 2>&1 || true
  ok "Cleaned up the workspace. You're back on your real project."
}

# ---- continue after an overlap was resolved -------------------------------
if [ "${1:-}" = "continue" ]; then
  if ! git -C "$root" rev-parse -q --verify MERGE_HEAD >/dev/null 2>&1; then
    oops "There's nothing waiting to finish. (Maybe it's already done?)"
    exit 1
  fi
  unresolved="$(git -C "$root" diff --name-only --diff-filter=U)"
  if [ -n "$unresolved" ]; then
    oops "Still a couple of spots to settle before I can finish:"
    printf '   - %s\n' $unresolved
    exit 1
  fi
  git -C "$root" add -A
  git -C "$root" commit --no-edit >/dev/null 2>&1
  ok "Added the feature to your project."
  # The merge commit's subject is "Add <feature>" — recover the name from it.
  branch="$(git -C "$root" log -1 --format='%s' | sed 's/^Add //')"
  finish_up "$branch"
  exit 0
fi

# ---- figure out which feature to add --------------------------------------
feats="$(feature_worktrees)"
nfeat="$(printf '%s' "$feats" | grep -c .)"
if [ "$nfeat" -eq 0 ]; then
  oops "There's no feature in progress to add. (Start one with /feature.)"
  exit 1
fi

want="${1:-}"
if [ -n "$want" ]; then
  want="$(slugify "$want")"
  line="$(printf '%s\n' "$feats" | awk -F'\t' -v b="$want" '$2==b')"
  if [ -z "$line" ]; then
    oops "I couldn't find a feature called \"$1\". In progress right now:"
    printf '%s\n' "$feats" | awk -F'\t' '{gsub(/-/," ",$2); print "   - "$2}'
    exit 1
  fi
elif [ "$nfeat" -gt 1 ]; then
  oops "You have a few features in progress — which should I add?"
  printf '%s\n' "$feats" | awk -F'\t' '{gsub(/-/," ",$2); print "   - "$2}'
  info "Just tell me the name."
  exit 1
else
  line="$feats"
fi

IFS=$'\t' read -r wt branch <<<"$line"
desc="${branch//-/ }"

# Make sure the feature's work is saved and backed up first.
if [ -n "$(git -C "$wt" status --porcelain 2>/dev/null)" ]; then
  git -C "$wt" add -A
  git -C "$wt" commit -m "Final touches on $desc" >/dev/null 2>&1 || true
fi
has_remote && git -C "$wt" push -u origin "$branch" >/dev/null 2>&1 || true

# Pull the real project up to date with GitHub first, then fold the feature in.
sync_main "$root"

if git -C "$root" merge --no-ff "$branch" -m "Add $branch" >/dev/null 2>&1; then
  ok "Added your \"$desc\" to the project."
  finish_up "$branch"
  exit 0
fi

# Overlap: two changes touched the same place. Hand off in plain language.
conflicts="$(git -C "$root" diff --name-only --diff-filter=U)"
say ""
oops "Almost there — but some changes overlap and need your call:"
printf '   - %s\n' $conflicts
say ""
info "For each file, I'll ask whether to keep the version you just built or the"
info "one already in your project. (Then I'll finish up automatically.)"
echo "NEEDS_RESOLUTION"
exit 2
