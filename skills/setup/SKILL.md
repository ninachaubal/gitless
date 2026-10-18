---
name: setup
description: Check and set up everything needed to keep your work safe and backed up
allowed-tools: Bash
disable-model-invocation: true
---

`<scripts>` below is this plugin's `scripts/` folder: `${CLAUDE_PLUGIN_ROOT}/scripts`
in Claude Code; in Codex, the `scripts/` folder two levels above this SKILL.md.
Follow the **gitless** skill throughout (read it first if you haven't yet).

Make sure the user's machine is ready to save and back up work. Run:

`bash "<scripts>/bootstrap.sh"`

Then, in plain language (no git jargon):
- If something needs installing and the script printed an install command, offer to run it for them (it may ask for their password).
- If they're not signed in to GitHub, walk them through creating a free account and have them run `! gh auth login` so the sign-in happens in this session.
- Once everything reports ready, tell them they can start a project with the `new-project` command.
