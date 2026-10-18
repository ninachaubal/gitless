---
name: undo
description: Step back through your recent checkpoints (like Undo in a writing app)
argument-hint: "[how many steps | list]"
allowed-tools: Bash
disable-model-invocation: true
---

`<scripts>` below is this plugin's `scripts/` folder: `${CLAUDE_PLUGIN_ROOT}/scripts`
in Claude Code; in Codex, the `scripts/` folder two levels above this SKILL.md.
Follow the **gitless** skill throughout (read it first if you haven't yet).

The user wants to step back. If they're unsure how far, show recent points in time:

`bash "<scripts>/undo.sh" list`

Then step back, with the number of steps if they gave one (default 1):

`bash "<scripts>/undo.sh" [steps]`

- Partner command: `redo` steps forward again. Reassure them nothing is lost.
- Orient the user by **time** ("back to about 5 minutes ago"), never by checkpoint
  names — auto-saves don't have meaningful names.
- This works *within the current piece of work*. If they instead want to drop a
  whole finished feature by name ("get rid of the dark mode feature"), that's a
  different action — use the `remove-feature` command.
