#!/usr/bin/env bash
# Usage (on a termag box): git clone git@github.com:davidbrackbill/cfg.git && bash cfg/install.sh
# termag's dotfiles claim runs this from ~/.dotfiles, non-interactively.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
mkdir -p "$HOME/.local/bin"

# ── Tools ──────────────────────────────────────────────────────────────────────
echo "==> Installing tools (apt)..."
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update -qq
sudo apt-get install -y -qq \
    bash bash-completion fd-find bat eza zoxide fzf ripgrep jq tmux tree

if ! command -v starship &>/dev/null; then
    echo "==> Installing starship..."
    curl -fsSL https://starship.rs/install.sh | sh -s -- --yes --bin-dir "$HOME/.local/bin"
fi

# ── Git identity ───────────────────────────────────────────────────────────────
git_name="${TERMAG_OWNER_NAME:-$(git config --global --includes user.name 2>/dev/null || true)}"
git_email="${TERMAG_OWNER_EMAIL:-$(git config --global --includes user.email 2>/dev/null || true)}"
if { [ -z "$git_name" ] || [ -z "$git_email" ]; } && [ -t 0 ]; then
    read -rp "  Git name:  " git_name
    read -rp "  Git email: " git_email
fi
if [ -n "$git_name" ] && [ -n "$git_email" ]; then
    git config --file "$HOME/.gitconfig-local" user.name "$git_name"
    git config --file "$HOME/.gitconfig-local" user.email "$git_email"
    echo "  Saved git identity to ~/.gitconfig-local"
else
    echo "  No git identity available; set user.name and user.email in ~/.gitconfig-local"
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
cd "$HOME"

echo "==> Checking out dotfiles to ~..."
backup="$HOME/.cfg-bak/$(date +%Y%m%d-%H%M%S)"
cfg ls-tree -r --name-only HEAD | while read -r f; do
    if [ -e "$HOME/$f" ] || [ -L "$HOME/$f" ]; then
        if ! cfg show "HEAD:$f" 2>/dev/null | cmp -s - "$HOME/$f"; then
            mkdir -p "$backup/$(dirname "$f")"
            mv "$HOME/$f" "$backup/$f"
        fi
    fi
done
[ -d "$backup" ] && echo "  Backed up replaced files to $backup/"
cfg checkout -f HEAD -- ':/'
cfg reset -q

cfg config status.showUntrackedFiles no
cfg remote set-url origin git@github.com:davidbrackbill/cfg.git

# ── tmux plugins ───────────────────────────────────────────────────────────────
"$HOME/.tmux/plugins/tpm/bin/install_plugins" >/dev/null || echo "  tpm plugin install failed; run prefix+I in tmux"

# ── Login shell: bash ──────────────────────────────────────────────────────────
me="$(id -un)"
if [ "$(getent passwd "$me" | cut -d: -f7)" != "/bin/bash" ]; then
    echo "==> Switching login shell to bash..."
    sudo chsh -s /bin/bash "$me"
fi

echo ""
echo "Done. Remove the clone: rm -rf $REPO_DIR"
echo "New tmux panes and ssh sessions will start bash."
