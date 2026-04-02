#!/bin/bash
input=$(cat)
USED=$(echo "$input" | jq -r '.context_window.current_usage | .input_tokens + .output_tokens + .cache_creation_input_tokens + .cache_read_input_tokens // 0')
MAX=$(echo "$input" | jq -r '.context_window.context_window_size // 1000000')
MODEL_ID=$(echo "$input" | jq -r '.model.id // "?"' | tr '[:upper:]' '[:lower:]')
case "$MODEL_ID" in
  *opus*) SYMBOL="🐘" ;;
  *sonnet*) SYMBOL="🦊" ;;
  *haiku*) SYMBOL="🐭" ;;
  *) SYMBOL="?" ;;
esac
UNIT_SIZE=40000
FILLED=$((USED / UNIT_SIZE))
MAX_FILLED=$((MAX / UNIT_SIZE))
BAR=$(printf "%${FILLED}s" | tr ' ' '|')$(printf "%$((MAX_FILLED - FILLED))s")
SESSION_ID=$(echo "$input" | jq -r '.session_id // ""')

echo "$SYMBOL [$BAR] $SESSION_ID"