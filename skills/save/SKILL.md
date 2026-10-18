---
name: save
description: Save a checkpoint of your current work and back it up
argument-hint: "[optional note]"
allowed-tools: Bash
disable-model-invocation: true
---

`<scripts>` below is this plugin's `scripts/` folder: `${CLAUDE_PLUGIN_ROOT}/scripts`
in Claude Code; in Codex, the `scripts/` folder two levels above this SKILL.md.
Follow the **gitless** skill throughout (read it first if you haven't yet).

Save the user's current work, passing along their note if they gave one (leave
it off if not):

`bash "<scripts>/save.sh" "<note>"`

Relay the friendly confirmation. Remember you should also do this quietly on your
own at natural stopping points — the user doesn't have to ask every time.
