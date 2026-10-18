---
name: redo
description: Step forward again after an undo (like Redo in a writing app)
argument-hint: "[how many steps]"
allowed-tools: Bash
disable-model-invocation: true
---

`<scripts>` below is this plugin's `scripts/` folder: `${CLAUDE_PLUGIN_ROOT}/scripts`
in Claude Code; in Codex, the `scripts/` folder two levels above this SKILL.md.
Follow the **gitless** skill throughout (read it first if you haven't yet).

The user wants to redo — step forward again after undoing. Run, with the number
of steps if they gave one (default 1):

`bash "<scripts>/redo.sh" [steps]`

Relay the friendly confirmation. This is the partner to `undo`. Orient by time,
not by checkpoint names.
