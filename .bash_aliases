# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
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
alias g="git"
alias add="git add"
alias stats="git status"
alias commit="git commit"
alias gtree="git ls-tree --full-tree -r HEAD"

alias submit="/home/w3157/submit/submit-lab"

alias clac="ssh -X ps2958@clac.cs.columbia.edu"
alias cunix="ssh -X ps2958@cunix.cc.columbia.edu"
