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

# Check for git worktree
WORKTREE=""
if git_dir=$(git rev-parse --git-dir 2>/dev/null); then
  if [[ $git_dir =~ worktrees/([^/]+) ]]; then
    WORKTREE="${BASH_REMATCH[1]}"
  fi
fi

echo "$SYMBOL [$BAR] $WORKTREE"
