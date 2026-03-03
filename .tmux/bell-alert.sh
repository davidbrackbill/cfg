#!/usr/bin/env bash
# Called from tmux alert-bell hook: bell-alert.sh <session> <window_index> <window_name>
SESSION="$1"
WINDOW="$2"
WINDOW_NAME="$3"

RESPONSE=$(alerter \
  --title "$SESSION/$WINDOW_NAME" \
  --message " " \
  --timeout 10 \
  --group "tmux-bell-$SESSION-$WINDOW")

if [ "$RESPONSE" = "@CONTENTCLICKED" ]; then
  tmux switch-client -t "$SESSION:$WINDOW"
fi
