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
ESC=$'\033'
# Each mark sits at k * UNIT_SIZE tokens: yellow past 150k, red past 250k
FILLED_BAR=""
for ((k = 1; k <= FILLED; k++)); do
  if ((k * UNIT_SIZE > 250000)); then
    FILLED_BAR+="${ESC}[31m|${ESC}[0m"
  elif ((k * UNIT_SIZE > 150000)); then
    FILLED_BAR+="${ESC}[33m|${ESC}[0m"
  else
    FILLED_BAR+="|"
  fi
done
EMPTY_BAR=$(printf "%$((MAX_FILLED - FILLED))s")
SESSION_ID=$(echo "$input" | jq -r '.session_id // ""')

printf "%s [%s%s] %s\n" "$SYMBOL" "$FILLED_BAR" "$EMPTY_BAR" "$SESSION_ID"