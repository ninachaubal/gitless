#!/usr/bin/env bash
# Show the user, in plain language, what they can do and the usual flow — so they
# can get un-stuck in the session instead of digging up the README.

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$HERE/lib/common.sh"
p="$(gl_cmd '')"   # /gitless: in Claude Code, $gitless: in Codex

cat <<EOF
gitless — your work, kept safe, in plain language.

You don't need to know git. Just tell me what you want in your own words
(or type the ${p} command). The main things you can do:

  Start a new project      "start a project called recipes"      ${p}new-project
  Use gitless here          "manage this folder with gitless"     ${p}adopt
  Build something new       "new feature: search"                 ${p}feature
  Save your progress        "save"  /  "save a checkpoint"        ${p}save
  Go back                   "undo"  /  "go back"                  ${p}undo
  Go forward again          "redo"                                ${p}redo
  Finish what you built     "it's done"  /  "ship it"             ${p}done
  Remove a feature          "get rid of the search feature"       ${p}remove-feature
  See where things stand    "where are we?"  /  "is it saved?"    ${p}status
  Set up cloud backups      "set up backups"                      ${p}setup

The usual flow:

  1. Start a project    — I set it up and back it up to GitHub.
  2. Say what to build  — I open a safe space so your project can't break.
  3. Work away          — I save checkpoints as we go (or just say "save").
  4. Change your mind   — "undo" and "redo" step back and forth, freely.
  5. Say it's done      — I add it to your real project and back it up.

Your real project is always saved and backed up. Nothing is ever lost —
if you ever want to go back, just ask.
EOF
