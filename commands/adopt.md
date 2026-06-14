---
description: Use gitless in the current folder (an existing project or one with work already)
allowed-tools: Bash
---

The user wants to manage the current folder with gitless.

1. Run: `bash "${CLAUDE_PLUGIN_ROOT}/scripts/adopt.sh"`
   It prints `PROJECT: <path>` — you're now working in that project.
2. Set up the project's notes file:
   - If the project has **no CLAUDE.md**, run `/init` to document it.
   - Then add the gitless section: `bash "${CLAUDE_PLUGIN_ROOT}/scripts/write-claude-md.sh"`
3. Save so it's backed up: `bash "${CLAUDE_PLUGIN_ROOT}/scripts/save.sh" "Set up gitless notes"`

If GitHub isn't connected and they want cloud backup, run /setup. Relay the
friendly output. No git jargon — see the gitless skill.
