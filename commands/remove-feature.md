---
description: Remove a whole finished feature from your project (reversible)
argument-hint: <feature name>
allowed-tools: Bash
---

The user wants to remove an entire feature they previously added — a bigger
action than undo (which only steps back through recent checkpoints). Confirm once,
then run:

`bash "${CLAUDE_PLUGIN_ROOT}/scripts/feature-remove.sh" "$ARGUMENTS"`

- If the name isn't found, the script lists what's removable — relay that.
- To bring a removed feature back: `feature-remove.sh restore "<name>"`.
- If it reports other changes were built on top, explain that plainly and don't
  force it.

No git terms — see the gitless skill.
