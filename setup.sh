#!/bin/bash
echo "source ~/.config/.bash_profile" >> ~/.bash_profile
echo "source ~/.config/.vimrc" >> ~/.vimrc
echo "source-file ~/.config/.tmux.conf" >> ~/.tmux.conf
cp ~/.config/.minttyrc ~/.minttyrc
mkdir -p ~/.backup
mkdir -p ~/.backup/.backups
mkdir -p ~/.backup/.undofiles
mkdir -p ~/.backup/.swapfiles