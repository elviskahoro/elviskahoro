# Spec: Symlink Dotfiles from elviskahoro/elviskahoro

**Date:** 2026-03-24
**Status:** Done
**Goal:** Symlink dotfiles from `~/Documents/elviskahoro/elviskahoro/` to their target locations so that local edits are automatically tracked in the dotfiles repo.

## Context

The repo at `~/Documents/elviskahoro/elviskahoro/` contains dotfiles and config directories that should be symlinked to their canonical locations (mostly `$HOME`). Currently, the home directory has separate copies of these files — not symlinks — so changes aren't tracked.

## Source → Target Mapping

### Dotfiles (source repo → `$HOME`)

| Source file | Symlink location |
|---|---|
| `.bash_profile` | `~/.bash_profile` |
| `.bashrc` | `~/.bashrc` |
| `.gitconfig` | `~/.gitconfig` |
| `.gitignore_global` | `~/.gitignore_global` |
| `.ideavimrc` | `~/.ideavimrc` |
| `.inputrc` | `~/.inputrc` |
| `.profile` | `~/.profile` |
| `.vimrc` | `~/.vimrc` |
| `.zprofile` | `~/.zprofile` |
| `.zshenv` | `~/.zshenv` |
| `.zshrc` | `~/.zshrc` |

### Directories (source repo → `$HOME`)

| Source directory | Symlink location |
|---|---|
| `.vim/` | `~/.vim` |
| `.warp/` | `~/.warp` |

### Nested config files

| Source file | Symlink location |
|---|---|
| `.config/karabiner.json` | `~/.config/karabiner.json` |
| `.config/.tmux.conf` | `~/.config/.tmux.conf` |
| `.config/vi-mode.sh` | `~/.config/vi-mode.sh` |
| `.config/bash_profile.sh` | `~/.config/bash_profile.sh` |
| `.config/starship.toml` | `~/.config/starship.toml` |
| `.config/git/.gitmessage` | `~/.config/git/.gitmessage` |

**Note:** `.config/` is symlinked file-by-file (not the whole directory) because it contains other files managed by various applications.

## Excluded files

- `README.md` — repo documentation, not a dotfile
- `.gitmodules` — git metadata, stays in the repo
- `.config/README.md` — documentation, not a config

## Implementation Plan

### 1. Create a setup script at `~/Documents/elviskahoro/elviskahoro/setup.sh`

The script should:

1. **Define variables:**
   - `DOTFILES_DIR="$HOME/Documents/elviskahoro/elviskahoro"`
   - `BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"`

2. **Backup existing files** before replacing them:
   - For each target that exists and is NOT already a symlink pointing to the correct source, move it to `$BACKUP_DIR` (preserving directory structure).
   - Skip if already correctly symlinked.
   - Print what's being backed up.

3. **Create parent directories** as needed (e.g., `~/.config/git/`, `~/Library/Application Support/Code/User/`).

4. **Create symlinks** using `ln -sf` for each mapping above.

5. **Report results:**
   - List created symlinks.
   - List skipped (already correct) symlinks.
   - List backed-up files and their backup location.
   - If backup dir is empty (nothing was backed up), remove it.

### 2. Script requirements

- **Idempotent:** Safe to run multiple times. Skip already-correct symlinks.
- **Non-destructive:** Always backup before overwriting. Never delete originals without backup.
- **Dry-run mode:** Support `--dry-run` flag that prints what would happen without making changes.
- **No external dependencies:** Pure bash, no `stow`, `rcm`, or other tools.
- **macOS compatible:** Use BSD-compatible flags.

### 3. Script structure

```
#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$HOME/Documents/elviskahoro/elviskahoro"
BACKUP_DIR=""
DRY_RUN=false

# Parse args (--dry-run)
# Define file mappings as arrays
# For each mapping:
#   - Check if symlink already correct → skip
#   - Backup existing file/dir if present
#   - Create parent dirs
#   - Create symlink
# Summary output
```

### 4. Verification

After running the script, verify:
- `ls -la ~/.zshrc` shows symlink to the dotfiles repo
- `ls -la ~/.gitconfig` shows symlink to the dotfiles repo
- Opening a new terminal session works without errors
- `git -C ~/Documents/elviskahoro/elviskahoro status` shows changes when a dotfile is edited

## Risks and mitigations

| Risk | Mitigation |
|---|---|
| Overwriting active shell config breaks terminal | Backup dir preserves originals; new terminal test before closing current |
| VS Code settings path has spaces | Quote all paths in the script |
| `.config/` dir doesn't exist yet | Script creates parent dirs |
| Running script twice creates nested symlinks | Check if target is already correct symlink before acting |
| Karabiner expects specific permissions on config | Symlinks inherit source permissions; verify Karabiner still works post-setup |
