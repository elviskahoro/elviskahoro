# chrome os
Change Linux VM password
```sh
sudo su
passwd $username$
```

# Install
Install [Brew](https://brew.sh/) 
```sh
sudo apt-get update
sudo apt-get install build-essential
```

# github
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

# dotfiles
Getting dot files
```sh
git init .
git remote add -t \* -f origin git@github.com:elviskahoro/dotfiles.git
git checkout main
```

If error due to file override.
```sh
git fetch --all
git reset --hard origin/main
git checkout main
```

Rename git repo to dotfiles
```sh
mv .git/ .dotfiles/
```

# tmux
```sh
brew install tmux
```

# vim and neovim
```sh
brew install vim
brew install neovim
```

## vim plug
[Download plug.vim](https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim) and put it in the "autoload" directory.

### vim unix
```sh
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```
### neovim unix, Linux
```sh
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
```

