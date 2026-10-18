---
name: adopt
description: Use gitless in the current folder (an existing project or one with work already)
allowed-tools: Bash
disable-model-invocation: true
---

`<scripts>` below is this plugin's `scripts/` folder: `${CLAUDE_PLUGIN_ROOT}/scripts`
in Claude Code; in Codex, the `scripts/` folder two levels above this SKILL.md.
Follow the **gitless** skill throughout (read it first if you haven't yet).

The user wants to manage the current folder with gitless.

1. Run: `bash "<scripts>/adopt.sh"`
   It prints `PROJECT: <path>` — you're now working in that project.
2. Set up the project's notes:
   - If the project has no notes describing it yet (no AGENTS.md or CLAUDE.md),
     create them first — in Claude Code, run `/init`; otherwise write a short
     AGENTS.md saying what the project is and how to run it.
   - Then add the gitless section: `bash "<scripts>/write-project-notes.sh"`
3. Save so it's backed up: `bash "<scripts>/save.sh" "Set up gitless notes"`

If GitHub isn't connected and they want cloud backup, run the `setup` command.
Relay the friendly output. No git jargon.
