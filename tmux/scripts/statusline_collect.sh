#!/usr/bin/env bash
#
# Status-line stat collector.
#
# Publishes CPU / MEM / GPU into the tmux user options @stat_cpu, @stat_mem and
# @stat_gpu once per status-interval. status-right reads those options, so
# drawing the status line expands pure tmux formats and forks nothing.
#
# The values used to be rendered inline with #(), which re-ran the sysstat
# scripts on every status redraw rather than once per status-interval: ~70
# execs/sec, of which ~14/sec were helpers reconnecting to the single-threaded
# tmux server. Keystrokes queued behind that traffic and typing went laggy while
# aggregate CPU still looked idle.
#
# Started from tmux.conf via run-shell -b. A per-user lock keeps one instance
# across config reloads; the loop exits once the tmux server goes away.
#
# Numbers match the definitions tmux-plugin-sysstat used, so the displayed
# values keep their previous meaning:
#   CPU  Linux: non-idle share of /proc/stat jiffies over the interval
#        macOS: 100 - idle% from `top -l 2`, whose second sample spans the interval
#        1 decimal on both
#   MEM  Linux: (MemTotal - MemAvailable) / MemTotal
#        macOS: (active + wired) / (active + wired + free + inactive +
#               speculative + compressor) vm_stat pages
#        rounded to whole percent on both
#   GPU  nvidia-smi utilization.gpu, whole percent
# Colors and view templates are still read from the @sysstat_* options, so
# customizing those in tmux.conf keeps working.

set -u
LC_NUMERIC=C

# One collector per user. Losing the race means another instance is live.
lock="${TMPDIR:-/tmp}/tmux-statusline-collect.$(id -u).lock"
if command -v flock >/dev/null 2>&1; then
  exec 9>"$lock" || exit 0
  flock -n 9 || exit 0
else
  # macOS ships no flock: a lock directory holding the owner's pid, reclaimed
  # once that pid is gone.
  if ! mkdir "$lock.d" 2>/dev/null; then
    kill -0 "$(cat "$lock.d/pid" 2>/dev/null)" 2>/dev/null && exit 0
    rm -rf "$lock.d"
    mkdir "$lock.d" 2>/dev/null || exit 0
  fi
  echo $$ >"$lock.d/pid"
  trap 'rm -rf "$lock.d"' EXIT
fi

os=$(uname -s)

opt() {
  local v
  v=$(tmux show-option -gqv "$1" 2>/dev/null)
  [[ -n $v ]] && printf '%s' "$v" || printf '%s' "$2"
}

# Read configuration once at startup, never in the loop.
interval=$(opt "status-interval" "5")
[[ $interval =~ ^[0-9]+$ ]] && ((interval > 0)) || interval=5

cpu_tmpl=$(opt "@sysstat_cpu_view_tmpl" 'CPU:#[fg=#{cpu.color}]#{cpu.pused}#[default]')
cpu_medium=$(opt "@sysstat_cpu_medium_threshold" "30")
cpu_stress=$(opt "@sysstat_cpu_stress_threshold" "80")
cpu_low_c=$(opt "@sysstat_cpu_color_low" "green")
cpu_med_c=$(opt "@sysstat_cpu_color_medium" "yellow")
cpu_str_c=$(opt "@sysstat_cpu_color_stress" "red")

mem_tmpl=$(opt "@sysstat_mem_view_tmpl" 'MEM:#[fg=#{mem.color}]#{mem.pused}#[default]')
mem_medium=$(opt "@sysstat_mem_medium_threshold" "75")
mem_stress=$(opt "@sysstat_mem_stress_threshold" "90")
mem_low_c=$(opt "@sysstat_mem_color_low" "green")
mem_med_c=$(opt "@sysstat_mem_color_medium" "yellow")
mem_str_c=$(opt "@sysstat_mem_color_stress" "red")

has_gpu=0
command -v nvidia-smi >/dev/null 2>&1 && has_gpu=1

# Same banding as the plugin's fcomp(): strictly above stress -> stress color.
pick_color() {
  awk -v v="$1" -v m="$2" -v s="$3" -v lc="$4" -v mc="$5" -v sc="$6" \
    'BEGIN { if (v > s) print sc; else if (v > m) print mc; else print lc }'
}

render() {
  local tmpl=$1 key=$2 value=$3 color=$4
  tmpl=${tmpl//"#{${key}.pused}"/$value}
  tmpl=${tmpl//"#{${key}.color}"/$color}
  printf '%s' "$tmpl"
}

if [[ $os == Darwin ]]; then
  # top waits one interval between its two samples, so this call is the
  # loop's pacing; the second sample is the one that covers the interval.
  sample_cpu() {
    cpu=$(LC_ALL=C top -l 2 -s "$interval" -n 0 |
      awk '/^CPU usage/ { for (i=2; i<=NF; i++) if ($i ~ /^idle/) idle=$(i-1) }
           END { sub(/%/, "", idle); printf "%.1f", 100-idle }')
  }

  sample_mem() {
    vm_stat | awk -F: '
      /^Pages (active|wired)/ { gsub(/[ .]/, "", $2); used+=$2 }
      /^Pages (free|inactive|speculative|occupied by compressor)/ { gsub(/[ .]/, "", $2); free+=$2 }
      END { if (used+free > 0) printf "%.0f", 100*used/(used+free); else printf "0" }'
  }
else
  cpu_totals() {
    awk '/^cpu /{ idle=$5+$6; total=0; for (i=2; i<=NF; i++) total+=$i; print total, idle; exit }' /proc/stat
  }

  read -r prev_total prev_idle < <(cpu_totals)

  # Sets $cpu instead of printing it: the previous totals must survive to the
  # next call, which a $(...) subshell would discard.
  sample_cpu() {
    sleep "$interval"
    local cur_total cur_idle
    read -r cur_total cur_idle < <(cpu_totals)
    cpu=$(awk -v pt="$prev_total" -v pi="$prev_idle" -v ct="$cur_total" -v ci="$cur_idle" \
      'BEGIN { dt=ct-pt; di=ci-pi; if (dt <= 0) printf "0.0"; else printf "%.1f", 100*(1-di/dt) }')
    prev_total=$cur_total
    prev_idle=$cur_idle
  }

  sample_mem() {
    awk '/^MemTotal:/{t=$2} /^MemAvailable:/{a=$2; exit} END { if (t > 0) printf "%.0f", 100*(t-a)/t; else printf "0" }' /proc/meminfo
  }
fi

while :; do
  sample_cpu
  mem=$(sample_mem)

  cpu_view=$(render "$cpu_tmpl" cpu "$cpu" "$(pick_color "$cpu" "$cpu_medium" "$cpu_stress" "$cpu_low_c" "$cpu_med_c" "$cpu_str_c")")
  mem_view=$(render "$mem_tmpl" mem "$mem" "$(pick_color "$mem" "$mem_medium" "$mem_stress" "$mem_low_c" "$mem_med_c" "$mem_str_c")")

  # Read-only utilization query: no CUDA context and no device memory, so it is
  # deliberately not taken through gpu-lock -- a status bar cannot hold that lock.
  gpu_view=""
  if ((has_gpu)); then
    gpu_view=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null | head -1)
    [[ $gpu_view =~ ^[0-9]+$ ]] || gpu_view="--"
  fi

  tmux set -gq @stat_cpu "$cpu_view" \; \
       set -gq @stat_mem "$mem_view" \; \
       set -gq @stat_gpu "$gpu_view" 2>/dev/null || exit 0
done
