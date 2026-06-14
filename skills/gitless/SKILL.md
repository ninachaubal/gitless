---
name: gitless
description: Plain-language version control for people who don't know or want to deal with git. Use in a gitless project (its CLAUDE.md has a "uses gitless" note) and whenever the user wants to get set up, start a project, save or back up work, build/add/make/change/finish/remove a feature, undo or redo, or check where things stand — i.e. anytime you'd otherwise run git or gh, or are about to build something new. Translates all git jargon into everyday words.
---

# gitless — version control without the vocabulary

This plugin is for someone building a personal project who wants the safety of
version control without learning git. Your job is to give them that safety while
**never making them think about git**. They should feel like they're using a tool
that remembers their work, lets them try things safely, and backs everything up —
not like they're driving git with a translator.

## The prime directive: no git jargon, ever

The user must never see the words **commit, branch, merge, push, pull, rebase,
stash, HEAD, origin, worktree, PR, or pull request** in your output. Don't show
raw `git` output either — route everything through the scripts in this plugin,
which already speak plainly. When you summarize, use everyday language.

Translate like this:

| what git calls it | what you say |
| --- | --- |
| commit | **save** / "saved a checkpoint" |
| a branch / worktree | "a **separate space** for this feature; your project stays untouched" |
| main | "your **project**" / "the real version" |
| push / backed up to origin | "**backed up** to GitHub" |
| pull / sync | "**got the latest**" |
| open a PR and merge | "**added it to your project**" / "made it official" |
| revert / reset | "**undo**" / "go back to before" |
| merge conflict | "two changes touch the same spot — I need you to pick" |

Never say "PR" or "pull request." Since there's no reviewer on a personal
project, finishing a feature is just **adding it to your project** — the pull
request is an internal detail the user never needs to hear about.

## The one allowed vendor word: "GitHub"

**GitHub is fine to say.** Once the user has an account, "GitHub" no longer refers
to a git concept — it's a *vendor they have an account with*, like Dropbox or
iCloud. Use it as the place their code lives: "I backed this up to your GitHub,"
"your project is on GitHub at <url>." Just don't let it slide into git-concept
talk (no "GitHub branch," "push to GitHub origin," etc.).

When someone is brand new, explain it as a backup service, not a git host:
> "GitHub is a free service that keeps a safe copy of your code in the cloud, so
> you can't lose it and you can get to it from anywhere. Let's create an account
> at https://github.com — then I'll connect this project to it."

## The tools (always use these, never raw git)

All scripts live in `${CLAUDE_PLUGIN_ROOT}/scripts/` and print friendly output.
Run them with `bash` and relay their output as-is (or summarize in plain words).
**They work from anywhere inside the project** — `save`, `done`, and `status`
find the feature in progress on their own. So you never need to `cd` into a
feature folder to run them, and you never need to read a script's source to
figure out how to call it. Just call it.

- `bootstrap.sh` — check/repair the toolchain (git, GitHub CLI, sign-in). `/setup`
- `new-project.sh <name>` — make a project: folder, GitHub backup, sensible ignore rules. `/new-project`
- `feature-start.sh <description>` — open a separate space to build a feature. `/feature`
- `save.sh [note]` — save a checkpoint of the current work. `/save`
- `undo.sh [steps|list]` — step back through recent checkpoints (recoverably). `/undo`
- `redo.sh [steps]` — step forward again after an undo. `/redo`
- `feature-remove.sh <name>` — remove a whole finished feature from the project (reversible). `/remove-feature`
- `feature-ship.sh [continue]` — add the finished feature to the project + back up. `/done`
- `update-gitignore.sh <stack>...` — quietly keep ignore rules sane for the stack in use.
- `status.sh` — plain-language "where things stand." `/status`
- `help.sh` — show the user what they can do + the usual flow. `/help`

## How to behave

**Keep the project safe and synced.** The project's main copy always reflects the
"real version" and stays backed up to GitHub. Feature work happens in a separate
space so the real version never breaks.

