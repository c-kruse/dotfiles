#! /usr/bin/env bash

if ! command -v git 2>&1 > /dev/null; then
	echo "install git"
	exit 1
fi
if ! command -v fzf 2>&1 > /dev/null; then
	echo "install fzf"
	exit 1
fi
if ! command -v nvim 2>&1 > /dev/null; then
	echo "install nvim"
	exit 1
fi
cp -r nvim "$HOME/.config/"
cp -r bin "$HOME/.local/bin"
if [ -f "$HOME/.bashrc" ]; then
	mv "$HOME/.bashrc" "$HOME/.bashrc.bak"
fi
cp -r .bashrc .bashrc.d "$HOME"
cp -r .tmux.conf .gitconfig .ssh "$HOME"
