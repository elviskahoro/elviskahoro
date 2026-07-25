# Global secrets / env vars (not tracked in dotfiles repo)
[[ -f "$HOME/.env.local" ]] && source "$HOME/.env.local"

# Opt in to bd v2 --json envelope format

# Directory-specific environment variables
[[ -f "$PWD/.env.local" ]] && source "$PWD/.env.local"
