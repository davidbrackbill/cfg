#!/usr/bin/env bash
# Auto-fix golangci-lint issues after Claude edits a .go file.
# Runs from PostToolUse Write|Edit in ~/.claude/settings.json.

f=$(jq -r '.tool_input.file_path // empty' 2>/dev/null)
[[ "$f" == *.go ]] || exit 0

root=$(git -C "$(dirname "$f")" rev-parse --show-toplevel 2>/dev/null) || exit 0
cd "$root" || exit 0

# Only proceed if this is a Go module
[[ -f go.mod ]] || exit 0

cfg=()
[[ -f .golangci.yml ]] && cfg=(--config .golangci.yml)

# Prefer project-local install, fall back to global
if go tool golangci-lint version &>/dev/null 2>&1; then
  go tool golangci-lint run --fix "${cfg[@]}" ./... 2>/dev/null
elif command -v golangci-lint &>/dev/null; then
  golangci-lint run --fix "${cfg[@]}" ./... 2>/dev/null
fi

exit 0
