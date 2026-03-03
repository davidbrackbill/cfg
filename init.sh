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
    bash neovim fd bat eza fzf atuin yazi lazygit \
    fish tmux jujutsu rm-improved mise starship \
    tree-sitter-cli vjeantet/tap/alerter

# ── Bare repo ──────────────────────────────────────────────────────────────────
echo "==> Setting up bare repo at ~/.cfg..."
cp -r "$REPO_DIR/.git" "$HOME/.cfg"
git --git-dir="$HOME/.cfg" config --bool core.bare true

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
