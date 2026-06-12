#!/usr/bin/env python3
"""Arrange the current tmux window's panes into a preferred grid.

Reads ~/.config/tmux/pane-layouts.conf to decide, per pane count, how many
columns to use and how many panes stack in each column. Builds a tmux layout
string (with the correct checksum) and applies it with `select-layout`.

Usage (normally via a key binding):
    grid-layout.py            # use the config / balanced fallback
    grid-layout.py v          # force a single row of columns (vertical bars)
    grid-layout.py h          # force a single column of rows (horizontal bars)

Panes are placed column-major: column 1 top-to-bottom, then column 2, etc.,
in current pane-index order. Pane contents are preserved; only positions change.
"""
import math
import os
import subprocess
import sys

CONFIG = os.path.expanduser("~/.config/tmux/pane-layouts.conf")


def tmux(*args):
    return subprocess.check_output(["tmux", *args], text=True).strip()


def load_config():
    """Return {pane_count: [rows_per_column, ...]}."""
    spec = {}
    try:
        with open(CONFIG) as f:
            lines = f.readlines()
    except FileNotFoundError:
        return spec
    for line in lines:
        line = line.split("#", 1)[0].strip()
        if not line or "=" not in line:
            continue
        key, val = line.split("=", 1)
        try:
            n = int(key.strip())
            cols = [int(x) for x in val.split()]
        except ValueError:
            continue
        if cols and sum(cols) == n:
            spec[n] = cols
    return spec


def balanced_columns(n):
    """Fallback: ceil(sqrt(n)) columns, panes spread as evenly as possible
    with any remainder going to the leftmost columns."""
    k = max(1, math.ceil(math.sqrt(n)))
    base, rem = divmod(n, k)
    return [base + (1 if i < rem else 0) for i in range(k)]


def split_sizes(total, n):
    """Split `total` cells across n panes, accounting for (n-1) 1-cell borders.
    Returns a list of sizes summing to total - (n-1)."""
    avail = total - (n - 1)
    base, rem = divmod(avail, n)
    return [base + (1 if i < rem else 0) for i in range(n)]


def checksum(body):
    csum = 0
    for ch in body:
        csum = (csum >> 1) + ((csum & 1) << 15)
        csum = (csum + ord(ch)) & 0xFFFF
    return csum


def build_layout(width, height, columns, pane_ids):
    """columns: list of row-counts per column. Returns a tmux layout string."""
    col_widths = split_sizes(width, len(columns))
    cells = []
    pid = iter(pane_ids)
    x = 0
    for ci, rows in enumerate(columns):
        w = col_widths[ci]
        if rows == 1:
            cells.append(f"{w}x{height},{x},0,{next(pid)}")
        else:
            row_heights = split_sizes(height, rows)
            sub = []
            y = 0
            for ri in range(rows):
                h = row_heights[ri]
                sub.append(f"{w}x{h},{x},{y},{next(pid)}")
                y += h + 1
            cells.append(f"{w}x{height},{x},0[" + ",".join(sub) + "]")
        x += w + 1

    if len(cells) == 1 and "[" not in cells[0] and "{" not in cells[0]:
        body = f"{width}x{height},0,0,{pane_ids[0]}"
    elif len(cells) == 1:
        # single column of stacked rows -> top level is a vertical split
        inner = cells[0].split("[", 1)[1].rsplit("]", 1)[0]
        body = f"{width}x{height},0,0[" + inner + "]"
    else:
        body = f"{width}x{height},0,0{{" + ",".join(cells) + "}"
    return f"{checksum(body):04x},{body}"


def main():
    force = sys.argv[1] if len(sys.argv) > 1 else None
    win = tmux("display-message", "-p", "#{window_id}")
    width = int(tmux("display-message", "-t", win, "-p", "#{window_width}"))
    height = int(tmux("display-message", "-t", win, "-p", "#{window_height}"))
    pane_ids = [int(p.lstrip("%"))
                for p in tmux("list-panes", "-t", win, "-F", "#{pane_id}").splitlines()]
    n = len(pane_ids)
    if n <= 1:
        return

    if force == "v":
        columns = [1] * n
    elif force == "h":
        columns = [n]
    else:
        columns = load_config().get(n) or balanced_columns(n)

    layout = build_layout(width, height, columns, pane_ids)
    tmux("select-layout", "-t", win, layout)


if __name__ == "__main__":
    main()
