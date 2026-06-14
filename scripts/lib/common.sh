#!/usr/bin/env bash
# Shared helpers for gitless. Everything user-facing speaks plain language;
# raw git stays hidden behind these functions.

set -euo pipefail

# ---- friendly output -------------------------------------------------------
say()  { printf '%s\n' "$*"; }
ok()   { printf '\xe2\x9c\x93 %s\n' "$*"; }      # ✓
info() { printf '\xe2\x80\xa2 %s\n' "$*"; }      # •
oops() { printf '\xe2\x9a\xa0 %s\n' "$*" >&2; }  # ⚠

# Run git with no output; callers translate the result.
gitq() { git "$@" >/dev/null 2>&1; }

# ---- repo awareness (always derived from git, never stored) ----------------

# Root of the project = the main checkout (first entry in the worktree list).
project_root() {
  git worktree list --porcelain 2>/dev/null | sed -n 's/^worktree //p' | head -n1
}

current_branch() { git rev-parse --abbrev-ref HEAD 2>/dev/null || true; }

# Are we inside a feature space (i.e. not on the project's real version)?
in_feature() {
  local b; b="$(current_branch)"
  [ -n "$b" ] && [ "$b" != "main" ] && [ "$b" != "master" ]
}

have_changes() { [ -n "$(git status --porcelain 2>/dev/null)" ]; }

has_remote() { [ -n "$(git remote 2>/dev/null)" ]; }

# Every feature space (linked worktrees that aren't the real project), one per
# line as "<path><TAB><feature-name>". Lets scripts find the feature without
# depending on which folder they were run from.
feature_worktrees() {
  git worktree list --porcelain 2>/dev/null | awk '
    /^worktree /{ wt=substr($0,10) }
    /^branch /{ br=$2; sub(/^refs\/heads\//,"",br);
                if (br!="main" && br!="master") print wt "\t" br }
  '
}

# If exactly one feature is in progress, echo "<path><TAB><name>"; else nothing.
# Always succeeds (returning non-zero would trip `set -e` at the call site).
the_feature() {
  local out; out="$(feature_worktrees)"
  [ "$(printf '%s' "$out" | grep -c .)" -eq 1 ] && printf '%s' "$out"
  return 0
}

# Turn "Add a dark mode" into "add-a-dark-mode".
slugify() {
  printf '%s' "$1" \
    | tr '[:upper:]' '[:lower:]' \
    | sed -e 's/[^a-z0-9]\{1,\}/-/g' -e 's/^-//' -e 's/-$//'
}

# The project's real-version branch.
base_branch() {
  if   git show-ref --verify --quiet refs/heads/main;   then echo main
  elif git show-ref --verify --quiet refs/heads/master; then echo master
  else echo main; fi
}

# The folder whose work an action should touch: the feature space we're standing
# in, or the single feature in progress, else the real project. Cwd-independent.
work_target() {
  local t single
  t="$(git rev-parse --show-toplevel 2>/dev/null || echo "$PWD")"
  single="$(the_feature)"
  if [ -n "$single" ] && ! in_feature; then
    IFS=$'\t' read -r t _ <<<"$single"
  fi
  printf '%s' "$t"
}

# Keep the cloud backup matching the current state after a rewind (undo/redo).
# Safe because this is a single-user project on its own line of work; hidden.
force_sync() {  # <dir> <branch>
  has_remote || return 0
  git -C "$1" push --force-with-lease origin "$2" >/dev/null 2>&1 || true
}

# Pull the project's real version (top-level main) up to date with GitHub, so it
# never falls behind the cloud. Fast-forward only — never creates conflicts here.
# Call it at the moments that touch main (starting/finishing a feature, saving the
# project directly).
sync_main() {  # <root>
  local root="$1" base
  [ -n "$(git -C "$root" remote 2>/dev/null)" ] || return 0
  if   git -C "$root" show-ref --verify --quiet refs/heads/main;   then base=main
  elif git -C "$root" show-ref --verify --quiet refs/heads/master; then base=master
  else base=main; fi
  git -C "$root" fetch origin "$base" >/dev/null 2>&1 || return 0
  git -C "$root" merge --ff-only "origin/$base" >/dev/null 2>&1 || true
}

# Drop a pending "redo" line, keeping its tip recoverable. Called when a fresh
# edit starts a new direction (so redo no longer applies — like a writing app).
clear_redo() {  # <dir> <branch>
  local ref="refs/gitless/redo/$2" tip
  tip="$(git -C "$1" rev-parse -q --verify "$ref" 2>/dev/null)" || return 0
  git -C "$1" tag -f "gitless/recovered-$(date +%s)" "$tip" >/dev/null 2>&1 || true
  git -C "$1" update-ref -d "$ref" >/dev/null 2>&1 || true
}

# Remember / recall the project the user is working in, so commands still work
# when the session's folder is the *parent* of a freshly made project (the cwd
# doesn't follow `new-project` into the new folder).
_gl_state()          { printf '%s' "${XDG_STATE_HOME:-$HOME/.local/state}/gitless"; }
active_project()     { local f; f="$(_gl_state)/active"; [ -f "$f" ] && cat "$f"; return 0; }
set_active_project() { local d; d="$(_gl_state)"; mkdir -p "$d" && printf '%s\n' "$1" > "$d/active"; }

# If we're inside a project, note it as the active one and stay put. If we're not
# (e.g. sitting in the parent folder right after creating one), step into the
# active project so the rest of the script operates at the right level.
enter_project() {
  if git rev-parse --git-dir >/dev/null 2>&1; then
    set_active_project "$(project_root)" 2>/dev/null || true
    return 0
  fi
  local p; p="$(active_project)"
  [ -n "$p" ] && [ -d "$p/.git" ] && cd "$p" 2>/dev/null || true
}

# Fail loudly (in plain words) when we're not in a gitless project.
require_project() {
  enter_project
  if ! git rev-parse --git-dir >/dev/null 2>&1; then
    oops "This folder isn't a project yet. Want me to start one? (run /new-project)"
    exit 1
  fi
}
