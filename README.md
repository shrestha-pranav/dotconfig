Config Files for bash terminals

Installing:
- git clone https://github.com/shrestha-pranav/dotconfig
- cd dotconfig
- chmod u+x setup.sh && ./setup.sh

Note: The git directory is used as the setup directory and config files at $HOME is linked to this by setup.sh. The setup creates backup directories to backup existing configs and for temporary vim files.

Important: Additional bash settings should be added to the ~/.local_profile file

Useful bash aliases (use 'alias [command]' or just 'alias' for details)
- Directory settings: .., ls, ll
- Makefile: val, m, mm, mf
- Git: gtree, add, commit
- Tmux: tux, dux
- Python/Conda envs: ac (source activate), dac (deactivate), lab, hub
- Windows Explorer: start (opens directory in explorer.exe)
- SSH: Add servers as documented in .local_profile and use with 'shh [server_alias]'

TMUX: Terminal multiplexer. Improve terminal use massively. If tmux is not installed, use tmux.sh to install.
For most commands in tmux, prefix must be hit first. (Ctrl+Space). For instance: To split panes, Ctrl+Space then | for horizontal split and Ctrl+Space then - for vertical split.

Some common shortcuts for tmux (Ctrl+Space then the following keys):
- | Horizontal split pane
- - Vertical split pane
- c Create new window
- n/p Next/Previous window (shown in status bar. Can also switch with Shift+Left/Right)
- Arrow keys/{h,j,k,l} Switch panes

Panes can be resized with Ctrl+[Space then arrow keys]

VIM: Colon (:) has been mapped to [Space]. So, enter normal mode with [Esc], then hit [Space],w,q to save quit, or [Space],w to save. 