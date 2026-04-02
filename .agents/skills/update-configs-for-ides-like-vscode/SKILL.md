---
name: update-configs-for-ides-like-vscode
description: Parse a VS Code fork's live settings and keybindings, then propagate changes into the shared generic config and editor-specific overrides in the dotfiles repo.
version: 2.0.0
metadata:
  author: elviskahoro
---

# VS Code Config Sync

Sync editor settings and keybindings between VS Code forks (Cursor, Positron, VSCodium) and the dotfiles repo's layered config structure.

## When to Use

- After changing settings or keybindings in any editor and wanting to persist them
- When setting up a new VS Code fork
- When auditing drift between editors
- When the user says "sync my settings", "update my config", or names a specific editor

## Architecture

The dotfiles repo at `~/Documents/elviskahoro/dotfiles/vscode/` uses a layered config:

```
vscode/
├── compose.sh                  # Merges generic + editor → generated/, optionally symlinks
├── .gitignore                  # Ignores generated/
├── generic/
│   ├── settings.json           # Shared across ALL editors
│   └── keybindings.json        # Shared keybinding entries
├── cursor/
│   ├── settings.json           # Cursor-only setting overrides
│   └── keybindings.json        # Cursor-only keybinding entries
├── positron/
│   ├── settings.json           # Positron-only setting overrides
│   └── keybindings.json        # Positron-only keybinding entries
├── vscodium/
│   ├── settings.json           # VSCodium-only setting overrides
│   └── keybindings.json        # VSCodium-only keybinding entries
└── generated/                  # OUTPUT: composed files, gitignored
    ├── cursor/
    │   ├── settings.json       # Full merged config, symlinked from Application Support
    │   └── keybindings.json
    ├── positron/
    │   ├── settings.json
    │   └── keybindings.json
    └── vscodium/
        ├── settings.json
        └── keybindings.json
```

### Data Flow

```
generic/ + editor/  →  compose.sh  →  generated/<editor>/  ←symlink←  ~/Library/Application Support/<Editor>/User/
```

1. Source files (generic + editor-specific) are version-controlled
2. `compose.sh` merges them into `generated/<editor>/`
3. Each editor's Application Support dir symlinks to the generated files
4. Editors read/write the generated files directly
5. This skill parses changes from generated files back into source files

### Compose Rules

- **Settings**: `jq -s '.[0] * .[1]'` — deep merge, editor overrides win
- **Keybindings**: `jq -s '.[0] + .[1]'` — array concat, generic entries first

### compose.sh Usage

```bash
./compose.sh <editor|all> [--link] [--dry-run]

./compose.sh cursor              # generate only
./compose.sh cursor --link       # generate + symlink into Application Support
./compose.sh all                 # generate all editors
./compose.sh all --link          # generate + symlink all
./compose.sh all --link --dry-run  # preview what would happen
```

## Editor Paths (macOS)

| Editor   | App Support Dir | Generated Dir |
|----------|----------------|---------------|
| Cursor   | `~/Library/Application Support/Cursor/User/` | `generated/cursor/` |
| Positron | `~/Library/Application Support/Positron/User/` | `generated/positron/` |
| VSCodium | `~/Library/Application Support/VSCodium/User/` | `generated/vscodium/` |

## Execution Steps

### Step 1: Read generated files and current source files

Since editors are symlinked to `generated/<editor>/`, the generated files ARE the live config. Read in parallel:

1. `generated/<editor>/settings.json` — the live/generated settings
2. `generated/<editor>/keybindings.json` — the live/generated keybindings
3. `generic/settings.json` — shared source
4. `<editor>/settings.json` — editor-specific source
5. `generic/keybindings.json` — shared source
6. `<editor>/keybindings.json` — editor-specific source

If generated files don't exist yet, run `compose.sh <editor>` first.

If the user doesn't specify an editor, check all editors that have generated files and report which have drifted from their sources.

### Step 2: Diff settings

For settings (JSON objects), classify every key in the generated (live) config:

