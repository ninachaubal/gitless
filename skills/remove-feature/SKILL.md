---
name: remove-feature
description: Remove a whole finished feature from your project (reversible)
argument-hint: "<feature name>"
allowed-tools: Bash
disable-model-invocation: true
---

`<scripts>` below is this plugin's `scripts/` folder: `${CLAUDE_PLUGIN_ROOT}/scripts`
in Claude Code; in Codex, the `scripts/` folder two levels above this SKILL.md.
Follow the **gitless** skill throughout (read it first if you haven't yet).

The user wants to remove an entire feature they previously added — a bigger
action than undo (which only steps back through recent checkpoints). Confirm once,
then run it with the feature's name:

`bash "<scripts>/feature-remove.sh" "<feature name>"`

- If the name isn't found, the script lists what's removable — relay that.
- To bring a removed feature back: `bash "<scripts>/feature-remove.sh" restore "<name>"`.
- If it reports other changes were built on top, explain that plainly and don't
  force it.

No git terms.
