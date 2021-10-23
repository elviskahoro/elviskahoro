# Starter

## chrome os

Change Linux VM password

```sh
sudo su
passwd $username$
```

## Install

Install [Brew](https://brew.sh/)

## github

Check Keys

```sh
ls -al ~/.ssh
```

Create Key

```sh
ssh-keygen -t ed25519 -C "ekk0809@gmail.com"
```

Check Agent

```sh
eval "$(ssh-agent -s)"
```

Copy SSH Key and Paste into [Github](https://github.com/settings/keys)

## dotfiles

A helpful [guide.](https://www.ackama.com/blog/posts/the-best-way-to-store-your-dotfiles-a-bare-git-repository-explained)

Getting dot files
```sh
git init .
git remote add -t \* -f origin git@github.com:elviskahoro/dotfiles.git
git checkout main
mv .git/ .dotfiles/
```

Getting profiles
```sh
git init .
git remote add -t \* -f origin git@github.com:elviskahoro/profiles.git
git checkout main
mv .git/ .profiles/
```

If error due to file override.
```sh
git fetch --all
git reset --hard origin/main
git checkout main
```

Reset Terminal
```sh
dot config --local status.showUntrackedFiles no
pro config --local status.showUntrackedFiles no
```

## brew packages

```sh
brew install git
sudo apt update
sudo apt-get update --allow-releaseinfo-change
sudo apt-get install build-essential
brew install tmux
brew install vim
brew install neovim
brew install grep
brew install node
brew install tig
brew install liquidprompt
brew install bat
brew install fzf
```

## vim & neovim

### vim plug

Download [
plug.vim](https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim)
and put it in the "autoload" directory.

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

```sh
npm install -g neovim
pip install --user neovim
```

[Install Coc](https://github.com/neoclide/coc.nvim/wiki/Install-coc.nvim)

```sh
chmod u+x ~/.vim/coc-reinstall.sh
~/.vim/coc-reinstall.sh
```

## gcp

[Install](https://cloud.google.com/sdk/docs/install#deb)

## pelican

```sh
python -m pip install "pelican[markdown]"
```

## zotero

[Install](https://www.zotero.org/support/kb/installing_on_a_chromebook)

```sh
wget -qO- https://github.com/retorquere/zotero-deb/releases/download/apt-get/install.sh | sudo bash
sudo apt update
sudo apt install zotero
```

[ZotFile](http://zotfile.com/)

[BetterBibText](https://retorque.re/zotero-better-bibtex/)

[Mdnotes](https://github.com/argenos/zotero-mdnotes)
