---
name: termag
description: Use a termag box (LaunchDarkly DevSpeed's EC2 agent workspaces) from the laptop. Covers first-time setup (CLI, SSM plugin, login, SSH key, GitHub, AWS profile), starting/creating a box, SSH over SSM, running git/Go/regen work on the box, and reviewing diffs with lazygit. Use when asked to use, set up, start, SSH into, or run work on a termag box, or when a heavy gonfalon task (merge + regen, bazel, dev stack) should run off the laptop.
argument-hint: <what to do on the box, e.g. "run spec regen on PR 74844">
---

# termag

## Task mode

The arguments are **a task to carry out on the box**, e.g. `/termag run spec regen on PR 74844`. Do it end to end:

1. **Preflight** (§1): `termag doctor` and `termag box list`. Fix setup gaps (§2). If the box is parked, start it (§3). Use the user's only box unless they named one.
2. **Resolve the target.** For a PR, run `gh pr view <n> -R launchdarkly/<repo> --json headRefName,baseRefName` to get the branch. Repo defaults to gonfalon.
3. **Prepare a worktree on the box** (§4): fetch, then `git worktree add -B <branch> ~/src/<short-name> origin/<branch>`. If it already exists, reuse it and `git pull --ff-only`.
4. **Do the task** in that worktree over `ssh -A -o BatchMode=yes termag-<box>`. Run anything that takes minutes in the background. Common recipes:
   - *spec regen (gonfalon):* `make generate-api-assets`, then check `git status`. Expect only `apidocs/*`, `packages/openapi/**` and generated mocks to change. Anything else means the regen picked up something unexpected, so flag it.
   - *merge main / resolve conflicts:* `git merge origin/main`. Hand-resolve source files, take `--theirs` for generated files and regen afterwards, then `gofmt` the Go.
   - *tests/build:* run the repo's normal command for the touched package.
5. **Commit on the box. Don't push.** Summarize what changed (files, +/-, anything surprising) and give the lazygit command (§5). Push only after the user OKs it.

If the task is only about setup or access ("set up termag", "ssh into my box"), do just that part.

termag gives each user EC2 "boxes" (arm64, `t4g.medium`) with tmux-backed projects. Boxes have **no inbound network**: all access is SSH tunnelled through AWS SSM by the `termag` CLI. Docs: `launchdarkly/termag` → `USAGE.md`, `cli/README.md`. Web UI: https://app.termag.ldinfra.net/termag. Slack: #feedback-termag, #proj-devspeed-termag.

## 1. Check setup first

```bash
termag doctor          # read-only report; every line ok/warn/fail with a fix
termag box list        # BOX / STATE / AGENT / PROJECTS
```

If `termag` is missing or doctor reports failures, do the matching step below, then re-run doctor.

**Expired SSO:** if any termag/ssh call prints ``has an expired AWS SSO session``, run `aws sso login --profile launchdarkly-termag` yourself in the background (it opens the browser and polls; no TTY needed), tell the user to approve it in the browser, and retry once it exits 0. Don't hand the command back to the user.

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
- **herdr:** not baked into either box image (full or `--minimal`). Before any herdr use on a box, ensure it's there. The official installer is idempotent: it puts the aarch64 binary at `~/.local/bin/herdr` and checks its SHA-256 against the release manifest:
  ```bash
  ssh -o BatchMode=yes termag-<box> 'export PATH=$HOME/.local/bin:$PATH; command -v herdr >/dev/null || curl -fsSL https://herdr.dev/install.sh | sh; herdr --version'
  ```
  Update an existing install with `herdr update` on the box. (An interactive `herdr --remote` also offers to install it, but a non-interactive one fails instead.)

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
- **herdr on the box:** after the install step in §4, the user runs `herdr --remote termag-<box>` in its own terminal window from the laptop. The box's herdr server owns the panes and the laptop draws the UI. A local `herdr` in another window stays independent. To keep Local and the box in one herdr window, use herdr's saved SSH machines (https://herdr.dev/docs/connecting-machines/). Don't run `--remote` from inside a local herdr pane, because the nested prefix keys clash.
- **Agent on the box:** `termag ask <box>/<project> "<prompt>"`, the web UI, or Slack `/t`.
- **Ports:** `termag forward <box> 3000`, or `termag gonfalon-up` for gonfalon's dev stack on `localhost:8090`.
