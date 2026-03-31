#!/usr/bin/env bash
set -euo pipefail

# Compose VS Code config by merging generic + editor-specific overrides.
# Writes generated files to generated/<editor>/ and optionally symlinks them.
#
# Usage: ./compose.sh <editor|all> [--link] [--dry-run]
#
# Examples:
#   ./compose.sh cursor              # generate only
#   ./compose.sh cursor --link       # generate + symlink into Application Support
#   ./compose.sh all                 # generate all editors
#   ./compose.sh all --link          # generate + symlink all editors

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
GENERATED_DIR="$SCRIPT_DIR/generated"

EDITORS="cursor positron vscodium vscode"

# Map editor name -> Application Support directory name
app_dir_for() {
    case "$1" in
        cursor)   echo "Cursor" ;;
        positron) echo "Positron" ;;
        vscodium) echo "VSCodium" ;;
        vscode)   echo "Code" ;;
        *) echo ""; return 1 ;;
    esac
}

LINK=false
DRY_RUN=false

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <editor|all> [--link] [--dry-run]"
    echo "Editors: $EDITORS, all"
    exit 1
fi

EDITOR_ARG="$1"
shift
for arg in "$@"; do
    case "$arg" in
        --link) LINK=true ;;
        --dry-run) DRY_RUN=true ;;
        *) echo "Unknown flag: $arg"; exit 1 ;;
    esac
done

log() {
    if [[ "$DRY_RUN" == true ]]; then
        echo "[DRY RUN] $1"
    else
        echo "$1"
    fi
}

compose_editor() {
    local editor="$1"
    local editor_dir="$SCRIPT_DIR/$editor"
    local out_dir="$GENERATED_DIR/$editor"

    if [[ ! -d "$editor_dir" ]]; then
        echo "Error: Unknown editor '$editor'"
        echo "Available: $EDITORS"
        return 1
    fi

    log "Composing $editor..."

    if [[ "$DRY_RUN" == false ]]; then
        mkdir -p "$out_dir"

        # Deep merge: generic settings + editor overrides (editor wins)
        jq -s '.[0] * .[1]' \
            "$SCRIPT_DIR/generic/settings.json" \
            "$editor_dir/settings.json" \
            > "$out_dir/settings.json"

        # Array concat: generic keybindings + editor-specific keybindings
        jq -s '.[0] + .[1]' \
            "$SCRIPT_DIR/generic/keybindings.json" \
            "$editor_dir/keybindings.json" \
            > "$out_dir/keybindings.json"
    fi

    log "  -> $out_dir/settings.json"
    log "  -> $out_dir/keybindings.json"
}

link_editor() {
    local editor="$1"
    local app_dir
    app_dir="$(app_dir_for "$editor")"
    local target_dir="$HOME/Library/Application Support/$app_dir/User"
    local source_dir="$GENERATED_DIR/$editor"

    for file in settings.json keybindings.json; do
        local source="$source_dir/$file"
        local target="$target_dir/$file"

        # Ensure target parent exists
        if [[ ! -d "$target_dir" ]]; then
            log "  Creating directory: $target_dir"
            if [[ "$DRY_RUN" == false ]]; then
                mkdir -p "$target_dir"
            fi
        fi

        # Already correct symlink
        if [[ -L "$target" ]]; then
            local existing
            existing="$(readlink "$target")"
            if [[ "$existing" == "$source" ]]; then
                log "  = $file (already linked)"
                continue
            fi
        fi

        # Backup existing file to tmp
        if [[ -e "$target" || -L "$target" ]]; then
            local backup_dir
            backup_dir="$(mktemp -d)/vscode-backup/$editor"
            mkdir -p "$backup_dir"
            local backup="$backup_dir/$file"
            log "  Backing up: $target -> $backup"
            if [[ "$DRY_RUN" == false ]]; then
                cp -a "$target" "$backup"
                rm "$target"
            fi
        fi

        # Create symlink
        log "  Linking: $target -> $source"
        if [[ "$DRY_RUN" == false ]]; then
            ln -s "$source" "$target"
        fi
    done
}

# Determine which editors to process
if [[ "$EDITOR_ARG" == "all" ]]; then
    targets="$EDITORS"
else
    targets="$EDITOR_ARG"
fi

for editor in $targets; do
    compose_editor "$editor"
    if [[ "$LINK" == true ]]; then
        link_editor "$editor"
    fi
done

echo ""
echo "Done."