**After creating a project, move into it.** `new-project.sh` prints
`PROJECT: <path>`; `cd` into that path so the session is working inside the new
project (creating it doesn't move the session there on its own). Even if that
`cd` doesn't stick, the scripts remember the active project and step into it
automatically — so you never need to chase the right folder.

**When the user seems lost, show them the ropes.** If they ask how this works,
what they can do, or seem unsure ("how do I…", "what can I do", "remind me", "I
forgot how this works"), run `help.sh` (or point them to /help) and answer their
question from it in plain language.

**Ignore rules update themselves.** When a project picks up a language or
framework (a `package.json`, `requirements.txt`, `Cargo.toml`, `go.mod`, etc.), a
background hook quietly adds sensible ignore rules for it — you don't need to do
anything, and don't mention it unless the user asks.

**Save often (auto + manual).** Quietly run `save.sh` at natural stopping points —
after a working change, before anything risky, before an undo. Also save whenever
the user asks ("save that," "/save"). The user should never lose work. Keep
auto-save quiet; don't announce every checkpoint — mention it only when useful.

**Before building anything new, open a feature first — never build on the real
project.** This is the most common mistake to avoid. When you're on the real
project (not already in a feature) and the user asks to add, build, make, create,
or change something — even casually ("let's add a dark mode," "can you make the
header sticky") — do **not** start editing code. First treat it as a new feature:
confirm *once* ("Want me to set this up as a separate feature so your project
stays safe while we work?"), then run `feature-start.sh` and do the work in the
space it opens. Once you're inside a feature, just keep working there — don't ask
again on every small change. `/feature` and `/done` are there for users who'd
rather drive it themselves.

**When you're in a feature, put file edits in its space.** After
`feature-start.sh` prints `WORKSPACE: <path>`, make your *file edits* under that
path — that's what keeps the real project untouched. (Only your file edits need
the path; the save/finish/status scripts find the feature themselves.) Tell the
user plainly: "I've opened a separate space for this — your project stays
untouched while we work." Re-derive feature state from `status.sh`, never from
memory, and never keep your own state file.

**There are two kinds of "undo" — keep them separate.**

1. **undo / redo (the small, everyday kind).** Like Undo/Redo in a writing app:
   linear, one checkpoint at a time, within the current piece of work. Triggered
   by "undo," "undo that," "go back," "redo." Use `undo.sh` / `redo.sh`. People
   try lots of approaches fast, so treat this as "go back and try something
   different" — nothing is thrown away (undo is itself undoable). **Orient by
   time, never by name** ("back to about 5 minutes ago"): auto-saves have no
   meaningful names, so never ask the user to pick a checkpoint by name. Undo
   stops at the start of the current feature — it won't spill into the rest of
   the project. (Under the hood this rewinds and quietly re-syncs the backup;
   the user never sees any of that.)

2. **remove a feature (the big, named kind).** "Get rid of the dark mode
   feature," "drop the login feature." This pulls a whole *finished* feature back
   out of the real project. Use `feature-remove.sh <name>`. Here names *do* work,
   because features are the one thing the user named. It's reversible — offer to
   "bring it back" (`feature-remove.sh restore <name>`).

Disambiguate by what they reference: a bare "undo" → the small kind (most recent
step); naming a feature that's already part of the project → the big kind.

**Finishing a feature.** Confirm it's done ("Ready to add this to your real
project?"), then run `feature-ship.sh`. It merges quietly and backs up. On
success, say something like: "Done — your '<feature>' is now part of the project
and backed up. I cleaned up the workspace."

## Merge conflicts: the one place to slow down

Try to add the feature silently first. If two changes touch the same spot,
`feature-ship.sh` stops and lists the affected files. **Do not show conflict
markers or git terms.** Walk the user through each spot in plain language:

> "Two changes both touched **login.js**. Which should win — the version you just
> built, or the version already in your project?"

Apply their pick per file with `resolve.sh <file> mine|project` (`mine` = the
feature they just built, `project` = what was already there), then run
`feature-ship.sh continue` to finish. If they're unsure, offer to show what each
version does in plain terms.

## Never do these

- Never rewrite history, force-anything, or delete the user's work irrecoverably.
- Never leave the project's real version broken or unbacked-up.
- Never expose a `.git` internal, a hash, or a branch name to the user.
- Never block on something the user must do themselves (like signing in to
  GitHub) — hand it off clearly using `! <command>` so the result lands in-session.
