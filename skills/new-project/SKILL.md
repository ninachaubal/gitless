---
name: new-project
description: Start a new project, backed up to GitHub with sensible defaults
argument-hint: "<project-name>"
allowed-tools: Bash
disable-model-invocation: true
---

`<scripts>` below is this plugin's `scripts/` folder: `${CLAUDE_PLUGIN_ROOT}/scripts`
in Claude Code; in Codex, the `scripts/` folder two levels above this SKILL.md.
Follow the **gitless** skill throughout (read it first if you haven't yet).

The user wants to start a new project. If they didn't give it a name, ask what
they'd like to call it.

1. Run: `bash "<scripts>/new-project.sh" "<name>"`
   (If it reports the toolchain or GitHub sign-in isn't ready, run the `setup`
   command first, then retry.)
2. The script prints `PROJECT: <path>`. **Work inside that path** from here on
   (`cd` into it, or run commands there) — the rest must happen in the project.
3. Add the project's notes: `bash "<scripts>/write-project-notes.sh"`
4. Save so the notes are backed up: `bash "<scripts>/save.sh" "Set up project notes"`

Relay the friendly output throughout. Speak plainly.
