# chrome os
```sh
sudo su
passwd $username$
```

# brew
[Install Brew](https://brew.sh/) 
```sh
brew install gcc
brew install tmux
```
# tmux

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

