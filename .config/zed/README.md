# Zed config

How Zed config in this repo actually reaches `~/.config/zed/` and
`~/Library/Application Support/Zed/`, and why themes need a manual step.

## Two different directories Zed reads from

- `~/.config/zed/` — `settings.json`, `keymap.json`. Plain files Zed reads
  directly. **Symlink-able**, and that's how this repo ships them.
- `~/Library/Application Support/Zed/extensions/` — where Zed actually loads
  extensions (including themes) from. **Not** `~/.config/zed/extensions/`.
  Zed never reads that path; a symlink placed there does nothing. Extensions
  can only be installed through the Zed GUI (Command Palette), never by
  hand-copying or symlinking files into place.

## `settings.json` / `keymap.json`

Managed by `setup.sh symlinks`:

```
dotfiles/.config/zed/settings.json -> ~/.config/zed/settings.json
dotfiles/.config/zed/keymap.json   -> ~/.config/zed/keymap.json
```

Edit the files in this repo; the symlink means Zed picks up changes
immediately. Re-run `setup.sh symlinks` on a new machine to (re)create both
links — check `symlinks_mappings` in `setup.sh` if a link ever goes missing.

`keymap-default.json`, `settings-default.json`, `keyboard_shortcuts-default-zed.json`,
`keymap-skill.md`, `settings-skill-vscode.md` are reference material only
(Zed's shipped defaults + notes) — never symlinked, never read by Zed.

## Themes (`themes/monokai-spectrum/`)

`monokai-spectrum` is a git submodule: the source of a custom Zed theme
extension (`Monokai Pro (Filter Spectrum)`) — see `.gitmodules`. It is
**not** installed just by being cloned/symlinked here. Because Zed only
loads extensions from `~/Library/Application Support/Zed/extensions/`,
getting this theme into Zed requires a one-time manual step per machine:

1. Open Zed → Command Palette (`Cmd+Shift+P`) → `zed: install dev extension`
2. Select this folder: `dotfiles/.config/zed/themes/monokai-spectrum`
3. Zed copies/links it into its real extensions directory and the theme
   becomes selectable as `Monokai Pro (Filter Spectrum)`.

If you edit `themes/monokai-spectrum/themes/monokai-spectrum.json`, re-run
`zed: install dev extension` (or `zed: extensions` → reload) to pick up the
change — Zed does not watch dev extension sources for edits.

The extension manifest (`themes/monokai-spectrum/extension.toml`) must
declare `themes = ["themes/<file>.json"]` or Zed won't see any theme in the
folder at all, even after "install dev extension" succeeds.

### `Monokai Vibrant Amped` vs `Monokai Pro (Filter Spectrum)`

These are two unrelated things that are easy to confuse:

- **`Monokai Pro (Filter Spectrum)`** — the custom port in this repo
  (`themes/monokai-spectrum/`), installed as a dev extension per above.
- **`Monokai Vibrant Amped`** — a *different*, third-party theme published
  to Zed's public extension store (by Chadderbox / MonokaiVibrantAmped),
  unrelated to anything in this repo.

Check `settings.json`'s `theme.dark` value to see which one is actually
active — don't assume it's the custom port just because this repo has a
`themes/` directory. To use the third-party one: Command Palette →
`zed: extensions` → search "Monokai Vibrant Amped" → Install.

## Keybinding syntax gotchas

Two easy-to-miss rules in `keymap.json` that look valid but silently do
nothing (or the wrong thing):

- **`shift-` only combines with letters.** For punctuation, `shift-cmd--`
  (meant as Shift+Cmd+Minus) is not valid syntax and never matches anything —
  Zed wants the character Shift actually produces instead: `cmd-_` for
  Shift+Cmd+Minus, `cmd-+` for Shift+Cmd+Equal. Same pattern for any other
  shifted symbol. See [Keybinding Syntax](https://zed.dev/docs/key-bindings#keybinding-syntax).
- **More specific context wins, silently.** A binding under `"context":
  "Editor"` overrides an identical keystroke bound under `"context":
  "Workspace"` whenever the editor is focused — no warning, it just fires the
  Editor one. Before adding a shortcut, grep this file for the same key
  string across all context blocks (remember punctuation keys per the rule
  above — `cmd-_` and `cmd-+` are the forms to search for, not
  `shift-cmd--`/`shift-cmd-=`).

## Stray files to watch for

`~/.config/zed/keymap_backup.json` (a plain file, not a symlink) can appear
from earlier manual troubleshooting. It's inert — Zed never reads it — but
delete it if you find it, it's just clutter.
