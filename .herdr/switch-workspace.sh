#!/usr/bin/env bash
# herdr equivalent of switch-session.sh — fuzzy-pick an existing workspace,
# or type a name that doesn't exist yet to create it.
set -euo pipefail

MAP=$(herdr workspace list | jq -r '.result.workspaces[] | "\(.label)\t\(.workspace_id)"')

RESULT=$(cut -f1 <<< "$MAP" | fzf --print-query 2>/dev/null)

QUERY=$(head -1 <<< "$RESULT")
LABEL=$(tail -1 <<< "$RESULT")

TARGET="${LABEL:-$QUERY}"
[ -n "$TARGET" ] || exit 0

WORKSPACE_ID=$(awk -F'\t' -v l="$TARGET" '$1==l{print $2; exit}' <<< "$MAP")

if [ -n "$WORKSPACE_ID" ]; then
  herdr workspace focus "$WORKSPACE_ID"
else
  herdr workspace create --label "$TARGET" --focus
fi
