---
name: feature
description: Start building a new feature in a separate, safe space
argument-hint: "<what you want to build>"
allowed-tools: Bash
disable-model-invocation: true
---

`<scripts>` below is this plugin's `scripts/` folder: `${CLAUDE_PLUGIN_ROOT}/scripts`
in Claude Code; in Codex, the `scripts/` folder two levels above this SKILL.md.
Follow the **gitless** skill throughout (read it first if you haven't yet).

The user wants to build something new. Open a separate space for it, passing a
short description of what they want to build (if they didn't say, ask):

`bash "<scripts>/feature-start.sh" "<description>"`

The script prints a line `WORKSPACE: <path>`. From now on, do all work for this
feature in that folder — that's what keeps the real project untouched. Tell the
user plainly that you've opened a separate space and their project stays safe.
Don't mention branches or worktrees.
