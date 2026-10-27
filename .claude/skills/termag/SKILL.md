---
name: termag
description: Use a termag box (LaunchDarkly DevSpeed's EC2 agent workspaces) from the laptop. Covers first-time setup (CLI, SSM plugin, login, SSH key, GitHub, AWS profile), starting/creating a box, SSH over SSM, running git/Go/regen work on the box, and reviewing diffs with lazygit. Use when asked to use, set up, start, SSH into, or run work on a termag box, or when a heavy gonfalon task (merge + regen, bazel, dev stack) should run off the laptop.
argument-hint: [box-name] [task]
---

# termag

termag gives each user EC2 "boxes" (arm64, `t4g.medium`) with tmux-backed projects. Boxes have **no inbound network**: all access is SSH tunnelled through AWS SSM by the `termag` CLI. Docs: `launchdarkly/termag` → `USAGE.md`, `cli/README.md`. Web UI: https://app.termag.ldinfra.net/termag. Slack: #feedback-termag, #proj-devspeed-termag.

## 1. Check setup first

```bash
termag doctor          # read-only report; every line ok/warn/fail with a fix
termag box list        # BOX / STATE / AGENT / PROJECTS
```

If `termag` is missing or doctor reports failures, do the matching step below, then re-run doctor.

## 2. First-time setup (laptop)

Prereq the user must do: approved **"Termag Access"** in Lumos.

| Need | How |
|---|---|
| CLI | `git clone git@github.com:launchdarkly/termag.git ~/ld/termag && make -C ~/ld/termag install-cli` → `~/.local/bin/termag`. Update later with `termag update`. |
| SSM plugin | `brew install --cask session-manager-plugin` needs sudo. Without a TTY, unpack the official pkg instead: download `https://s3.amazonaws.com/session-manager-downloads/plugin/latest/mac_arm64/session-manager-plugin.pkg`, check `pkgutil --check-signature`, `pkgutil --expand-full`, `install -m755 …/Payload/usr/local/sessionmanagerplugin/bin/session-manager-plugin ~/.local/bin/`. |
| Login | `termag login` (browser approval). |
| SSH key | doctor only looks for `~/.ssh/id_{ed25519,ecdsa,rsa}.pub`. If none: `ssh-keygen -q -t ed25519 -N "" -f ~/.ssh/id_ed25519`, then the **user** pastes the `.pub` in web UI → Settings → SSH keys (`pbcopy < ~/.ssh/id_ed25519.pub`). doctor cannot register an existing key itself. |
| AWS profile + SSO | `termag doctor --yes` adds `[profile launchdarkly-termag]` and runs `aws sso login` (browser). |
| GitHub token | Needed before `termag box create` works ("Connect GitHub in Settings before adding a box"). Token needs `read:org`: user runs `env -u GITHUB_TOKEN gh auth refresh -h github.com -s read:org` (a `GITHUB_TOKEN` in the env blocks `gh auth refresh`), then `termag doctor --yes` stores it. |
| SSH config | `termag ssh-config --install` (re-run after adding a box) → `ssh termag-<box>` works. |

### Gotchas from real use

- **TTY required.** `termag login`/`doctor` refuse without a terminal ("needs a person at a terminal"). Wrap them in `script -q /dev/null termag login`. Prompts still read stdin, so `doctor` without `--yes` answers nothing.
- **`doctor --yes` hangs on ssh-keygen's passphrase prompt** when generating a key. Generate the key yourself first (above).
- **`gh auth refresh` can't run headless.** It waits for Enter, so hand it to the user (`! <cmd>` in Claude Code).
- **Global `IdentityFile` hides the termag key.** If `~/.ssh/config` has `Host *` + `IdentityFile <other key>`, ssh never offers `id_ed25519` → `Permission denied (publickey)`. Fix outside termag's managed block (which `ssh-config --install` rewrites):
  ```
  Host termag-*
    IdentityFile ~/.ssh/id_ed25519
  ```
  Debug with `ssh -v -o BatchMode=yes termag-<box> true 2>&1 | rg -i offering`.

## 3. Get a box running

```bash
termag box list
termag box start <box> --wait                 # stopped/hibernated → running (~1 min)
termag box create <name> --wait --if-not-exists   # new box, up to ~20 min; needs GitHub connected
termag ssh-config --install
```

Run long waits in the background. A box auto-parks when idle; `termag box keep <box>` resets the clock.

## 4. Working on the box

Always non-interactive and batch: `ssh -A -o BatchMode=yes termag-<box> '<cmds>'`, with a `timeout` around it.

- **GitHub from the box:** older boxes have no `gh` login and no `termag-setup`. Use agent forwarding (`-A`): the laptop's org-SSO-authorized key does git auth. On first use, seed known_hosts and **verify** the fingerprint matches GitHub's published one (ed25519 `SHA256:+DiY3wvvV6TuJJhbpZisF/zLDA0zPMSvHdkr4UvCOqU`):
  ```bash
  ssh-keyscan -t ed25519,rsa,ecdsa github.com >> ~/.ssh/known_hosts
  ssh-keygen -lf ~/.ssh/known_hosts | rg github
  ```
- **Remote shell is zsh.** `$VAR:a…` is a zsh modifier (`$M:apidocs` breaks), so write `${M}:path`. A command stored in a variable (`$G commit`) doesn't word-split. Non-interactive ssh doesn't load the PATH, so export it explicitly:
  ```bash
  export GOENV_ROOT=$HOME/.goenv PATH=$HOME/.goenv/bin:$HOME/.goenv/shims:$HOME/.local/bin:$PATH
  ```
- **Go:** goenv lives at `~/.goenv`. Match the repo's `.go-version`. If the version is unknown, run `git -C ~/.goenv pull` first, then `goenv install -s <v> && goenv global <v>`.
- **Repos:** `~/src/gonfalon` (often far behind `main`). Prefer a worktree per task: `git worktree add -B <branch> ~/src/<name> origin/<branch>`. Set `git config user.name/user.email` in the repo before committing.
- **gonfalon apidocs regen:** `make generate-api-assets` (~3 min on the box).
- **Pushing:** gonfalon's pre-push (pre-commit) hooks need `pre-commit` and `pnpm` on the box. Install them (`uv tool install pre-commit`, node/pnpm), or push with `--no-verify` **only when the user OKs skipping**.
- **Copy files:** `scp`/`rsync` with `termag-<box>:path`.

## 5. Reviewing before pushing

Commit on the box, **don't push**, and let the user review:

- lazygit (install once if missing: download `lazygit_<v>_linux_arm64.tar.gz` from jesseduffield/lazygit releases into `~/.local/bin`):
  ```
  ssh -t -A termag-<box> 'cd ~/src/<worktree> && ~/.local/bin/lazygit'
  ```
  Panel `4` = commits, Enter = files/diff, `q` = quit.
- Or compare the PR diff before/after against the **exact merged main** (`HEAD~1^2` of the merge), not `origin/main`, which may have moved since.

Push only after the user approves.

## 6. Better than ad-hoc SSH

- **Connection reuse:** add `ControlMaster auto`, `ControlPersist 4h`, `ControlPath ~/.ssh/cm-%r@%h:%p` under `Host termag-*` so repeated calls skip the slow SSM handshake.
- **Durable sessions:** `termag attach <box>/<project> [--ctrl]` attaches to the project's tmux session, which survives laptop sleep.
- **Agent on the box:** `termag ask <box>/<project> "<prompt>"`, the web UI, or Slack `/t`.
- **Ports:** `termag forward <box> 3000`, or `termag gonfalon-up` for gonfalon's dev stack on `localhost:8090`.
