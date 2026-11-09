#!/usr/bin/env bash
# Usage (on a termag box): git clone -b linux git@github.com:davidbrackbill/cfg.git && bash cfg/init.sh
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
mkdir -p "$HOME/.local/bin"

# ── Tools ──────────────────────────────────────────────────────────────────────
echo "==> Installing tools (apt)..."
sudo apt-get update -qq
sudo apt-get install -y -qq \
    bash bash-completion fd-find bat eza zoxide fzf ripgrep jq tmux tree

if ! command -v starship &>/dev/null; then
    echo "==> Installing starship..."
    curl -fsSL https://starship.rs/install.sh | sh -s -- --yes --bin-dir "$HOME/.local/bin"
fi

# ── Git identity ───────────────────────────────────────────────────────────────
if [ ! -f "$HOME/.git.env" ]; then
    git_name="$(git config --global user.name 2>/dev/null || true)"
    git_email="$(git config --global user.email 2>/dev/null || true)"
    if [ -z "$git_name" ] || [ -z "$git_email" ]; then
        read -rp "  Git name:  " git_name
        read -rp "  Git email: " git_email
    fi
    cat > "$HOME/.git.env" <<EOF
# Git identity — do not commit
export GIT_AUTHOR_NAME="$git_name"
export GIT_AUTHOR_EMAIL="$git_email"
export GIT_COMMITTER_NAME="\$GIT_AUTHOR_NAME"
export GIT_COMMITTER_EMAIL="\$GIT_AUTHOR_EMAIL"
EOF
    echo "  Saved git identity to ~/.git.env"
fi

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
    backup="$HOME/.cfg-bak/$(date +%Y%m%d-%H%M%S)"
    echo "  Backing up conflicting files to $backup/..."
    cfg checkout 2>&1 \
        | grep -E "^\s+\S" \
        | awk '{print $1}' \
        | while read -r f; do
            mkdir -p "$backup/$(dirname "$f")"
            mv "$HOME/$f" "$backup/$f"
        done
    cfg checkout
fi

cfg config status.showUntrackedFiles no

# ── tmux plugins ───────────────────────────────────────────────────────────────
"$HOME/.tmux/plugins/tpm/bin/install_plugins" >/dev/null || echo "  tpm plugin install failed; run prefix+I in tmux"

# ── Login shell: bash ──────────────────────────────────────────────────────────
if [ "$(getent passwd "$USER" | cut -d: -f7)" != "/bin/bash" ]; then
    echo "==> Switching login shell to bash..."
    sudo chsh -s /bin/bash "$USER"
fi

echo ""
echo "Done. Remove the clone: rm -rf $REPO_DIR"
echo "New tmux panes and ssh sessions will start bash."
