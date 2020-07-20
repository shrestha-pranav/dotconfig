#!/usr/bin/env bash

# Check if Tmux is installed and try installing
is_app_installed() { type "$1" &>/dev/null; }

if ! is_app_installed tmux; then
  while true; do
    read -p "Do you wish to install this program?" yn
    case $yn in
      [Yy]* ) tmux.sh; break;;
      [Nn]* ) echo "Exiting config"; exit;;
      * ) echo "Please answer yes or no.";;
    esac
  done
fi

# Check if TPM is installed and git clone otherwise
if [ ! -e "$HOME/.config/tmux/plugins/tpm" ]; then
  printf "WARNING: Couldn't find TPM (Tmux Plugin Manager) \
    at default location: \$HOME/.config/tmux/plugins/tpm.\n"
  git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
fi

# Install TPM plugins
tmux new -d -s __noop >/dev/null 2>&1 || true
tmux set-environment -g TMUX_PLUGIN_MANAGER_PATH "~/.config/tmux/plugins"
~/.config/tmux/plugins/tpm/bin/install_plugins || true
tmux kill-session -t __noop >/dev/null 2>&1 || true