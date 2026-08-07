#!/usr/bin/env bash
# Open wt's picker in a throwaway tab, then dispose of the tab.
#
# Bound to a herdr `type = "shell"` command, which is the only type that can
# spawn a tab — `pane` and `popup` stay inside the current tab, and there is no
# `tab` type. This half runs detached with no TTY; the interactive picker runs
# inside the new tab's pane, which is where fzf needs a terminal.
set -euo pipefail

# A detached shell command does not inherit the pane's PATH.
export PATH="/opt/homebrew/bin:$HOME/.local/bin:/usr/bin:/bin:$PATH"

PANE=$(herdr tab create --label wt --focus | jq -r '.result.root_pane.pane_id')
[ -n "$PANE" ] && [ "$PANE" != "null" ] || exit 1

# --keep leaves the pane to us, so the tab is disposed of whether the picker
# completed or was aborted with esc/ctrl-c.
herdr pane run "$PANE" "wt open --keep; herdr pane close $PANE" >/dev/null
