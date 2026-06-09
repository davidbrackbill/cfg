#!/bin/bash
# Conditional nah guard — skip nah when in auto mode, otherwise run full nah validation

# Read the hook input from stdin
hook_input=$(cat)

# Check the current session's permission_mode from the hook input JSON
# When permission_mode is "auto", Auto mode is handling permissions
# so we skip nah to avoid redundancy
if echo "$hook_input" | jq -e '.permission_mode == "auto"' >/dev/null 2>&1; then
  # Auto mode is active — skip nah and let Auto mode handle it
  exit 0
fi

# Not in auto mode — run the nah guard
echo "$hook_input" | /Users/db/.claude/hooks/nah_guard.py
