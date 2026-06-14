---
description: Step forward again after an undo (like Redo in a writing app)
argument-hint: [how many steps]
allowed-tools: Bash
---

The user wants to redo — step forward again after undoing. Run:

`bash "${CLAUDE_PLUGIN_ROOT}/scripts/redo.sh" "$ARGUMENTS"`

Relay the friendly confirmation. This is the partner to /undo. Orient by time,
not by checkpoint names.
