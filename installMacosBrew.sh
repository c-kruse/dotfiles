#!/bin/bash

# neovim dev https://github.com/neovim/neovim/wiki/Installing-Neovim
brew install --HEAD luajit
brew install --HEAD neovim

# vim-plug https://github.com/junegunn/vim-plug
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

mkdir -p $HOME/.config
cp -r ./nvim $HOME/.config/nvim
