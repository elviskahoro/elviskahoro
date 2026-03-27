#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$HOME/Documents/elviskahoro/dotfiles"
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
DRY_RUN=false

# Parse args
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    *) echo "Unknown argument: $arg"; echo "Usage: $0 [--dry-run]"; exit 1 ;;
  esac
done

# Define mappings: relative paths from DOTFILES_DIR -> $HOME
mappings=(
  # Dotfiles (repo root -> $HOME)
  ".bash_profile"
  ".bashrc"
  ".gitconfig"
  ".gitignore_global"
  ".ideavimrc"
  ".inputrc"
  ".profile"
  ".vimrc"
  ".zprofile"
  ".zshenv"
  ".zshrc"
  # Directories (repo root -> $HOME)
  ".vim"
  ".warp"
  # Nested config files (file-by-file)
  ".config/karabiner.json"
  ".config/.tmux.conf"
  ".config/vi-mode.sh"
  ".config/bash_profile.sh"
  ".config/starship.toml"
  ".config/git/.gitmessage"
)

# Counters and lists for summary
created=()
skipped=()
backed_up=()
backup_dir_created=false

ensure_backup_dir() {
  if [[ "$backup_dir_created" == false ]]; then
    if [[ "$DRY_RUN" == false ]]; then
      mkdir -p "$BACKUP_DIR"
    fi
    backup_dir_created=true
  fi
}

log() {
  if [[ "$DRY_RUN" == true ]]; then
    echo "[DRY RUN] $1"
  else
    echo "$1"
  fi
}

for item in "${mappings[@]}"; do
  source="$DOTFILES_DIR/$item"
  target="$HOME/$item"

  # Verify source exists
  if [[ ! -e "$source" ]]; then
    echo "WARNING: Source does not exist, skipping: $source"
    continue
  fi

  # Check if target is already a correct symlink
  if [[ -L "$target" ]]; then
    existing_target="$(readlink "$target")"
    if [[ "$existing_target" == "$source" ]]; then
      skipped+=("$item")
      continue
    fi
  fi

  # Backup existing file/dir/symlink if present
  if [[ -e "$target" || -L "$target" ]]; then
    ensure_backup_dir
    backup_path="$BACKUP_DIR/$item"
    backup_parent="$(dirname "$backup_path")"
    log "Backing up: $target -> $backup_path"
    if [[ "$DRY_RUN" == false ]]; then
      mkdir -p "$backup_parent"
      mv "$target" "$backup_path"
    fi
    backed_up+=("$item")
  fi

  # Create parent directory
  target_parent="$(dirname "$target")"
  if [[ ! -d "$target_parent" ]]; then
    log "Creating directory: $target_parent"
    if [[ "$DRY_RUN" == false ]]; then
      mkdir -p "$target_parent"
    fi
  fi

  # Create symlink
  log "Linking: $target -> $source"
  if [[ "$DRY_RUN" == false ]]; then
    ln -s "$source" "$target"
  fi
  created+=("$item")
done

# Summary
echo ""
echo "=== Summary ==="
echo "Created: ${#created[@]}"
for item in "${created[@]:+"${created[@]}"}"; do
  echo "  + $item"
done

echo "Skipped (already linked): ${#skipped[@]}"
for item in "${skipped[@]:+"${skipped[@]}"}"; do
  echo "  - $item"
done

echo "Backed up: ${#backed_up[@]}"
for item in "${backed_up[@]:+"${backed_up[@]}"}"; do
  echo "  ~ $item"
done

if [[ ${#backed_up[@]} -gt 0 ]]; then
  echo ""
  echo "Backups saved to: $BACKUP_DIR"
fi

# Remove empty backup dir
if [[ "$DRY_RUN" == false && "$backup_dir_created" == true && -d "$BACKUP_DIR" ]]; then
  if [[ -z "$(ls -A "$BACKUP_DIR")" ]]; then
    rmdir "$BACKUP_DIR"
  fi
fi
