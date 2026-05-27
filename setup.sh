#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="${HOME}/Documents/elviskahoro/dotfiles"
BACKUP_DIR="${HOME}/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
DRY_RUN=false

usage() {
  cat <<EOF
Usage: $0 [--dry-run] [command]

Commands:
  (none)      Run all setup steps
  symlinks    Create dotfile symlinks only
  copies      Copy non-symlinkable files (e.g. Beacon sidecar runtime files)
  mcp         Sync MCP server configs to Claude Code CLI and Codex
  help        Show this help message

Options:
  --dry-run   Preview changes without applying them
EOF
}

# --- Symlinks -----------------------------------------------------------------

symlinks_mappings=(
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
  # Beacon sidecar plist — symlink is fine, launchctl reads it at load time.
  # The runtime files (otelcol.yaml, run.sh) are installed via copy_mappings
  # below because macOS TCC blocks launchd-spawned processes from reading
  # anything under ~/Documents/.
  "Library/LaunchAgents/com.beacon.sidecar.otlp.user.plist"
  # Nested config files (file-by-file)
  ".config/karabiner.json"
  ".config/.tmux.conf"
  ".config/vi-mode.sh"
  ".config/bash_profile.sh"
  ".config/starship.toml"
  ".config/git/.gitmessage"
  ".config/zed/settings.json"
)

backup_dir_created=false

ensure_backup_dir() {
  if [[ ${backup_dir_created} == false ]]; then
    if [[ ${DRY_RUN} == false ]]; then
      mkdir -p "${BACKUP_DIR}"
    fi
    backup_dir_created=true
  fi
}

log() {
  if [[ ${DRY_RUN} == true ]]; then
    echo "[DRY RUN] $1"
  else
    echo "$1"
  fi
}

cmd_symlinks() {
  local created=()
  local skipped=()
  local backed_up=()

  for item in "${symlinks_mappings[@]}"; do
    source="${DOTFILES_DIR}/${item}"
    target="${HOME}/${item}"

    # Verify source exists
    if [[ ! -e ${source} ]]; then
      echo "WARNING: Source does not exist, skipping: ${source}"
      continue
    fi

    # Check if target is already a correct symlink
    if [[ -L ${target} ]]; then
      existing_target="$(readlink "${target}")"
      if [[ ${existing_target} == "${source}" ]]; then
        skipped+=("${item}")
        continue
      fi
    fi

    # Backup existing file/dir/symlink if present
    if [[ -e ${target} || -L ${target} ]]; then
      ensure_backup_dir
      backup_path="${BACKUP_DIR}/${item}"
      backup_parent="$(dirname "${backup_path}")"
      log "Backing up: ${target} -> ${backup_path}"
      if [[ ${DRY_RUN} == false ]]; then
        mkdir -p "${backup_parent}"
        mv "${target}" "${backup_path}"
      fi
      backed_up+=("${item}")
    fi

    # Create parent directory
    target_parent="$(dirname "${target}")"
    if [[ ! -d ${target_parent} ]]; then
      log "Creating directory: ${target_parent}"
      if [[ ${DRY_RUN} == false ]]; then
        mkdir -p "${target_parent}"
      fi
    fi

    # Create symlink
    log "Linking: ${target} -> ${source}"
    if [[ ${DRY_RUN} == false ]]; then
      ln -s "${source}" "${target}"
    fi
    created+=("${item}")
  done

  # Summary
  echo ""
  echo "=== Symlinks ==="
  echo "Created: ${#created[@]}"
  for item in "${created[@]:+"${created[@]}"}"; do
    echo "  + ${item}"
  done

  echo "Skipped (already linked): ${#skipped[@]}"
  for item in "${skipped[@]:+"${skipped[@]}"}"; do
    echo "  - ${item}"
  done

  echo "Backed up: ${#backed_up[@]}"
  for item in "${backed_up[@]:+"${backed_up[@]}"}"; do
    echo "  ~ ${item}"
  done

  if [[ ${#backed_up[@]} -gt 0 ]]; then
    echo ""
    echo "Backups saved to: ${BACKUP_DIR}"
  fi

  # Remove empty backup dir
  if [[ ${DRY_RUN} == false && ${backup_dir_created} == true && -d ${BACKUP_DIR} ]]; then
    if [[ -z "$(ls -A "${BACKUP_DIR}" || true)" ]]; then
      rmdir "${BACKUP_DIR}"
    fi
  fi
}

# --- Copy mappings ------------------------------------------------------------
# Files that must exist as real files on the install side (not symlinks) because
# macOS TCC blocks launchd-spawned processes from reading anything whose final
# resolved path is under ~/Documents/. Re-run `setup.sh copies` after edits.

copy_mappings=(
  ".beacon/sidecar/otelcol.yaml"
  ".beacon/sidecar/run.sh"
)

cmd_copies() {
  local copied=()
  local skipped=()

  for item in "${copy_mappings[@]}"; do
    source="${DOTFILES_DIR}/${item}"
    target="${HOME}/${item}"

    if [[ ! -e ${source} ]]; then
      echo "WARNING: Source does not exist, skipping: ${source}"
      continue
    fi

    target_parent="$(dirname "${target}")"
    if [[ ! -d ${target_parent} ]]; then
      log "Creating directory: ${target_parent}"
      if [[ ${DRY_RUN} == false ]]; then
        mkdir -p "${target_parent}"
      fi
    fi

    # Skip if target is already a regular file with identical content.
    if [[ -f ${target} && ! -L ${target} ]] && cmp -s "${source}" "${target}"; then
      skipped+=("${item}")
      continue
    fi

    log "Copying: ${source} -> ${target}"
    if [[ ${DRY_RUN} == false ]]; then
      cp "${source}" "${target}"
      # Preserve executable bit from source.
      if [[ -x ${source} ]]; then
        chmod +x "${target}"
      fi
    fi
    copied+=("${item}")
  done

  echo ""
  echo "=== Copies ==="
  echo "Copied: ${#copied[@]}"
  for item in "${copied[@]:+"${copied[@]}"}"; do
    echo "  + ${item}"
  done
  echo "Skipped (unchanged): ${#skipped[@]}"
  for item in "${skipped[@]:+"${skipped[@]}"}"; do
    echo "  - ${item}"
  done
}

# --- MCP Sync ----------------------------------------------------------------

cmd_mcp() {
  echo ""
  echo "=== MCP Config Sync ==="
  if [[ ${DRY_RUN} == true ]]; then
    echo "[DRY RUN] Would run: scripts/sync-mcp-config"
  else
    if "${DOTFILES_DIR}/scripts/sync-mcp-config"; then
      echo "MCP sync completed."
    else
      echo "WARNING: MCP sync failed (non-fatal)." >&2
    fi
  fi
}

# --- Main ---------------------------------------------------------------------

# Parse flags and command
COMMAND=""
for arg in "$@"; do
  case "${arg}" in
  --dry-run) DRY_RUN=true ;;
  help | --help | -h)
    usage
    exit 0
    ;;
  *)
    if [[ -z ${COMMAND} ]]; then
      COMMAND="${arg}"
    else
      echo "Unknown argument: ${arg}"
      usage
      exit 1
    fi
    ;;
  esac
done

case "${COMMAND:-all}" in
all)
  cmd_symlinks
  cmd_copies
  cmd_mcp
  ;;
symlinks) cmd_symlinks ;;
copies) cmd_copies ;;
mcp) cmd_mcp ;;
*)
  echo "Unknown command: ${COMMAND}"
  usage
  exit 1
  ;;
esac
