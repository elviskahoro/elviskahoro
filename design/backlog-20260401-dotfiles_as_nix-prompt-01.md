# Spec: Manage Dotfiles with Nix (macOS)

## Goal

Migrate the current dotfiles repo from raw config files (manually synced) to a **Nix-based declarative setup** using **nix-darwin + home-manager** on macOS. This enables:

- One-command setup on a new machine
- Declarative, reproducible config
- Atomic rollbacks (built-in generations)
- Package installation bundled with config

## Current State

The repo currently contains these config files, managed manually:

| File | Purpose |
|---|---|
| `.zshrc` | Zsh config: env vars, history opts, starship init, pyenv, fnm |
| `.bashrc` | Shell aliases (200+), navigation shortcuts, tool aliases |
| `.bash_profile` | (empty) |
| `.gitconfig` | Git user, 350+ aliases (graphite `gt` wrappers, typo aliases), delta pager, LFS, credential helpers |
| `.gitignore_global` | Global git ignores |
| `.vimrc` | Vim config |
| `.ideavimrc` | JetBrains Vim emulation |
| `.zprofile` | Zsh profile |
| `.zshenv` | Zsh env (minimal) |
| `.profile` | Login profile (minimal) |
| `.inputrc` | Readline config (empty) |
| `.config/starship.toml` | Starship prompt config |
| `.config/karabiner.json` | Karabiner-Elements key remapping (mouse buttons, keyboard devices) |
| `.config/.tmux.conf` | Tmux config |
| `.config/bash_profile.sh` | Additional bash profile sourced config |
| `.config/vi-mode.sh` | Vi mode shell config |
| `.config/git/.gitmessage` | Git commit template |
| `.vim/` | Vim plugins/runtime |
| `.warp/` | Warp terminal config |
| `Library/` | macOS Library config files |

## Proposed Architecture

```
elviskahoro/
  flake.nix              # Entry point — defines darwinConfigurations + homeConfigurations
  flake.lock             # Pinned dependency versions
  hosts/
    darwin.nix            # nix-darwin system config (macOS settings, Homebrew casks)
  home/
    default.nix           # home-manager entry — imports all modules below
    shell.nix             # Zsh + Bash config (aliases, history, env vars)
    git.nix               # Git config (user, aliases, delta, LFS, credentials)
    starship.nix          # Starship prompt config
    vim.nix               # Vim/Neovim config
    tmux.nix              # Tmux config
    karabiner.nix         # Karabiner-Elements config (raw JSON)
    warp.nix              # Warp terminal config (raw files)
  overlays/               # Custom Nix overlays (if needed)
  README.md               # Updated setup instructions
```

## Technology Stack

