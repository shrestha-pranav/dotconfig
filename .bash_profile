#!/bin/bash
test -f ~/.config/bash/.bashrc && . ~/.config/bash/.bashrc
test -f ~/.config/bash/.bash_aliases && . ~/.config/bash/.bash_aliases
test -f ~/.config/bash/.local_profile && . ~/.config/bash/.local_profile
