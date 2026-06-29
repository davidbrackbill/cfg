# Global Memory

## Dev Setup

- **`~/init.sh`** — personal machine bootstrap script (dotfiles + brew installs). Add tools here when setting up work infrastructure that should be replicable on a new machine install.
- **`~/.cfg`** — bare git repo tracking dotfiles (including `~/.claude/settings.json` and `~/.claude/skills/`). Use `git --git-dir=$HOME/.cfg --work-tree=$HOME` to manage, or the `cfg` shell alias.

## Docker (macOS)

Using **Docker Desktop**. The `docker`/`docker compose` CLIs talk to whatever daemon is running; Desktop just supplies the Linux VM. **Colima is installed as a Desktop-free fallback** (`brew install colima docker docker-compose`; `colima start --cpu 4 --memory 8`).

**When Docker Desktop hangs** (`docker ps` blocks forever, no daemon socket):
- Cause: a half-started backend — `com.docker.backend` is running but the VM never booted, and stale `*.sock` files from a prior instance remain. A force-kill (`killall Docker`) is what *leaves* this orphaned state, so don't lead with it.
- Diagnose: `~/Library/Containers/com.docker.docker/Data/log/host/com.docker.virtualization.log` — a recent "running VM" line means the VM booted; its absence means it didn't. Stale sockets live in `Data/*.sock` and `~/.docker/run/docker.sock`.
- Clean-restart fix (this reliably works):
  1. `osascript -e 'quit app "Docker Desktop"'` (graceful first)
  2. `pkill -9 -f com.docker.backend` (kills the `--autostart` backend; leave root `com.docker.vmnetd`), confirm 0 stragglers
  3. `rm -f ~/Library/Containers/com.docker.docker/Data/*.sock ~/.docker/run/docker.sock`
  4. `open -a Docker`, then poll `docker ps` (~30–40s to come up)
- If it stalls twice, switch to Colima rather than fighting Desktop.

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
