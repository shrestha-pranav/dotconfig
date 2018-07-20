#!/usr/bin/env bash

# Exit if any command fails and return first non-zero error
set -euo pipefail

# Create backup directories for vim and .configs
mkdir -p "$HOME/.backup/"{,".tmp",".backups",".undofiles",".swapfiles"}

# Backup config files (if they exist)
BACKUP="$HOME/.backup/.tmp/"$(date '+%d%b%Y')
mkdir -p $BACKUP
test -f "$HOME/.bashrc"       && mv "$HOME/.bashrc"    $BACKUP 
test -f "$HOME/.localrc"      && mv "$HOME/.localrc"   $BACKUP 
test -f "$HOME/.tmux.conf"    && mv "$HOME/.tmux.conf" $BACKUP 
test -f "$HOME/.vimrc"        && mv "$HOME/.vimrc"     $BACKUP 
test -f "$HOME/.dircolors"    && mv "$HOME/.dircolors" $BACKUP 
test -f "$HOME/.aliases"      && mv "$HOME/.aliases"   $BACKUP 
test -f "$HOME/.bash_profile" && mv "$HOME/.bash_profile" $BACKUP 

echo "Starting config setup"

# Find where this file is located to set as config directory
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do 
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
DIR="$( cd -P "$( dirname "$SOURCE" )"; pwd -P )"
cd "$DIR";

echo "Setup directory=$DIR. Linking config files."

# Link up personal configuration files
ln -sf "$DIR/bashrc"    "$HOME/.bashrc"
ln -sf "$DIR/aliases"   "$HOME/.aliases"
ln -sf "$DIR/vimrc"     "$HOME/.vimrc"
ln -sf "$DIR/dircolors" "$HOME/.dircolors"
cp -f  "$DIR/localrc"   "$HOME/.localrc"

echo "Config files linked. Setting up Tmux."

# Check if Tmux is installed and try installing
is_app_installed() { type "$1" &>/dev/null; }

if ! is_app_installed tmux; then
  while true; do
    read -p "Do you wish to install this program?" yn
    case $yn in
      [Yy]* ) ./tmux/tmux.sh; break;;
      [Nn]* ) echo "Exiting config"; exit;;
      * ) echo "Please answer yes or no.";;
    esac
  done
fi

# Check if TPM is installed and git clone otherwise
if [ ! -e "$HOME/.tmux/plugins/tpm" ]; then
  printf "WARNING: Couldn't find TPM (Tmux Plugin Manager) \
    at default location: \$HOME/.tmux/plugins/tpm.\n"
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

# Copy tmux files and symlink .tmux.conf to $HOME
cp -a ./tmux/. "$HOME"/.tmux/
ln -sf .tmux/tmux.conf "$HOME"/.tmux.conf;

# Install TPM plugins
tmux new -d -s __noop >/dev/null 2>&1 || true
tmux set-environment -g TMUX_PLUGIN_MANAGER_PATH "~/.tmux/plugins"
"$HOME"/.tmux/plugins/tpm/bin/install_plugins || true
tmux kill-session -t __noop >/dev/null 2>&1 || true

echo "Setup completed. You're good to go!"
