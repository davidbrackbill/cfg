#!/bin/bash
input=$(cat)
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
FILLED=$((PCT / 5))
BAR=$(printf "%${FILLED}s" | tr ' ' '|')$(printf "%$((20 - FILLED))s")
echo "[$BAR]"
