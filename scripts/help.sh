#!/usr/bin/env bash
# Show the user, in plain language, what they can do and the usual flow — so they
# can get un-stuck in the session instead of digging up the README.

cat <<'EOF'
gitless — your work, kept safe, in plain language.

You don't need to know git. Just tell me what you want in your own words
(or type the /gitless: command). The main things you can do:

  Start a new project      "start a project called recipes"      /gitless:new-project
  Use gitless here          "manage this folder with gitless"     /gitless:adopt
  Build something new       "let's add a dark mode"               /gitless:feature
  Save your progress        "save"  /  "save a checkpoint"        /gitless:save
  Go back                   "undo"  /  "go back"                  /gitless:undo
  Go forward again          "redo"                                /gitless:redo
  Finish what you built     "it's done"  /  "ship it"             /gitless:done
  Remove a feature          "get rid of the dark mode feature"    /gitless:remove-feature
  See where things stand    "where are we?"  /  "is it saved?"    /gitless:status
  Set up cloud backups      "set up backups"                      /gitless:setup

The usual flow:

  1. Start a project    — I set it up and back it up to GitHub.
  2. Say what to build  — I open a safe space so your project can't break.
  3. Work away          — I save checkpoints as we go (or just say "save").
  4. Change your mind   — "undo" and "redo" step back and forth, freely.
  5. Say it's done      — I add it to your real project and back it up.

Your real project is always saved and backed up. Nothing is ever lost —
if you ever want to go back, just ask.
EOF
