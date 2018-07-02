# Backup files for vim and .configs
mkdir -p ~/.backup
mkdir -p ~/.backup/.configs
mkdir -p ~/.backup/.backups
mkdir -p ~/.backup/.undofiles
mkdir -p ~/.backup/.swapfiles

# Copy over files (if they exist)
test -f ~/.bashrc && mv ~/.bashrc ~/.backup/.configs/
test -f ~/.bash_profile && mv ~/.bash_profile ~/.backup/.configs/
test -f ~/.tmux.conf && mv ~/.tmux.conf ~/.backup/.tmux.conf
test -f ~/.vimrc && mv ~/.vimrc ~/.backup/.vimrc
test -f ~/.dircolors && mv ~/.dircolors ~/.backup/.dircolors

echo "Starting config setup"
# Find where this file is located to set as config directory
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do 
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

echo "Setup directory=$DIR. Linking files."

# Set up personal configuration files
# Includes bash, tmux and vim configs
ln -s -f "$DIR/.bashrc" ~/.bashrc
ln -s -f "$DIR/.bash_aliases" ~/.bash_aliases
ln -s -f "$DIR/.vimrc" ~/.vimrc
ln -s -f "$DIR/.tmux.conf" ~/.tmux.conf
ln -s -f "$DIR/.dircolors" ~/.dircolors
cp "$DIR/.local_profile" ~/.local_profile
