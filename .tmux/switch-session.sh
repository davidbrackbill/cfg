#!/bin/bash

# Get sessions sorted by activity (most recent first), with their names
SESSIONS=$(tmux list-sessions -F '#{session_activity}|#{session_name}' 2>/dev/null | sort -rn | cut -d'|' -f2)

# Run fzf with --print-query to capture user input
RESULT=$(fzf --tmux 80%,50% --print-query <<< "$SESSIONS" 2>/dev/null)

# Extract the query (what user typed) and the selection
QUERY=$(echo "$RESULT" | head -1)
SESSION=$(echo "$RESULT" | tail -1)

# If user selected a session, use it; otherwise use their typed query (creating new session if needed)
TARGET="${SESSION:-$QUERY}"

if [ -n "$TARGET" ]; then
  tmux switch-client -t "$TARGET" 2>/dev/null || tmux new-session -d -s "$TARGET" && tmux switch-client -t "$TARGET"
fi

exit 0
