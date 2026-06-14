# gitless

Plain-language version control for people who don't know — or don't want to deal
with — git. It gives someone building a personal project the safety net of version
control (saved checkpoints, cloud backup, safe spaces to experiment, real undo)
without ever showing them git jargon.

It's a Claude Code plugin: a **skill** that teaches Claude to speak plainly and a
set of **scripts** that bundle each git flow into one friendly command.

## What you can do

You never have to learn git. You just talk to Claude — in plain language or with a
slash command; both do the same thing.

| What you want | Just say… | …or run |
| --- | --- | --- |
| Get set up for backups | "set up backups" | `/gitless:setup` |
| Start a new project | "start a new project called my-app" | `/gitless:new-project my-app` |
| Use gitless on a folder you already have | "manage this folder with gitless" | `/gitless:adopt` |
| Build something new | "let's add a dark mode" / "new feature: search" | `/gitless:feature add dark mode` |
| Save your progress | "save" / "save a checkpoint" | `/gitless:save` |
| Step back | "undo" / "go back" | `/gitless:undo` |
| Step forward again | "redo" / "bring it back" | `/gitless:redo` |
| Finish a feature | "this is done" / "ship it" | `/gitless:done` |
| Drop a finished feature | "get rid of the dark mode feature" | `/gitless:remove-feature dark mode` |
| See where things stand | "where are we?" / "is it backed up?" | `/gitless:status` |
| Get a reminder of how this works | "how do I use this?" / "remind me" | `/gitless:help` |

Claude also saves quietly on its own at natural stopping points, so you rarely
have to remember to.

## The workflow

1. **Start a project.** *"Start a new project called recipes."* → gitless makes the
   folder, connects a private GitHub backup, and saves a first checkpoint. From
   here your project always has a safe, backed-up "real version."
2. **Build a feature.** *"Let's add a search box."* → gitless opens a *separate
   space* to work in, so your real project can't break while you experiment.
3. **Save checkpoints as you go.** *"save"* — or just keep working; gitless
   checkpoints at natural stopping points. Every checkpoint is backed up.
4. **Change your mind freely.** *"undo"* steps back through checkpoints; *"redo"*
   steps forward. Perfect for trying an approach, backing out, and trying another.
5. **Finish.** *"It's done."* → gitless folds the feature into your real project,
   backs it up, and tidies away the separate space.
6. **Remove it later if you want.** *"Get rid of the search feature."* → gitless
   takes that whole feature back out (and can bring it back).

Under the hood (you never see this): your project's real version stays on `main`
and in sync with your GitHub backup, feature work happens in `.worktrees/<feature>`
and is folded in when you're done, and ignore rules update themselves as you add
languages and frameworks.

## Installing

This repo is its own plugin marketplace. Add it and install:

```
/plugin marketplace add ninachaubal/gitless
/plugin install gitless@ninachaubal
```

Then make a project gitless-managed with `/gitless:new-project <name>` or
`/gitless:adopt`.

## Trying it locally (no install)

From a clone of this repo, load it into a session without installing anything
(session-only — nothing persists when you close it):

```
git clone https://github.com/ninachaubal/gitless
claude --plugin-dir ./gitless
```

The scripts can also be run directly for testing:

```
bash gitless/scripts/bootstrap.sh
```

## Layout

```
.claude-plugin/plugin.json   manifest
skills/gitless/SKILL.md       the behavior + vocabulary (the brain)
commands/*.md                 slash-command entry points (also reached by plain language)
scripts/*.sh                  the friendly git wrappers
scripts/lib/common.sh         shared helpers + plain-language output
hooks/                        auto-updates ignore rules when a stack is detected
```

## Not in scope (yet)

No CI, code review, or multi-contributor flows — this is deliberately for one
person maintaining a personal project. Those can layer on later.
