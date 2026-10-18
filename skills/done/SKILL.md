---
name: done
description: Add the finished feature to your real project and back it up
allowed-tools: Bash
disable-model-invocation: true
---

`<scripts>` below is this plugin's `scripts/` folder: `${CLAUDE_PLUGIN_ROOT}/scripts`
in Claude Code; in Codex, the `scripts/` folder two levels above this SKILL.md.
Follow the **gitless** skill throughout (read it first if you haven't yet).

The user says the current feature is finished. Confirm once that they're ready to
add it to their real project, then run this (from anywhere — it finds the feature
itself; don't `cd` and don't read the script):

`bash "<scripts>/feature-ship.sh"`

- If it succeeds, relay the friendly confirmation.
- If it says there's no feature in progress, the work may already be on the real
  project — just reassure the user; don't go hunting or inspecting scripts.
- If it prints `NEEDS_RESOLUTION`, two changes overlap. Walk the user through each
  listed file in plain language: ask whether to keep the version they just built
  or the one already in the project. Apply each choice with
  `bash "<scripts>/resolve.sh" <file> mine|project`
  (`mine` = what they built, `project` = what was already there). Resolving the
  last file finishes automatically; otherwise run `feature-ship.sh continue`.

Never show conflict markers or git terms.
