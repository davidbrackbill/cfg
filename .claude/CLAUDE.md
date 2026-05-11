# Global Memory

## Dev Setup

- **`~/init.sh`** — personal machine bootstrap script (dotfiles + brew installs). Add tools here when setting up work infrastructure that should be replicable on a new machine install.
- **`~/.cfg`** — bare git repo tracking dotfiles (including `~/.claude/settings.json` and `~/.claude/skills/`). Use `git --git-dir=$HOME/.cfg --work-tree=$HOME` to manage, or the `cfg` shell alias.

## Runtime Management

- **mise** manages node (and other runtimes except Go). Use `mise install node@lts && mise use -g node@lts`. Do NOT use brew for node/python/ruby.
- **goenv** manages Go versions (`~/.goenv`). Do NOT use mise or brew for Go.
- pnpm globals install via `pnpm add -g <pkg>` after mise node is active. Do NOT use `npm install -g`.

## Skills

Skills live in `~/.claude/skills/<name>/SKILL.md` and are invoked as `/<name>`. Each `SKILL.md` has a YAML frontmatter block (`name`, `description`, `argument-hint`) followed by step-by-step instructions for Claude to follow when the skill is triggered. Skills are tracked in `~/.cfg`.

To create a new skill:
1. `mkdir ~/.claude/skills/<name>`
2. Write `~/.claude/skills/<name>/SKILL.md` with frontmatter + instructions
3. Track it: `cfg add ~/.claude/skills/<name>/SKILL.md && cfg commit`

## MCP Servers

Prefer MCP tools over other methods for these services:
- **Confluence** — use `confluence` MCP (search pages, read full content)
- **Jira** — use `jira` MCP (read issues, comments, fields)
- **GitHub** — use `github` MCP (PRs, issues, diffs)
- **Slack** — no MCP; use `ld research` CLI (see below)

## Jira CLI (`jira`)

Installed via brew (`ankitpokhrel/jira-cli/jira-cli`). Useful for creating/editing issues from the terminal.

```bash
jira issue list -p MTRX                  # list issues in MTRX project
jira issue view MTRX-123                 # view issue details
jira issue create -p MTRX               # create issue (interactive)
jira issue edit MTRX-123                # edit issue
jira issue move MTRX-123 "In Progress"  # transition issue
jira issue comment add MTRX-123         # add comment
jira open MTRX-123                      # open in browser
```

Config: `~/.config/.jira/.config.yml`

## ld CLI (Internal Tools)

See [`~/.claude/ld-tools.md`](.claude/ld-tools.md) for full usage.

## Testing Practices

When testing code changes, always add test cases to the project's existing test directory rather than creating temporary test files. This ensures:
- Changes are persisted and can be reviewed
- Tests are discoverable and maintainable
- The test suite grows with the codebase
- Other developers can understand what was being tested

Do NOT create random temp testers or one-off test files in `/tmp/` unless explicitly requested.
