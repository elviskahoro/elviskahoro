# Plan: Symlink Dotfiles Setup Script

**Status:** Done
**Date:** 2026-03-24

## Context

The dotfiles repo at `~/Documents/elviskahoro/elviskahoro/` contains config files that should be symlinked to their canonical locations. All home directory dotfiles were regular files (not symlinks), so edits weren't tracked in the repo. A `setup.sh` script was created to automate the symlinking.

During implementation, the repo versions of several files were outdated compared to the local copies (`.bashrc`, `.gitconfig`, `.zshrc`, `.zprofile`). These were replaced with the backup versions before pushing.

## What was built

- `~/Documents/elviskahoro/elviskahoro/setup.sh`

## Implementation

### Script structure

```bash
#!/usr/bin/env bash
set -euo pipefail
```

1. **Parse args** - `--dry-run` flag to preview without changes
2. **Define variables** - `DOTFILES_DIR`, `BACKUP_DIR` (lazy-created only if needed)
3. **Define mappings** - Array of 19 relative paths (source and target share the same relative path from repo/home)
4. **Main loop** for each mapping:
   - If target is already a correct symlink -> skip
   - If target exists (file, dir, or wrong symlink) -> back it up to `$BACKUP_DIR` preserving directory structure
   - Create parent directories (`mkdir -p`)
   - Create symlink (`ln -s`, not `-sf` — conflicts handled explicitly via backup)
5. **Summary** - Print counts and lists of created/skipped/backed-up items. Remove empty backup dir.

### Mapping list (19 items)

**11 dotfiles** (repo root -> `$HOME`):
`.bash_profile`, `.bashrc`, `.gitconfig`, `.gitignore_global`, `.ideavimrc`, `.inputrc`, `.profile`, `.vimrc`, `.zprofile`, `.zshenv`, `.zshrc`

**2 directories** (repo root -> `$HOME`):
`.vim/`, `.warp/`

**6 nested config files** (file-by-file, not whole dirs):
`.config/karabiner.json`, `.config/.tmux.conf`, `.config/vi-mode.sh`, `.config/bash_profile.sh`, `.config/starship.toml`, `.config/git/.gitmessage`

### Key design decisions

- **Backup dir created lazily** - only if something actually needs backing up
- **Use `ln -s` (not `-sf`)** - conflicts handled explicitly via backup, safer
- **Dry-run** prints all actions prefixed with `[DRY RUN]` without executing
- **All paths quoted** to handle potential spaces
- **BSD-compatible** - no GNU-specific flags
- **VS Code files excluded** - will be handled separately via `vscode/` workflow

### Additional fixes during implementation

- Removed stale `alias claude=` from `.zshrc` (path didn't exist)
- Added guard for cargo env in `.zshenv` (`[[ -f ]] && source`)
- Replaced repo versions of `.bashrc`, `.gitconfig`, `.zshrc`, `.zprofile` with local backup versions (repo was outdated)
- Added missing `.warp/keybindings.yaml` to repo

## Verification

All verified:
1. `ls -la ~/.zshrc` shows symlink -> repo
2. `ls -la ~/.gitconfig` shows symlink -> repo
3. Running script again shows all items as "already linked" (idempotent)
4. `--dry-run` produces output without changes
5. New terminal session works without errors
6. Backups saved to `~/.dotfiles_backup_20260324_072610/`
