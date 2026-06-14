---
description: Start building a new feature in a separate, safe space
argument-hint: <what you want to build>
allowed-tools: Bash
---

The user wants to build: "$ARGUMENTS".

Open a separate space for it:

`bash "${CLAUDE_PLUGIN_ROOT}/scripts/feature-start.sh" "$ARGUMENTS"`

The script prints a line `WORKSPACE: <path>`. From now on, do all work for this
feature in that folder — that's what keeps the real project untouched. Tell the
user plainly that you've opened a separate space and their project stays safe.
Don't mention branches or worktrees.
