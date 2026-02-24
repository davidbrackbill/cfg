#!/usr/bin/env bash
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
    bash \
    neovim \
    fd \
    bat \
    eza \
    fzf \
    atuin \
    yazi \
    lazygit \
    fish \
    tmux \
    jujutsu \
    rm-improved \
    mise \
    starship

# ── Dotfiles ───────────────────────────────────────────────────────────────────
link() {
    local src="$REPO_DIR/$1"
    local dst="$HOME/$1"
    [ ! -e "$src" ] && return
    if [ -e "$dst" ] && [ ! -L "$dst" ]; then
        echo "  Backing up $dst → $dst.bak"
        mv "$dst" "$dst.bak"
    fi
    mkdir -p "$(dirname "$dst")"
    ln -sf "$src" "$dst"
    echo "  Linked ~/$1"
}

echo "==> Linking dotfiles..."
link .bashrc
link .bash_aliases
link .profile
link .gitconfig
link .inputrc
link .clang-format
link .prettierrc.json
link .tmux.conf
mkdir -p "$HOME/.config"
for d in atuin fish jj lazygit nvim yazi; do
    link ".config/$d"
done

# ── Private env file ───────────────────────────────────────────────────────────
if [ ! -f "$HOME/.ld.env" ]; then
    echo "==> Creating ~/.ld.env for private tokens..."
    cat > "$HOME/.ld.env" <<'EOF'
# Private environment variables — do NOT commit this file
# export GITHUB_TOKEN=
# export HOMEBREW_GITHUB_API_TOKEN=
EOF
    echo "  Created ~/.ld.env"
    echo "  Move your tokens here and remove them from ~/.bashrc.bak"
fi

# ── Homebrew bash ──────────────────────────────────────────────────────────────
BREW_BASH=/opt/homebrew/bin/bash
if ! grep -qF "$BREW_BASH" /etc/shells 2>/dev/null; then
    echo ""
    echo "To use Homebrew bash 5.x (system bash on Mac is 3.2 — missing globstar, autocd, etc.):"
    echo "  sudo sh -c 'echo $BREW_BASH >> /etc/shells'"
    echo "  chsh -s $BREW_BASH"
fi

echo ""
echo "Done."
