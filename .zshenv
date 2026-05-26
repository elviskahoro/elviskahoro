# Global secrets / env vars (not tracked in dotfiles repo)
[[ -f "$HOME/.env.local" ]] && source "$HOME/.env.local"

# Directory-specific environment variables
[[ -f "$PWD/.env.local" ]] && source "$PWD/.env.local"
