---
name: lode
description: Save session context to an Obsidian note in ~/libdarkly. Use when the user wants to document findings, files touched, or investigation context for a ticket or epic. Argument should be a Jira ticket key (e.g. MTRX-1755).
argument-hint: <TICKET-KEY>
---

Save the current session's context to an Obsidian note at `~/libdarkly/epics/<epic-folder>/<ticket>.md`.

Steps:

1. **Derive the JSONL path** (same as the `tools` skill):
   - Slugify cwd by replacing all `/` with `-` (result starts with `-`)
   - Path is: `~/.claude/projects/<slug>/<session-id>.jsonl`

2. **Determine the ticket key** from $ARGUMENTS (e.g. `MTRX-1755`). Derive the epic folder as the ticket prefix + `-1` (e.g. `mtrx-1` for `MTRX-1755`). Lowercase both.

3. **Extract files touched** from the JSONL using jq:
```
jq -r 'select(.type=="assistant") | .message.content[]? | select(.type=="tool_use") | select(.name | test("Read|Write|Edit|Glob|Grep")) | .input | (.file_path // .path // .pattern // "")' <jsonl_path> | sort -u | grep -v '^$'
```

4. **Determine the note path**: `~/libdarkly/epics/<epic-folder>/<ticket-lowercase>.md`
   - If the file already exists, **append** a new session section rather than overwriting.
   - If it doesn't exist, create it.

5. **Write or append** the following to the note:

```markdown
## Session — <today's date>

Jira: https://launchdarkly.atlassian.net/browse/<TICKET>
JSONL: [<session-id>](file:///Users/db/.claude/projects/<slug>/<session-id>.jsonl)

### Files Touched

<list of files from step 3, one per line as a markdown list>
```

6. **Search other JSONL files** in the same projects folder for related sessions:
   - For each JSONL that isn't the current session, search user messages for the ticket key, epic name, or related keywords
   - Use jq: `jq -r 'select(.type=="user") | .message.content | if type=="array" then .[].text? else . end' <path> 2>/dev/null | grep -i "<ticket>"`
   - For each matching session, derive a human-readable title by reading the first few assistant messages to understand the session topic
   - Use jq: `jq -r 'select(.type=="assistant") | .message.content[]? | select(.type=="text") | .text' <path> 2>/dev/null | grep -v '^\s*$' | head -3`
   - Get the file modification date via `stat -f "%Sm" -t "%Y-%m-%d" <path>`
   - Append matching sessions sorted by date as: `- <date> [<descriptive title>](file:///Users/db/.claude/projects/...)`

7. Confirm to the user what was written and where, and list any additional related sessions found.
