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

## Cursor: "add to current chat" vs "new chat" commands for selections (2026-08-24)

Cursor ships two similarly-named composer commands, verified by reading
`workbench.desktop.main.js` (minified IDs `NFe`/`Nyn`) rather than trusting
their (identical, seemingly copy-pasted) internal titles:

- `composer.addsymbolstocomposer` — resolves the *currently selected*
  composer/chat, opens it, and adds the selection/symbols to it. This is
  "add to current chat."
- `composer.addsymbolstonewcomposer` — creates a brand-new composer tab
  first, then internally calls `composer.addsymbolstocomposer` to add the
  selection to that new tab. This is "new chat with selection."
- `composer.newAgentChat` — always opens a fresh empty agent chat (no
  selection handling).

`cursor/keybindings.json` had `cmd+l` bound to `composer.newAgentChat`,
which is why selecting code and pressing Cmd+L always opened a new chat
instead of adding to the open one. Fixed by rebinding `cmd+l` to
`composer.addsymbolstocomposer`.

## Known cleanup debt: positron/keybindings.json is largely a stale copy of generic

As of 2026-07-31, `positron/keybindings.json` (587 lines) duplicates roughly
90% of `generic/keybindings.json` (660 lines) verbatim, rather than
containing only Positron-specific deltas. This predates the generic/override
split and has not been cleaned up. Not resolved — flagged for a future
dedicated dedup pass. Until then, don't assume `positron/keybindings.json`
contains only true overrides; diff it against `generic/keybindings.json`
(`diff <(jq -S . generic/keybindings.json) <(jq -S . positron/keybindings.json)`)
before treating an entry there as intentional.
