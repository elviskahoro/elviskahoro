# Dotfiles

## VS Code Config Sync

When asked to sync, update, or fix VS Code/editor settings or keybindings (for Cursor, Positron, or VSCodium), follow the skill defined in `.agents/skills/update-configs-for-ides-like-vscode/SKILL.md`.

Key points:
- **Never edit `vscode/generated/` files directly** — they are composed outputs
- Source of truth is `vscode/generic/` (shared) + `vscode/<editor>/` (overrides)
- After editing source files, run `./vscode/compose.sh <editor|all> [--link]` to regenerate
- Editors symlink `~/Library/Application Support/<Editor>/User/` to `vscode/generated/<editor>/`
- To pull changes the user made in-editor back into source files, read the full skill for the diff/classify/apply workflow
