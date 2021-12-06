# Ramp Up


Chromebook (cb)
MacOS (osx)

cb::Change Linux VM password
```sh
sudo su
passwd $username$
```


Authenticate Github
```sh
ls -al ~/.ssh
```
```sh
ssh-keygen -t ed25519 -C "ekk0809@gmail.com"
```

```sh
eval "$(ssh-agent -s)"
```

Copy SSH Key and Paste into [Github](https://github.com/settings/keys)

Dotfiles [guide](https://www.ackama.com/blog/posts/the-best-way-to-store-your-dotfiles-a-bare-git-repository-explained)

Install [Brew](https://brew.sh/)
```sh
brew install git
```

dotfiles
```sh
git init .
```

```sh
git remote add -t \* -f origin git@github.com:elviskahoro/dotfiles.git &&
git checkout main &&
mv .git/ .dotfiles/
```

If error due to file override.
```sh
git fetch --all
git reset --hard origin/main
git checkout main
```

Restart shell

Ignore untracked files
```sh
dot config --local status.showUntrackedFiles no
```

cb::Update packages
```sh
sudo apt update -y
sudo apt-get update --allow-releaseinfo-change
sudo apt-get install build-essential
sudo apt-get install -y xclip
brew install liquidprompt
```

```sh
brew install vim
brew install tmux
brew install tig
brew install node
brew install neovim
brew install grep
brew install bat
brew install fzf
brew install glow
npm install -g neovim
```

TODO: Add poetry instructions for installing python

```
pip install --user neovim
```

Download [plug.vim](https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim) and put it in the "autoload" directory.

vim
```sh
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```

neovim
```sh
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
```

[Install Coc Plugin](https://github.com/neoclide/coc.nvim/wiki/Install-coc.nvim)
```sh
chmod u+x ~/.vim/coc-reinstall.sh
~/.vim/coc-reinstall.sh
```

Reload .vimrc and `:PlugInstall` to install plugins.

### Commands

| Command                             | Description                                                        |
| ----------------------------------- | ------------------------------------------------------------------ |
| `PlugInstall [name ...] [#threads]` | Install plugins                                                    |
| `PlugUpdate [name ...] [#threads]`  | Install or update plugins                                          |
| `PlugClean[!]`                      | Remove unlisted plugins (bang version will clean without prompt) |
| `PlugUpgrade`                       | Upgrade vim-plug itself                                            |
| `PlugStatus`                        | Check the status of plugins                                        |
| `PlugDiff`                          | Examine changes from the previous update and the pending changes   |
| `PlugSnapshot[!] [output path]`     | Generate script for restoring the current snapshot of the plugins  |

```sh
pip install "pelican[markdown]"
```

Install [flatpak](https://flatpak.org/setup/Chrome%20OS/)
```sh
sudo apt install flatpak &&
flatpak --user remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
```

[Zotero flatpak](https://flathub.org/apps/details/org.zotero.Zotero)

If flatpak fails: [link](https://www.zotero.org/support/kb/installing_on_a_chromebook)
```sh
wget -qO- https://github.com/retorquere/zotero-deb/releases/download/apt-get/install.sh | sudo bash
sudo apt update
sudo apt install zotero
```

[ZotFile](http://zotfile.com/)

[BetterBibText](https://retorque.re/zotero-better-bibtex/)

[Mdnotes](https://github.com/argenos/zotero-mdnotes)

Install [GCP](https://cloud.google.com/sdk/docs/install#deb)

web repo

```sh
git submodule update --init --recursive
```
