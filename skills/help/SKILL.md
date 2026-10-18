---
name: help
description: Show what you can do with gitless and the usual workflow
allowed-tools: Bash
disable-model-invocation: true
---

`<scripts>` below is this plugin's `scripts/` folder: `${CLAUDE_PLUGIN_ROOT}/scripts`
in Claude Code; in Codex, the `scripts/` folder two levels above this SKILL.md.
Follow the **gitless** skill throughout (read it first if you haven't yet).

The user wants a reminder of how gitless works. Run:

`bash "<scripts>/help.sh"`

Relay it as-is. If they then ask a specific "how do I X" question, answer from it
in plain language — no git jargon.
