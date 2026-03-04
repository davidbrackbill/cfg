---
name: tools
description: Show all tool calls made in the current session. Use when asked "what did you do", "show me your tool calls", "what tools did you use", or "what did you just do".
argument-hint: [filter]
---

Show the tool calls made in this session by reading the current session's JSONL transcript.

Steps:
1. Derive the JSONL path:
   - Slugify cwd by replacing all `/` with `-` (result starts with `-`)
   - Path is: `~/.claude/projects/<slug>/<session-id>.jsonl`
2. Run this jq command via Bash:
```
jq -c 'select(.type=="assistant") | .message.content[]? | select(.type=="tool_use") | {tool: .name, input: .input}' <path>
```
3. If $ARGUMENTS is provided, filter to only show tool calls where `.tool` matches (case-insensitive).
4. Display results as a clean table or list: timestamp (from the parent record's `.timestamp`), tool name, and a brief summary of the input (not the full blob — e.g. for Bash show the command, for Read/Write/Edit show the file path).

If no tool calls are found, say so clearly.
