# tmux configuration

A personal tmux setup, originally forked from
[samoshkin/tmux-config](https://github.com/samoshkin/tmux-config) and since
trimmed and customized. Lives in `~/.config/tmux/`.

For the full key reference, see **[cheatsheet.md](cheatsheet.md)**.

## Features

- `C-Space` prefix (instead of `C-b`)
- Windows/panes index from `1`; new windows and splits inherit the current path
- Prompt to rename a window right after it's created
- Directional pane navigation with `prefix + ←↑↓→` and `Alt + ←↑↓→` (no prefix)
- One-key grid layouts (`prefix + Space` / `v` / `h`) driven by
  [`scripts/grid-layout.py`](scripts/grid-layout.py) + [`pane-layouts.conf`](pane-layouts.conf)
- All destructive bindings (`x`/`X`/`C-x`/`Q`) confirm before acting
- Nested local/remote session support (`F12` toggles outer bindings off)
- Clipboard integration via [`yank.sh`](yank.sh) with an OSC 52 fallback (works
  local, remote, and nested)
- Compact status line with a configurable color theme

## Status line

Status bar is at the top (bottom for remote sessions). Right side shows:

```
[PREFIX]/[COPY] · [OFF] · [Z] | CPU | MEM | (GPU) | user@host | date
```

- **CPU / MEM** via [tmux-plugin-sysstat](https://github.com/samoshkin/tmux-plugin-sysstat)
- **GPU** utilization is appended only on machines with `nvidia-smi` (probed once
  at load, so other machines spawn no per-tick subprocess)
- `[PREFIX]`/`[COPY]`/`[Z]` indicators, and `[OFF]` when bindings are toggled off (`F12`)
- Toggle the whole bar with `prefix + C-s`

## Installation

```sh
git clone git@github.com:shrestha-pranav/dotconfig.git ~/.config
~/.config/tmux/setup.sh        # installs TPM + plugins
```

`setup.sh` clones [TPM](https://github.com/tmux-plugins/tpm) into
`~/.config/tmux/plugins/` and installs the declared plugins. Reload inside tmux
with `prefix + C-r` (or `prefix + I` to (re)install plugins).

Requires **tmux ≥ 3.3** (`allow-passthrough` is used by the OSC 52 yank path). If
your distro ships an older tmux, [`install.sh`](install.sh) builds the pinned
stable version from source on Debian/Ubuntu; on macOS use `brew install tmux`.

## Nested sessions

When you tmux into a remote host from inside a local tmux, both sessions fight
over the prefix. Press `F12` to switch *all* bindings and prefix handling off in
the outer session, so keystrokes pass through to the inner one; `F12` again to
restore. The status line greys out and shows `[OFF]` while disabled. Remote
sessions are detected via `$SSH_CLIENT` and load
[`tmux.remote.conf`](tmux.remote.conf).

## Clipboard

Copying (`y`, `Enter`, mouse drag, etc.) pipes through `yank.sh`, which copies to
the system clipboard locally and falls back to OSC 52 escape sequences so copies
from remote/nested sessions still reach your local clipboard (terminal must
support OSC 52). On Linux, install `xclip` or `xsel`; on macOS it works out of
the box.

## Theme

Colors are plain variables near the bottom of [`tmux.conf`](tmux.conf) (the block
under `# === Theme ===`). Change the values; keep the variable names — they form
a contract the rest of the config relies on.
