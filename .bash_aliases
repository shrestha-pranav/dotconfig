#!/bin/bash

# add colors to grep and ls
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# more ls aliases
alias ..="cd .."
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# compiler aliases
alias val="valgrind --leak-check=yes"
alias m="make"
alias mm="make;make run;"
alias mf="make;make free;"

# git aliases
alias add="git add -u"
alias commit="git commit"
alias gtree="git ls-tree --full-tree -r HEAD"

# tmux aliases
alias tux="tmux attach"
alias dux="tmux detach"

# python/conda aliases
function ac { source activate $1; cd "$HOME/$1";}
alias dac="source deactivate"
alias lab="jupyter notebook"
alias hub="jupyterhub"
