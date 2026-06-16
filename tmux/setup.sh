#!/usr/bin/env bash

# Check if Tmux is installed and try installing
is_app_installed() { type "$1" &>/dev/null; }

if ! is_app_installed tmux; then
  read -p "tmux is not installed. Install it now? [y/N] " yn
  case $yn in
    [Yy]* )
      if [[ "$OSTYPE" == darwin* ]]; then
        brew install tmux              # macOS
      else
        bash "$HOME/.config/tmux/install.sh"   # Debian/Ubuntu: build pinned stable from source
      fi
      ;;
    * ) echo "tmux is required; exiting."; exit 1;;
  esac
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

# Compact sysstat output: strip the trailing "%" the CPU/MEM scripts print, to
# pair with the label-less @sysstat_*_view_tmpl in tmux.conf (bare numbers). The
# plugins dir is gitignored, so this re-applies the patch on every fresh install.
# Idempotent + portable (-i.bak works on both BSD and GNU sed).
sysstat="$HOME/.config/tmux/plugins/tmux-plugin-sysstat/scripts"
[ -f "$sysstat/cpu.sh" ] && sed -i.bak 's/"%\.1f%%"/"%.1f"/' "$sysstat/cpu.sh" && rm -f "$sysstat/cpu.sh.bak"
[ -f "$sysstat/mem.sh" ] && sed -i.bak 's/"%\.0f%%"/"%.0f"/' "$sysstat/mem.sh" && rm -f "$sysstat/mem.sh.bak"

# Reload config into any running server so the bar (sysstat CPU/MEM) updates now,
# instead of waiting for a manual `prefix + I` / restart.
tmux source "$HOME/.config/tmux/tmux.conf" >/dev/null 2>&1 || true