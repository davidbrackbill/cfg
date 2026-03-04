# Global Memory

## Dev Setup

- **`~/init.sh`** — personal machine bootstrap script (dotfiles + brew installs). Add tools here when setting up work infrastructure that should be replicable on a new machine install.
- **`~/.cfg`** — bare git repo tracking dotfiles (including `~/.claude/settings.json` and `~/.claude/skills/`). Use `git --git-dir=$HOME/.cfg --work-tree=$HOME` to manage, or the `cfg` shell alias.

## Runtime Management

- **mise** manages node (and other runtimes except Go). Use `mise install node@lts && mise use -g node@lts`. Do NOT use brew for node/python/ruby.
- **goenv** manages Go versions (`~/.goenv`). Do NOT use mise or brew for Go.
- npm globals install via `npm install -g <pkg>` after mise node is active.

## ld CLI (Internal Tools)

See [`~/.claude/ld-tools.md`](.claude/ld-tools.md) for full usage.
