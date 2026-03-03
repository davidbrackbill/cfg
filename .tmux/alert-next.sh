#!/usr/bin/env bash
# Jump to next alerted window across all sessions
TARGET=$(tmux list-windows -a -F '#{session_name}:#{window_index} #{window_bell_flag}' | awk '$2==1{print $1; exit}')
[ -n "$TARGET" ] && tmux switch-client -t "$TARGET" || true
