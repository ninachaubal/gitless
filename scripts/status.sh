#!/usr/bin/env bash
# Plain-language "where things stand." Works from anywhere in the project. No git terms.

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$HERE/lib/common.sh"

enter_project
if ! git rev-parse --git-dir >/dev/null 2>&1; then
  info "This folder isn't a project yet. Run /new-project to start one."
  exit 0
fi

# Which work are we looking at — a feature, or the real project?
target="$(git rev-parse --show-toplevel 2>/dev/null || echo "$PWD")"
single="$(the_feature)"
desc=""
if in_feature; then
  desc="$(current_branch | tr '-' ' ')"
elif [ -n "$single" ]; then
  IFS=$'\t' read -r target b <<<"$single"; desc="${b//-/ }"
fi

if [ -n "$desc" ]; then
  say "You're building: \"$desc\" (in a separate space)."
  info "Your real project stays safe until this is added."
else
  say "You're on your real project."
fi

# Saved or not?
if [ -n "$(git -C "$target" status --porcelain 2>/dev/null)" ]; then
  info "You have unsaved changes. Say \"save\" and I'll checkpoint them."
else
  ok "Everything's saved."
fi

# Backed up or not?
if has_remote; then
  if git -C "$target" rev-parse --abbrev-ref '@{u}' >/dev/null 2>&1; then
    ahead="$(git -C "$target" rev-list --count '@{u}..HEAD' 2>/dev/null || echo 0)"
    if [ "${ahead:-0}" -gt 0 ]; then
      info "$ahead checkpoint(s) not backed up to GitHub yet."
    else
      ok "Backed up to GitHub."
    fi
  else
    info "Not backed up to GitHub yet — I'll do that on your next save."
  fi
else
  info "Not connected to GitHub yet. Run /setup to turn on cloud backup."
fi

# When did we last save?
last="$(git -C "$target" log -1 --date=relative --format='%s (%ad)' 2>/dev/null || true)"
[ -n "$last" ] && say "Last checkpoint: $last"