| Component | Role |
|---|---|
| [Nix](https://nixos.org/download) | Package manager (works on macOS) |
| [nix-darwin](https://github.com/LnL7/nix-darwin) | macOS system-level config (like NixOS but for macOS) |
| [home-manager](https://github.com/nix-community/home-manager) | User-level dotfile management |
| [Nix Flakes](https://nixos.wiki/wiki/Flakes) | Reproducible dependency pinning + composable config |

## Migration Plan

### Phase 1: Bootstrap Nix on macOS

1. Install Nix: `curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh`
   - Uses the Determinate Systems installer (recommended for macOS — handles macOS updates gracefully)
2. Enable flakes (the installer does this by default)
3. Scaffold `flake.nix` with nix-darwin + home-manager as inputs

### Phase 2: Shell Config (`home/shell.nix`)

Migrate `.zshrc`, `.bashrc`, `.bash_profile`, `.zprofile`, `.zshenv`, `.profile`.

```nix
# home/shell.nix
{ pkgs, ... }: {
  programs.zsh = {
    enable = true;
    history = {
      size = 10000000;
      save = 10000000;
      share = true;
      ignoreDups = true;
      expireDuplicatesFirst = true;
    };
    sessionVariables = {
      GIT_EDITOR = "vim";
      GITHUB_EDITOR = "vim";
      EDITOR = "vim";
    };
    initContent = ''
      # Source bashrc for aliases
      if [ -f "$HOME/.bashrc" ]; then
        source "$HOME/.bashrc"
      fi

      # Python & Node versions managed per-project via `nix develop`
      # No pyenv or fnm init needed
    '';
  };

  programs.bash = {
    enable = true;
    shellAliases = {
      # Navigation
      "~" = "cd ~";
      ".." = "cd ../";
      "..." = "cd ../../";
      down = "cd ~/Downloads/";
      docs = "cd ~/Documents/";
      desk = "cd ~/Desktop";

      # Tool aliases
      ls = "eza -a --long";
      tree = "eza --tree --git-ignore";
      less = "less -R";
      cp = "cp -i";
      mv = "mv -i";
      mkdir = "mkdir -p";
      py = "python";
      g = "git";
      # ... (all 200+ aliases from .bashrc)
    };
  };
}
```

### Phase 3: Git Config (`home/git.nix`)

Migrate `.gitconfig`, `.gitignore_global`, `.config/git/.gitmessage`.

```nix
# home/git.nix
{ pkgs, ... }: {
  programs.git = {
    enable = true;
    userName = "elvis kahoro";
    userEmail = "github@elvis.ai";

    delta = {
      enable = true;
      options = {
        navigate = true;
        light = false;
        line-numbers = true;
        side-by-side = false;
        minus-style = ''red "#ffeeee"'';
        plus-style = ''green "#383830"'';
      };
    };

    lfs.enable = true;

    extraConfig = {
      init.defaultBranch = "main";
      fetch.prune = true;
      pull.rebase = true;
      push = {
        default = "simple";
        autoSetupRemote = true;
      };
      core = {
        excludesfile = "~/.gitignore_global";
        editor = "vim";
      };
      merge.conflictstyle = "diff3";
      diff.colorMoved = "default";
      stash = {
        showStat = true;
        showPatch = true;
      };
      commit.template = "~/.config/git/.gitmessage";
      credential."https://github.com".helper = "/opt/homebrew/bin/gh auth git-credential";
    };

    aliases = {
      a = "!gt add";
      aa = "!gt add .";
      au = "!gt add -u";
      bc = "!gt create";
      bd = "!f() { if [ $# -eq 0 ]; then gt down; else gt down $1; fi }; f";
      bu = "!f() { if [ $# -eq 0 ]; then gt up; else gt up $1; fi }; f";
      ca = "!gt modify";
      co = "! gt modify -c";
      l = "!gt log --reverse --show-untracked";
      s = "status";
      ss = "!gh pr create --fill --web";
      rs = "!gt sync";
      # ... (all 350+ aliases from .gitconfig)
    };
  };

  home.file.".gitignore_global".source = ../files/.gitignore_global;
  home.file.".config/git/.gitmessage".source = ../files/.gitmessage;
}
```

### Phase 4: Tools & Packages (`home/default.nix`)

Declare CLI tools as Nix packages instead of installing via Homebrew.

```nix
# home/default.nix
{ pkgs, ... }: {
  imports = [
    ./shell.nix
    ./git.nix
    ./starship.nix
    ./vim.nix
    ./tmux.nix
    ./karabiner.nix
  ];

  home.packages = with pkgs; [
    # CLI tools (currently installed via brew)
    eza           # ls replacement
    bat           # cat replacement
    delta         # git diff pager
    starship      # prompt
    ripgrep       # rg
    fd            # find replacement
    jq            # JSON
    fx            # JSON viewer
    tmux
    # Python & Node managed via nix develop shells (per-project flakes)
    # No pyenv or fnm needed
    uv            # Python package manager

    # Dev tools
    gh            # GitHub CLI
  ];

  home.stateVersion = "24.05";
  programs.home-manager.enable = true;
}
```

### Phase 5: Starship (`home/starship.nix`)

```nix
# home/starship.nix
{ ... }: {
  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      right_format = "";
      # format string is long — keep as-is from current starship.toml
      format = "..."; # import from current config
    };
  };
}
```

### Phase 6: Raw Config Files (Karabiner, Warp, Vim)

Some configs are better kept as raw files rather than converted to Nix expressions.

```nix
# home/karabiner.nix
{ ... }: {
  # Karabiner expects JSON at ~/.config/karabiner/karabiner.json
  home.file.".config/karabiner/karabiner.json".source = ../files/karabiner.json;
}
```

Store original files in a `files/` directory and use `home.file.<path>.source` to symlink them.

### Phase 7: macOS System Settings (`hosts/darwin.nix`)

nix-darwin can manage macOS defaults (optional but nice):

```nix
# hosts/darwin.nix
{ pkgs, ... }: {
  # Homebrew integration for GUI apps (casks) that aren't in nixpkgs
  homebrew = {
    enable = true;
    casks = [
      "warp"
      "raycast"
      "rectangle-pro"
      "karabiner-elements"
    ];
    onActivation.cleanup = "zap";  # Remove casks not listed here
  };

  # macOS system defaults
  system.defaults = {
    dock.autohide = true;
    finder.AppleShowAllExtensions = true;
    NSGlobalDomain.AppleShowAllExtensions = true;
  };

  services.nix-daemon.enable = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
```

## Flake Entry Point

```nix
# flake.nix
{
  description = "elvis's macOS dotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nix-darwin, home-manager, ... }: {
    darwinConfigurations."elvis-macbook" = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";  # Apple Silicon
      modules = [
        ./hosts/darwin.nix
        home-manager.darwinModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.elvis = import ./home;
        }
      ];
    };
  };
}
```

## Daily Workflow

```bash
# After editing any .nix file:
darwin-rebuild switch --flake .

# Commit and push:
git add -A && git commit -m "update shell aliases" && git push
```

## New Machine Setup

```bash
# 1. Install Nix
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh

# 2. Clone dotfiles
git clone git@github.com:elviskahoro/elviskahoro.git ~/dotfiles

# 3. Build and activate
cd ~/dotfiles
darwin-rebuild switch --flake .
```

Everything — packages, configs, macOS settings — is set up in one command.

## Migration Strategy

Migrate incrementally, not all at once:

1. **Start with `flake.nix` + one module** (e.g., `starship.nix` — smallest config)
2. Verify it works: `darwin-rebuild switch --flake .`
3. Add modules one at a time: git → shell → vim → tmux → karabiner
4. Keep raw files in `files/` for configs that don't benefit from Nix expressions
5. Remove old dotfiles from repo root as each is migrated
6. Update README with new setup instructions

## Risks & Mitigations

| Risk | Mitigation |
|---|---|
| Nix learning curve | Start with one module, learn incrementally |
| macOS updates can break Nix | Determinate Systems installer handles this; community is active |
| Some tools not in nixpkgs | Use Homebrew casks via nix-darwin's `homebrew` module |
| Graphite (`gt`) not in nixpkgs | Install via Homebrew cask or `npm install -g @withgraphite/graphite-cli` in shell init |
| Config drift if editing `~/.zshrc` directly | home-manager symlinks are read-only — forces you to edit the .nix source |

## Decisions

- **Shell aliases**: Keep all 200+ aliases as-is (including typo corrections)
- **Python & Node runtimes**: Replace `pyenv` and `fnm` with Nix-managed runtimes (`nix develop` shells per project)
- **Warp config**: Manage through Nix (disable Warp's own cloud sync, keep config in repo)
- **`Library/` macOS preferences**: Include in Nix — manage via nix-darwin `system.defaults` where possible, raw files for the rest
