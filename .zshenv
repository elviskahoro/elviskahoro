
[[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"

# Directory-specific environment variables
[[ -f "$PWD/.env.local" ]] && source "$PWD/.env.local"
