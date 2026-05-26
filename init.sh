#!/usr/bin/env bash
# Usage: git clone https://github.com/davidbrackbill/cfg.git && bash cfg/init.sh
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

# ── Homebrew ───────────────────────────────────────────────────────────────────
if ! command -v brew &>/dev/null; then
    echo "==> Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# ── Tools ──────────────────────────────────────────────────────────────────────
echo "==> Installing tools..."
brew install \
    bash neovim fd bat eza fzf atuin yazi lazygit zoxide \
    fish tmux jujutsu rm-improved mise starship \
    tree-sitter-cli vjeantet/tap/alerter \
    1password-cli \
    timg \
    ankitpokhrel/jira-cli/jira-cli \
    docker-credential-helper-ecr

echo "==> Installing casks..."
brew tap notwadegrimridge/brew
brew install --cask \
    karabiner-elements \
    raycast \
    hammerspoon \
    betterdisplay

# ── Runtimes (via mise) ────────────────────────────────────────────────────────
echo "==> Installing runtimes via mise..."
mise install node@lts pnpm@latest
mise use -g node@lts pnpm@latest uv@latest
MISE_PYTHON_PRECOMPILED_FLAVOR=install_only mise use -g python@3.13
eval "$(mise activate bash)"
pnpm add -g @mermaid-js/mermaid-cli @aashari/mcp-server-atlassian-confluence sql-formatter tsc-files
npx puppeteer browsers install chrome-headless-shell

# ── pre-commit (linting/formatting hooks for foundation) ─────────────────────
echo "==> Installing pre-commit..."
mise use -g pipx:pre-commit

# ── nah (Claude Code permissions hook) ────────────────────────────────────────
echo "==> Installing nah..."
mise use -g pipx:nah
uv pip install pyyaml --python "$(mise where pipx-nah)/nah/bin/python"

# ── Bare repo ──────────────────────────────────────────────────────────────────
if [ ! -d "$HOME/.cfg" ]; then
    echo "==> Setting up bare repo at ~/.cfg..."
    cp -r "$REPO_DIR/.git" "$HOME/.cfg"
    git --git-dir="$HOME/.cfg" config --bool core.bare true
else
    echo "==> ~/.cfg already exists, skipping bare repo setup."
fi

cfg() { git --git-dir="$HOME/.cfg" --work-tree="$HOME" "$@"; }

echo "==> Checking out dotfiles to ~..."
if ! cfg checkout 2>/dev/null; then
    echo "  Backing up conflicting files to ~/.cfg-bak/..."
    mkdir -p "$HOME/.cfg-bak"
    cfg checkout 2>&1 \
        | grep -E "^\s+\S" \
        | awk '{print $1}' \
        | while read -r f; do
            mkdir -p "$HOME/.cfg-bak/$(dirname "$f")"
            mv "$HOME/$f" "$HOME/.cfg-bak/$f"
        done
    cfg checkout
fi

cfg config status.showUntrackedFiles no

# ── Git global config ──────────────────────────────────────────────────────────
git config --global core.excludesfile ~/.gitignore_global

# ── Private env ────────────────────────────────────────────────────────────────
if [ ! -f "$HOME/.ld.env" ]; then
    echo "==> Creating ~/.ld.env..."
    cat > "$HOME/.ld.env" <<'EOF'
# Private tokens — do not commit
# export GITHUB_TOKEN=
# export HOMEBREW_GITHUB_API_TOKEN=
EOF
fi

if [ ! -f "$HOME/.git.env" ]; then
    echo "==> Setting up git identity (~/.git.env)..."
    while true; do
        read -rp "  Git name:  " git_name
        read -rp "  Git email: " git_email
        echo ""
        echo "  Name:  $git_name"
        echo "  Email: $git_email"
        read -rp "  Look good? [y/n] " confirm
        [[ "$confirm" == "y" ]] && break
    done
    cat > "$HOME/.git.env" <<EOF
# Git identity — do not commit
export GIT_AUTHOR_NAME="$git_name"
export GIT_AUTHOR_EMAIL="$git_email"
export GIT_COMMITTER_NAME="\$GIT_AUTHOR_NAME"
export GIT_COMMITTER_EMAIL="\$GIT_AUTHOR_EMAIL"
EOF
    echo "  Saved to ~/.git.env"
fi

# ── Claude Code MCP servers ────────────────────────────────────────────────────
echo "==> Configuring Claude Code MCP servers..."
claude mcp add-json --scope user confluence '{"command":"npx","args":["-y","@aashari/mcp-server-atlassian-confluence"]}' 2>/dev/null || true
claude mcp add-json --scope user jira '{"command":"npx","args":["-y","@aashari/mcp-server-atlassian-jira"]}' 2>/dev/null || true
claude mcp add-json --scope user github '{"command":"npx","args":["-y","@modelcontextprotocol/server-github"]}' 2>/dev/null || true
claude mcp add --scope user --transport http figma https://mcp.figma.com/mcp 2>/dev/null || true

# ── Homebrew bash ──────────────────────────────────────────────────────────────
BREW_BASH=/opt/homebrew/bin/bash
if ! grep -qF "$BREW_BASH" /etc/shells 2>/dev/null; then
    echo ""
    echo "To switch to Homebrew bash:"
    echo "  sudo sh -c 'echo $BREW_BASH >> /etc/shells'"
    echo "  chsh -s $BREW_BASH"
fi

echo ""
echo "Done. Remove the clone: rm -rf $REPO_DIR"
echo "Then restart your shell."
