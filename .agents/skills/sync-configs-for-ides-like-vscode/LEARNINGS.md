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

## Known cleanup debt: positron/keybindings.json is largely a stale copy of generic

As of 2026-07-31, `positron/keybindings.json` (587 lines) duplicates roughly
90% of `generic/keybindings.json` (660 lines) verbatim, rather than
containing only Positron-specific deltas. This predates the generic/override
split and has not been cleaned up. Not resolved — flagged for a future
dedicated dedup pass. Until then, don't assume `positron/keybindings.json`
contains only true overrides; diff it against `generic/keybindings.json`
(`diff <(jq -S . generic/keybindings.json) <(jq -S . positron/keybindings.json)`)
before treating an entry there as intentional.
