#!/bin/bash
test -f ~/.config/.bashrc && . ~/.config/.bashrc
test -f ~/.config/.bash_aliases && . ~/.config/.bash_aliases
test -f ~/.config/.local_aliases && . ~/.config/.local_aliases
