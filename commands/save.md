---
description: Save a checkpoint of your current work and back it up
argument-hint: [optional note]
allowed-tools: Bash
---

Save the user's current work:

`bash "${CLAUDE_PLUGIN_ROOT}/scripts/save.sh" "$ARGUMENTS"`

Relay the friendly confirmation. Remember you should also do this quietly on your
own at natural stopping points — the user doesn't have to ask every time.
