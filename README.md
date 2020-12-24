## Config Files for bash terminals

### Installation:
- git clone https://github.com/shrestha-pranav/dotconfig .config
- cd .config
- chmod u+x setup.sh && ./setup.sh

**Note**: The git directory is used as the setup directory and config files at `$HOME` is linked to this by setup.sh. The setup creates backup directories to backup existing configs and for temporary vim files.

**Important:** Additional bash settings should be added to the ~/.local_profile file

### Useful bash aliases
Use 'type [command]' or just 'alias' for details)

- Directory settings: .., ls, ll
- Git: gtree, add, commit
- Tmux: tux [name]

### TMUX - Terminal Multiplexer
Improve terminal use massively. If tmux is not installed (check with `which tmux` or `tmux -V`), use tmux.sh to install.

**tl;dr** tmux works using sessions (read: instances), windows (read: tabs) and panes (window splits). Tmux commands work as `[prefix]` (Ctrl+Space) then `[command]` (e.g. `Ctrl+Space, c` to create a new window)

Common tmux commands include pane, window and session management.

*__Window (Tab) Management__*    

	  c		Create window
      w		List windows
     n/p	Next/Previous window
      ,		Rename window
      &		Kill window

*__Pane Management__*

      |		Split pane horizontally
      -		Split pane vertically
    ↑ ↓ → ←	Switch between panes (vim-like hjkl also works)
      q		Show pane numbers (press # to select pane)
      x		Kill pane
    [Space]	Toggle between layouts
     { }	Move current pane left/right
      z		Toggle Pane Zoom

*__Session Management__*    

    :new ⏎	New session
      s		List sessions
      $		Name session

*__Miscellaneous__*    

      d		Detach (same as tmux detach or dux)
      t		Big clock
      ?		List shortcuts
      :		Prompt

### VIM

Colon `:` has been mapped to `[Space]`. So, enter normal mode with `[Esc]`, then hit `[Space] w q` to save quit, or `[Space] w` to save.