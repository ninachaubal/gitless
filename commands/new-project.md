---
description: Start a new project, backed up to GitHub with sensible defaults
argument-hint: <project-name>
allowed-tools: Bash
---

The user wants to start a new project called "$ARGUMENTS".

1. Run: `bash "${CLAUDE_PLUGIN_ROOT}/scripts/new-project.sh" "$ARGUMENTS"`
   (If it reports the toolchain or GitHub sign-in isn't ready, run /setup first,
   then retry. If no name was given, ask what they'd like to call it.)
2. The script prints `PROJECT: <path>`. **`cd` into that path** — the rest must
   run inside the project.
3. Set up the project's notes file:
   - If the project has **no CLAUDE.md**, run `/init` to create one.
   - Then add the gitless section: `bash "${CLAUDE_PLUGIN_ROOT}/scripts/write-claude-md.sh"`
4. Save so the notes are backed up: `bash "${CLAUDE_PLUGIN_ROOT}/scripts/save.sh" "Set up project notes"`

Relay the friendly output throughout. Speak plainly — see the gitless skill.