1. **Compose the expected config** by mentally merging `generic/settings.json` with `<editor>/settings.json` (editor keys override generic).
2. **Compare generated vs composed** to find:
   - **New keys** — present in generated but not in composed (user added via editor UI)
   - **Changed values** — present in both but values differ (user changed via editor UI)
   - **Removed keys** — present in composed but not in generated (user removed via editor UI)

Present a clear summary table to the user before making changes:

```
| Key                          | Status  | Composed Value | Live Value |
|------------------------------|---------|----------------|------------|
| editor.fontSize              | changed | 16             | 14         |
| some.new.setting             | added   | —              | true       |
| old.removed.setting          | removed | "foo"          | —          |
```

### Step 3: Classify setting changes as generic or editor-specific

For each change, determine placement:

- **Generic** if:
  - The setting is a general preference (font, theme, behavior) that should apply everywhere
  - The same change appears in multiple editors
  - It updates an existing generic value to a newer preference

- **Editor-specific** if:
  - It only makes sense for one editor (e.g., `cursor.*` settings, `python.languageServer: "None"` for Positron)
  - It uses an editor-specific extension or feature
  - It overrides a generic value for a specific editor only

**Ask the user when ambiguous.** Present the setting and ask: "Should this go in generic (all editors) or just <editor>?"

### Step 4: Diff keybindings

For keybindings (JSON arrays of objects), compare by matching on `key` + `command` + `when`:

1. **Compose the expected keybindings** by concatenating `generic/keybindings.json` + `<editor>/keybindings.json`.
2. **Compare generated vs composed** to find:
   - **New entries** — in generated but not in composed
   - **Removed entries** — in composed but not in generated
   - **Modified entries** — same `key`+`command` but different `when` clause

Present a summary to the user.

### Step 5: Classify keybinding changes as generic or editor-specific

- **Generic** if:
  - The keybinding is a universal preference (e.g., `cmd+o` → quickOpen, zoom keys)
  - The same binding exists in all or most editors

- **Editor-specific** if:
  - It references an editor-specific command (e.g., `composerMode.agent` for Cursor, `continue.newSession` for Positron)
  - It conflicts with how other editors use the same key

**When moving a keybinding to generic, check other editors' files for conflicts** — the same key combo must not be bound to a different command in another editor's specific file.

### Step 6: Apply changes

After user confirmation:

1. **Update `generic/settings.json`** — add/update/remove generic settings
2. **Update `<editor>/settings.json`** — add/update/remove editor-specific overrides. Remove keys that are now redundant (same value as generic).
3. **Update `generic/keybindings.json`** — add/remove generic keybinding entries
4. **Update `<editor>/keybindings.json`** — add/remove editor-specific entries. Remove entries that are now in generic.
5. **Regenerate** — run `compose.sh <editor>` (or `compose.sh all` if generic changed) to rebuild the generated files from the updated sources.
6. **Verify** — confirm the regenerated output still matches what the user expects.

### Step 7: Cross-editor audit (optional)

If the user asks to sync all editors, or if a generic change was made:

1. For each other editor, regenerate and diff against its previous generated output
2. Flag any new changes introduced by the generic update
3. Offer to update other editors' overrides if needed

## Important Rules

- **JSONC handling**: Generated files may contain comments (JSONC) if the editor added them. Strip comments before comparing. Source files in the dotfiles repo use pure JSON (no comments).
- **Never delete settings from generic without confirmation** — the user may have intentionally set them even if one editor removed them.
- **Preserve JSON formatting** — use consistent 4-space indentation in all source files.
- **Editor-specific settings.json should be minimal** — only keys that differ from generic. If an editor override matches generic, remove it from the override file.
- **Order doesn't matter for settings** (object keys), but **order matters for keybindings** (array entries) — generic entries must come before editor-specific entries in the composed output.
- **Always regenerate after source changes** — after updating any source file, run `compose.sh` to rebuild generated files. The editors are symlinked to generated, so they pick up changes immediately.
