---
description: Step back through your recent checkpoints (like Undo in a writing app)
argument-hint: [how many steps | list]
allowed-tools: Bash
---

The user wants to step back. If they're unsure how far, show recent points in time:

`bash "${CLAUDE_PLUGIN_ROOT}/scripts/undo.sh" list`

Then step back (default 1 step):

`bash "${CLAUDE_PLUGIN_ROOT}/scripts/undo.sh" "$ARGUMENTS"`

- Partner command: **/redo** steps forward again. Reassure them nothing is lost.
- Orient the user by **time** ("back to about 5 minutes ago"), never by checkpoint
  names — auto-saves don't have meaningful names.
- This works *within the current piece of work*. If they instead want to drop a
  whole finished feature by name ("get rid of the dark mode feature"), that's a
  different action — use **/remove-feature**.
