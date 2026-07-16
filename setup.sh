#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="${HOME}/Documents/elviskahoro/dotfiles"
BACKUP_DIR="${HOME}/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
DRY_RUN=false

usage() {
  cat <<EOF
Usage: $0 [--dry-run] [command]

Commands:
  (none)        Run all setup steps
  symlinks      Create dotfile symlinks only
  copies        Copy non-symlinkable files (e.g. Beacon runtime files)
  launchagents  Install Beacon launch-agent plists as real files and load them
  bin           Create ~/.local/bin command shims (gt -> Gas Town, graphite -> Graphite)
  mcp           Sync MCP server configs to Claude Code CLI, Codex user config, and Warp
  help          Show this help message

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
  # NOTE: Beacon launch-agent plists are NOT symlinked. launchd's login-time
  # scan cannot read a plist whose resolved path is under ~/Documents/ (macOS
  # TCC), so a symlinked agent silently fails to load on boot. They are installed
  # as real files and (re)bootstrapped by cmd_launchagents below.
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
#
# Entries are either "path" (same relative path under the repo root and $HOME)
# or "src=>dst" for a renamed copy. The Infisical bootstrap file uses the latter:
# it lives at the repo root as beacon.env (gitignored — carries a service token)
# but deploys to ~/.beacon/sidecar/infisical.env, the real file both launch
# agents source. A symlink here would resolve back under ~/Documents/ and TCC
# would block the launchd-spawned read ("Operation not permitted").

copy_mappings=(
  ".beacon/sidecar/otelcol.yaml"
  ".beacon/sidecar/run.sh"
  ".beacon/braintrust-bridge/bridge.py"
  ".beacon/braintrust-bridge/run.sh"
  # Codex user settings must be a real file. The project-local `.codex/config.toml`
  # stays empty so Codex does not treat telemetry as project config.
  ".codex/user-config.toml=>.codex/config.toml"
  "beacon.env=>.beacon/sidecar/infisical.env"
)

cmd_copies() {
  local copied=()
  local skipped=()

  for item in "${copy_mappings[@]}"; do
    if [[ ${item} == *"=>"* ]]; then
      source="${DOTFILES_DIR}/${item%%=>*}"
      target="${HOME}/${item##*=>}"
    else
      source="${DOTFILES_DIR}/${item}"
      target="${HOME}/${item}"
    fi

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

    # A legacy symlink here (e.g. otelcol.yaml pointing into ~/Documents) must be
    # replaced with a real file: `cp` through a symlink back to the source fails
    # ("identical file") and aborts under `set -e`. Back it up and remove first.
    if [[ -L ${target} ]]; then
      ensure_backup_dir
      backup_path="${BACKUP_DIR}/${item}"
      log "Replacing legacy symlink with real file: ${target}"
      if [[ ${DRY_RUN} == false ]]; then
        mkdir -p "$(dirname "${backup_path}")"
        mv "${target}" "${backup_path}"
      fi
    fi

    log "Copying: ${source} -> ${target}"
    if [[ ${DRY_RUN} == false ]]; then
      cp "${source}" "${target}"
      # Preserve executable bit from source.
      if [[ -x ${source} ]]; then
        chmod +x "${target}"
      fi
      # The Infisical bootstrap file carries a service token — lock it to 0600.
      if [[ "$(basename "${target}")" == "infisical.env" ]]; then
        chmod 600 "${target}"
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

  # Every copied file is consumed by a running launch agent (collector config,
  # launcher, daemon, or the injected secret), so a copy only takes effect after
  # a restart. Kickstart any loaded beacon agent when something actually changed.
  if [[ ${DRY_RUN} == false && ${#copied[@]} -gt 0 ]]; then
    local domain
    domain="gui/$(id -u)"
    for label in com.beacon.sidecar.otlp.user com.beacon.braintrust.bridge.user; do
      if launchctl print "${domain}/${label}" >/dev/null 2>&1; then
        echo "Kickstarting ${label} to pick up copied files"
        launchctl kickstart -k "${domain}/${label}" >/dev/null 2>&1 || true
      fi
    done
  fi
}

# --- Launch agents ------------------------------------------------------------
# launchd's login-time scan of ~/Library/LaunchAgents cannot read a plist whose
# resolved path is under ~/Documents/ (macOS TCC), so a symlinked agent silently
# fails to load on boot/login. Install each plist as a REAL file and
# (re)bootstrap it. Idempotent: an unchanged, already-loaded agent is skipped.
# Re-run `setup.sh launchagents` after editing a plist.

launchagents_mappings=(
  "Library/LaunchAgents/com.beacon.sidecar.otlp.user.plist"
  "Library/LaunchAgents/com.beacon.braintrust.bridge.user.plist"
)

cmd_launchagents() {
  local domain
  domain="gui/$(id -u)"
  local installed=()
  local loaded=()
  local skipped=()

  for item in "${launchagents_mappings[@]}"; do
    source="${DOTFILES_DIR}/${item}"
    target="${HOME}/${item}"
    local label
    label="$(basename "${item}" .plist)"

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

    # Does the plist need (re)writing as a real file?
    local need_copy=false
    if [[ -L ${target} ]]; then
      # Legacy symlink (the load-at-boot bug) — back it up, replace with a copy.
      ensure_backup_dir
      backup_path="${BACKUP_DIR}/${item}"
      log "Replacing legacy symlink with real file: ${target}"
      if [[ ${DRY_RUN} == false ]]; then
        mkdir -p "$(dirname "${backup_path}")"
        mv "${target}" "${backup_path}"
      fi
      need_copy=true
    elif [[ ! -f ${target} ]]; then
      need_copy=true
    elif ! cmp -s "${source}" "${target}"; then
      need_copy=true
    fi

    if [[ ${need_copy} == true ]]; then
      log "Installing plist (real file): ${target}"
      if [[ ${DRY_RUN} == false ]]; then
        cp "${source}" "${target}"
      fi
      installed+=("${item}")
    fi

    # (Re)load when the plist changed or the agent isn't currently loaded.
    local is_loaded=false
    if launchctl print "${domain}/${label}" >/dev/null 2>&1; then
      is_loaded=true
    fi
    if [[ ${need_copy} == true || ${is_loaded} == false ]]; then
      log "Bootstrapping launch agent: ${domain}/${label}"
      if [[ ${DRY_RUN} == false ]]; then
        launchctl bootout "${domain}/${label}" 2>/dev/null || true
        if ! launchctl bootstrap "${domain}" "${target}"; then
          echo "WARNING: launchctl bootstrap failed for ${label}" >&2
        fi
        launchctl enable "${domain}/${label}" 2>/dev/null || true
      fi
      loaded+=("${item}")
    else
      skipped+=("${item}")
    fi
  done

  echo ""
  echo "=== Launch agents ==="
  echo "Installed/updated: ${#installed[@]}"
  for item in "${installed[@]:+"${installed[@]}"}"; do
    echo "  + ${item}"
  done
  echo "Loaded: ${#loaded[@]}"
  for item in "${loaded[@]:+"${loaded[@]}"}"; do
    echo "  ~ ${item}"
  done
  echo "Skipped (unchanged & loaded): ${#skipped[@]}"
  for item in "${skipped[@]:+"${skipped[@]}"}"; do
    echo "  - ${item}"
  done
}

# --- Command shims ------------------------------------------------------------
# Gas Town (gastown) and Graphite both ship a CLI named `gt`. Homebrew let
# Graphite win ${prefix}/bin/gt, so bare `gt` resolved to Graphite in every
# shell -- including the non-interactive ones Gas Town polecats run in, which
# broke `gt prime` / `gt hook` / `gt mail check` (issue #2). A shell alias can't
# fix that: it only applies to interactive shells, not `sh -c` / agent subshells.
#
# So we shim at the PATH level instead. ~/.local/bin is first on PATH, so a `gt`
# there wins everywhere. We point it at Gas Town and expose Graphite under its
# own `graphite` name -- which the git aliases in .gitconfig now call
# (`!graphite ...`), so `git a`, `git bc`, etc. keep working. Idempotent.

BIN_DIR="${HOME}/.local/bin"

cmd_bin() {
  local created=()
  local skipped=()
  local backed_up=()
  local missing=()

  local prefix
  prefix="$(brew --prefix 2>/dev/null || echo /opt/homebrew)"

  # link name => absolute target binary
  local bin_shims=(
    "gt=>${prefix}/opt/gastown/bin/gastown"
    "graphite=>${prefix}/bin/gt"
  )

  if [[ ! -d ${BIN_DIR} ]]; then
    log "Creating directory: ${BIN_DIR}"
    if [[ ${DRY_RUN} == false ]]; then
      mkdir -p "${BIN_DIR}"
    fi
  fi

  for item in "${bin_shims[@]}"; do
    local name="${item%%=>*}"
    local target="${item##*=>}"
    local link="${BIN_DIR}/${name}"

    if [[ ! -e ${target} ]]; then
      echo "WARNING: shim target does not exist, skipping: ${name} -> ${target}"
      missing+=("${name}")
      continue
    fi

    # Already the correct symlink?
    if [[ -L ${link} && "$(readlink "${link}")" == "${target}" ]]; then
      skipped+=("${name}")
      continue
    fi

    # Back up an existing real file or a symlink pointing elsewhere.
    if [[ -e ${link} || -L ${link} ]]; then
      ensure_backup_dir
      backup_path="${BACKUP_DIR}/.local/bin/${name}"
      log "Backing up: ${link} -> ${backup_path}"
      if [[ ${DRY_RUN} == false ]]; then
        mkdir -p "$(dirname "${backup_path}")"
        mv "${link}" "${backup_path}"
      fi
      backed_up+=("${name}")
    fi

    log "Linking shim: ${link} -> ${target}"
    if [[ ${DRY_RUN} == false ]]; then
      ln -s "${target}" "${link}"
    fi
    created+=("${name}")
  done

  echo ""
  echo "=== Command shims ==="
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
  if [[ ${#missing[@]} -gt 0 ]]; then
    echo "Missing targets (not installed?): ${#missing[@]}"
    for item in "${missing[@]:+"${missing[@]}"}"; do
      echo "  ! ${item}"
    done
  fi

  # Warn if a bare `gt` still resolves to Graphite ahead of the shim on PATH.
  if [[ ${DRY_RUN} == false ]] && command -v gt >/dev/null 2>&1; then
    local resolved
    resolved="$(command -v gt)"
    if [[ ${resolved} != "${BIN_DIR}/gt" ]]; then
      echo ""
      echo "WARNING: 'gt' resolves to ${resolved}, not ${BIN_DIR}/gt."
      echo "         Ensure ${BIN_DIR} is early in PATH (it is set in .zshrc)."
    fi
  fi
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
  cmd_launchagents
  cmd_bin
  cmd_mcp
  ;;
symlinks) cmd_symlinks ;;
copies) cmd_copies ;;
launchagents) cmd_launchagents ;;
bin) cmd_bin ;;
mcp) cmd_mcp ;;
*)
  echo "Unknown command: ${COMMAND}"
  usage
  exit 1
  ;;
esac
