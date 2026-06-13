# tmux cheatsheet — prefix is `Ctrl+Space` (`<P>`)

## Sessions
`<P> d` detach · `<P> D` detach others · `<P> R` rename · `<P> Q` kill (confirm) · `<P> C-u` merge into named session · `<P> $` renew env · `<P> F12` toggle off all bindings (nested)

## Windows
`<P> c` new (cwd) · `<P> r` rename · `<P> X` kill (confirm) · `<P> C-x` kill others · `Shift+←/→` prev/next (no prefix) · `<P> Tab` last MRU · `<P> L` link from session · `<P> !` break pane → window · `<P> j` join window → pane · `<P> m` activity monitor · `<P> M` silence monitor

## Panes — split / nav / size
`<P> \` split right · `<P> -` split down · `Alt+←↑↓→` move focus (no prefix) · `<P> ←↑↓→` move focus · `<P> C-o` rotate · `<P> Space` grid layout · `<P> v` / `h` force cols/rows · <code><P> &#124;</code> swap with pane 1 · `<P> x` kill (confirm) · `<P> z` zoom toggle (status `[Z]`) · `<P> C-←↑↓→` resize 1 cell (repeats) · mouse drag border = resize

## Copy mode (vi)
Scroll up = enter · `v` select · `V` line · `y`/`Enter` copy+cancel · `Y` line · `D` to EOL · `A` append · `C-j` copy+cancel · `Alt+↑↓` line · `Alt+PgUp/Dn` half · `PgUp/Dn` page · drag = auto-copy · `<P> p` paste · `<P> C-p` choose buffer

## Config / status
`<P> C-e` edit conf + reload · `<P> C-r` reload · `<P> C-s` toggle status bar
Status bar (top): `session | windows | [PREFIX]/[COPY]/[Z] | CPU | MEM | GPU | user@host | date`

---

## Appendix — gotchas

- **All kill bindings confirm.** `<P> x` (pane), `<P> X` (window), `<P> C-x` (other windows), and `<P> Q` (session) all prompt `confirm-before`.
- **`Alt+arrow` does *not* resize.** It's rebound to switch panes. For 5-cell resize you'd need to add it back; the 1-cell `<P> C-arrow` default still works.
- **Grid layout needs Python.** `<P> Space` / `v` / `h` shell out to `scripts/grid-layout.py`, which reads `pane-layouts.conf`. No Python → those binds no-op.
