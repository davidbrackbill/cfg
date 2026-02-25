# Available in all shells
cfg() { git --git-dir="$HOME/.cfg" --work-tree="$HOME" "$@"; }

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# [[Options]]
shopt -s histappend checkwinsize globstar nullglob expand_aliases autocd

HISTSIZE=100000
HISTFILESIZE=1000000
HISTCONTROL=ignoreboth
HISTIGNORE='ls:bg:fg:history'
HISTTIMEFORMAT='%F %T '
PROMPT_DIRTRIM=1

set -o vi
bind -f ~/.inputrc

# [[Sources]]
safe_source() { [ "$#" -eq 1 ] && [ -s "$1" ] && source "$1"; }



safe_source /opt/homebrew/opt/fzf/shell/key-bindings.bash
safe_source /opt/homebrew/etc/profile.d/bash_completion.sh
safe_source "$HOME/.ghcup/env"
safe_source "$HOME/.cargo/env"
safe_source ~/.git.env
safe_source ~/.ld.env
safe_source ~/.bash_aliases

# [[Exports]]
export EDITOR=nvim
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# PNPM
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
    *":$PNPM_HOME:"*) ;;
    *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# Go tools
export PATH="$PATH:$HOME/go/bin"

# [[Functions]]

# Fuzzy-find a file/dir under $dir
fr() {
    local dir="${1:-/}"
    fd . "$dir" --hidden --exclude .git --exclude node_modules --exclude __pycache__ |
        fzf-tmux --select-1 --query "${*:2}"
}

# Find and cd-to / open in nvim
f() {
    local path
    path=$(fr "$HOME" "$*")
    [[ -d $path ]] && cd "$path" || { cd "$(dirname "$path")" && nvim "$path"; }
}

# Yazi file manager, cd to exit dir
yy() {
    local tmp
    tmp="$(mktemp -t yazi-cwd.XXXXXX)"
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}

# Tmux attach (by name), or list sessions / open new
ta() {
    if [ -n "${1}" ]; then
        tmux a -t "${1}"
    else
        tmux ls || tmux
    fi
}

# Lazygit for dotfiles bare repo
cfgl() { lazygit --git-dir="$HOME/.cfg" --work-tree="$HOME"; }

# [[Mise]] — use shims (faster than eval activate which costs ~1.3s)
export PATH="$HOME/.local/share/mise/shims:$PATH"

# [[Starship prompt]]
command -v starship &>/dev/null && eval "$(starship init bash)"

safe_source ~/.velcro.launchdarklyrc
export PATH="/opt/homebrew/opt/openjdk@11/bin:$PATH"
