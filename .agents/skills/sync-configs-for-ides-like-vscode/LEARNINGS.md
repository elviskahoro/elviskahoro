# Learnings

Accumulated, dated notes from past sync sessions — nonobvious facts, verified
command-ID quirks, and known cleanup debt. Read this before starting a sync
(SKILL.md Step 0). Append a short entry when you discover something worth
remembering: a verified fact, a gotcha that cost time, or debt you noticed but
didn't fix. Keep entries short and dated; link the specific files/commands
involved so a future agent can re-verify rather than trust blindly.

## How to verify a command ID before trusting it

Cursor, Positron, and VSCodium all fork VS Code's upstream, so most core
`workbench.*` / `editor.*` command IDs are identical across all three — but
each fork also adds its own commands (Cursor: `composerMode.agent`,
`composer.newAgentChat`; Positron: R/data-science-specific commands), and a
fork can in principle rename or drop a core command. Don't assume a command
exists in every editor just because it exists in one — verify:

```bash
grep -rl "<commandId>" "/Applications/<Editor>.app/Contents/Resources/app" 2>/dev/null
```

If a command is missing (or differently named) in one editor, that binding
belongs in `<editor>/keybindings.json` as a per-editor override — not
`generic/keybindings.json`.

## Correction: `vscode/generated/` is NOT gitignored — it's tracked

As of 2026-08-24, there is no `vscode/.gitignore`, and `git ls-files
vscode/generated/` lists every generated settings/keybindings file as
tracked. The Architecture section above (and CLAUDE.md) still call it "OUTPUT:
composed files, gitignored" — that's aspirational/stale, not current fact.
Practical effect: after any sync session that edits source files and reruns
`compose.sh`, the regenerated `generated/<editor>/*.json` files show up as
real tracked diffs and should be staged and committed alongside the source
changes, not left as untracked/ignored working-tree noise.

## Gotcha: one flagged drifted key is often not the only one

When a user (or a prior session) flags a single setting as having drifted
into a generated file outside its source, don't assume it's the only
drift — diff the *whole* generated file against generic+editor composed, not
just the one key mentioned. In one session, a Cursor `generated/settings.json`
had three undocumented live-only keys (`cursor.composer.queueMessageDefaultBehavior`,
`[kson]` formatter, `workbench.editorAssociations` for `*.pdf`) though only the
first had been explicitly flagged. The other two were general prefs that
belonged in `generic/settings.json` and would otherwise have been silently
wiped on the next `compose.sh` run.

## Verified: core maximize/layout commands match across all three editors (2026-07-31)

- `workbench.action.toggleMaximizeEditorGroup` ("maximize pane") — confirmed
  present and identically named in Cursor, Positron, and VSCodium. Safe to
  keep in `generic/keybindings.json`.
- `workbench.action.toggleEditorWidths` ("Toggle Editor Group Sizes") — a
  *different* command that's easy to confuse with the above; it only
  equalizes/toggles the width split between editor groups, it does not
  maximize a pane. `generic/keybindings.json` had `shift+cmd+enter`
  mis-bound to this instead of the maximize command — fixed 2026-07-31.

## Gotcha: a stale editor-specific duplicate can silently override a generic fix

Keybindings compose as `generic + editor` (array concat), and VS Code
resolves same-key conflicts by taking the LAST matching entry when multiple
`when` clauses hold simultaneously. If an editor-specific file has its own
copy of a binding that's *also* in generic, fixing only the generic copy does
nothing observable — the editor-specific duplicate (appended after generic)
still wins in whatever context its `when` clause covers. When fixing a
generic keybinding bug, always also grep the affected key across every
`<editor>/keybindings.json` for a shadowing duplicate, not just generic.

## Cursor: correct command for "add selection to current chat" is `aichat.newchataction`, NOT any `composer.*` command (2026-08-24, corrected same day)

First pass at this (see git history on this file) wrongly concluded
`composer.addsymbolstocomposer` (minified id `NFe`) was "add to current
chat" based on its title (`"New Chat with Selections"`, itself misleading —
titles in this bundle are not reliable) and reading its `run()` in
isolation. That was wrong on two counts, both confirmed live in the running
app, not just from source reading:

1. `composer.addsymbolstocomposer` / `composer.addsymbolstonewcomposer`
   (`NFe`/`Nyn`) unconditionally destructure their *second* argument
   (`t.codeSelections`, `t.locationLinks`) with no null-guard. A plain
   `keybindings.json` entry invokes a command with **no arguments at all**,
   so `t` is `undefined` and it throws
   `Cannot read properties of undefined (reading 'codeSelections')`
   immediately. These two command IDs can never be driven by a static
   keybinding — full stop, regardless of `when` clause.
2. `editor.action.addSymbolToChat` / `editor.action.addSymbolToNewChat`
   (ids `I2r`/`R2r`, menu title "Add Symbol to Current/New Chat...") don't
   crash (they always pass a well-formed `{locationLinks: [...]}` arg to
   `NFe`/`Nyn`), but they resolve the symbol *at the cursor position* via
   the language's definition provider (`X$d` → go-to-definition), not the
   raw selected text. On a plain text selection with no resolvable
   identifier, `locationLinks` comes back empty, `NFe` early-returns without
   attaching anything, and (for the *New Chat* variant specifically) a new
   chat tab still gets created first regardless — confirmed live: "creates
   a new chat successfully but doesn't add the selection to chat."

The actual command wired to Cursor's own built-in "Add to Chat ⌘L" hover
button (the one that appears over a text selection, `editor.contrib.hoverController`
→ class `N6i`, gated by the `hideChatEditTooltip`/"Toolbar on Selection"
setting) is minified id `Lyn`, which resolves to the string
**`"aichat.newchataction"`** — found by tracing the button's click handler
(`n.executeCommand(l, ...)` where `l = isGlass ? GTd : Lyn`) rather than
guessing from any command's title. `Lyn`'s `run(e,t)` just forwards
`(accessor, arg)` through to `composer.startComposerPrompt2` without ever
dereferencing into `arg` unguarded, so it's safe to bind bare with no args.

This is also literally Cursor's stock default for Cmd+L — `cursor/keybindings.json`
had overridden it away to `composer.newAgentChat` since commit `63e296c`
(pre-dating this investigation), which is the actual original root cause:
Cmd+L always opened a *new* chat instead of adding to the current one
because the override discarded the correct stock command. Fix: bind `cmd+l`
straight to `aichat.newchataction`, no `when` clause needed — confirmed
working live (selection gets added to the current chat).

Lesson: for this app, a command's declared `title` is not trustworthy
(multiple unrelated commands share the exact string "Open Chat" or "New
Chat with Selections"). To find the real command behind a UI affordance,
trace the click handler / keybinding registration to its id constant, then
resolve that constant to its string literal (`grep '\bXyz="'`) — don't
infer behavior from the title or from reading one command's `run()` in
isolation.

## Known cleanup debt: positron/keybindings.json is largely a stale copy of generic

As of 2026-07-31, `positron/keybindings.json` (587 lines) duplicates roughly
90% of `generic/keybindings.json` (660 lines) verbatim, rather than
containing only Positron-specific deltas. This predates the generic/override
split and has not been cleaned up. Not resolved — flagged for a future
dedicated dedup pass. Until then, don't assume `positron/keybindings.json`
contains only true overrides; diff it against `generic/keybindings.json`
(`diff <(jq -S . generic/keybindings.json) <(jq -S . positron/keybindings.json)`)
before treating an entry there as intentional.
