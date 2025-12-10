
[ -z "$PS1" ] && return #If not running interactively, exit

shopt -s histappend     #append not overwrite
HISTSIZE=1000           #setting history length
HISTFILESIZE=2000
HISTCONTROL=ignoreboth  #ignore duplicate lines or lines starting with spaces

shopt -s checkwinsize   #update COMUNSxROWS after commands on window change
#shopt -s globstar      #pattern "**" will match all files and 0+ directories

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in xterm-color|*-256color) color_prompt=yes;; esac

if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then color_prompt=yes; fi

# Add docker-container information to the PS1
DOCKER_PREFIX=''
if [ -f /.dockerenv ] && [ -n "$DOCKER_NAME" ]; then
  DOCKER_PREFIX='['"$DOCKER_NAME"'] '
  if [ "$color_prompt" = yes ]; then
    DOCKER_PREFIX='\[\033[01;36m\]['"$DOCKER_NAME"']\[\033[00m\] '
  fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}'"$DOCKER_PREFIX"'\[\033[01;32m\]\u\[\033[00m\]\[\033[01;33m\]@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}'"$DOCKER_PREFIX"'\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt DOCKER_PREFIX

# If this is an xterm set the title to user@host:dir
case "$TERM" in xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1";; *);;
esac
PROMPT_DIRTRIM=5

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

umask 077
export EDITOR=vim

eval `dircolors ~/.dircolors`

PROMPT_COMMAND="PS1=\"${PS1}\"; echo"

# Bash aliases and local profiles
test -f ~/.aliases && . ~/.aliases
test -f ~/.localrc && . ~/.localrc
