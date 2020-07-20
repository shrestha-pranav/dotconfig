#!/usr/bin/env bash

# Exit if any command fails and return first non-zero error
set -euo pipefail

# Create backup directories for vim and .configs
mkdir -p "$HOME/.backup/"{,".tmp",".backups",".undofiles",".swapfiles"}

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

echo "Setup directory=$DIR"

# Backup config files (if they exist)
echo "Backing up config files."
BACKUP="$HOME/.backup/.tmp/"$(date '+%d%b%Y')
mkdir -p $BACKUP
test -f "$HOME/.bashrc"       && mv "$HOME/.bashrc"    $BACKUP 
test -f "$HOME/.localrc"      && mv "$HOME/.localrc"   $BACKUP 
test -f "$HOME/.tmux.conf"    && mv "$HOME/.tmux.conf" $BACKUP 
test -f "$HOME/.vimrc"        && mv "$HOME/.vimrc"     $BACKUP 
test -f "$HOME/.dircolors"    && mv "$HOME/.dircolors" $BACKUP 
test -f "$HOME/.aliases"      && mv "$HOME/.aliases"   $BACKUP 
test -f "$HOME/.bash_profile" && mv "$HOME/.bash_profile" $BACKUP 

# Link up personal configuration files
echo "Linking config files."
ln -sf "$DIR/bashrc"    "$HOME/.bashrc"
ln -sf "$DIR/aliases"   "$HOME/.aliases"
ln -sf "$DIR/vimrc"     "$HOME/.vimrc"
ln -sf "$DIR/dircolors" "$HOME/.dircolors"
cp -f  "$DIR/localrc"   "$HOME/.localrc"

echo "Config files linked. Setting up Tmux."

chmod u+x $DIR/tmux/setup.sh
$DIR/tmux/setup.sh

echo "Setup completed. You're good to go!"
