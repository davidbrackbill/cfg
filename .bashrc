# Available in all shells
cfg() { git --git-dir="$HOME/.cfg" --work-tree="$HOME" "$@"; }

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# [[Options]]
shopt -s histappend checkwinsize globstar nullglob expand_aliases autocd
set -o ignoreeof

HISTSIZE=100000
HISTFILESIZE=1000000
HISTCONTROL=ignoreboth
HISTIGNORE='ls:bg:fg:history'
HISTTIMEFORMAT='%F %T '
PROMPT_DIRTRIM=1

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

# libpq (psql for CRDB access) — must come before /opt/homebrew/bin
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"

# LD dev tools (awslogin, update-aws-config, etc.)
export PATH="$PATH:$HOME/ld/dev/bin"

# Local project binaries
export PATH="$HOME/db/bin:$PATH"

# [[FZF]]
export FZF_DEFAULT_COMMAND='fd --hidden --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --exclude .git'

# [[Functions]]

# Fuzzy find and open: dirs→yazi, text files→nvim, binary→macOS default
f() {
    local path
    path=$(fd --hidden --exclude .git | fzf --tmux 80% --select-1 --query "$*")
    [[ -z "$path" ]] && return
    if [[ -d "$path" ]]; then
        yy "$path"
    elif file --brief --mime "$path" | grep -q '^image/\|^application/pdf'; then
        open "$path"
    else
        nvim "$path"
    fi
}

# Yazi file manager, cd to exit dir
yy() {
    tmux rename-window "≡" 2>/dev/null
    trap 'tmux rename-window "$" 2>/dev/null' INT TERM
    local tmp
    tmp="$(mktemp -t yazi-cwd.XXXXXX)"
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        cd -- "$cwd"
    fi
    rm -f -- "$tmp"
    tmux rename-window '$' 2>/dev/null
    trap - INT TERM
}

# Tmux attach (by name), or list sessions / open new
ta() {
    if [ -n "${1}" ]; then
        tmux a -t "${1}"
    else
        tmux ls || tmux
    fi
}

rgf() {
  local pattern="${1:-}"
  fzf --ansi \
      --disabled \
      --query "$pattern" \
      --bind "start:reload:rg --line-number --color=always {q}" \
      --bind "change:reload:rg --line-number --color=always {q} || true" \
      --delimiter : \
      --preview 'bat --highlight-line {2} {1}' \
      --bind "enter:become(nvim {1} +{2} +'set hlsearch' +'let @/=\"{q}\"')"
}

# Lazygit for dotfiles bare repo
cfgl() { lazygit --git-dir="$HOME/.cfg" --work-tree="$HOME"; }


# Window renames — higher-order helper captures previous name so nested calls restore correctly
_with_icon() {
  local icon="$1"; shift
  local prev
  prev=$(tmux display-message -p '#W' 2>/dev/null)
  (
    trap "tmux rename-window '$prev' 2>/dev/null" EXIT
    tmux rename-window "$icon" 2>/dev/null
    command "$@"
  )
}
clod()    { _with_icon "✦" claude "$@"; }
lazygit() { _with_icon "∆" lazygit "$@"; }
nvim()    { _with_icon "¶" nvim "$@"; }

# [[Mise]] — use shims (faster than eval activate which costs ~1.3s)
export PATH="$HOME/.local/share/mise/shims:$PATH"

# [[Starship prompt]]
command -v starship &>/dev/null && eval "$(starship init bash)"
[ -n "$TMUX" ] && PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND; }~/.tmux/plugins/tmux-continuum/scripts/continuum_save.sh"

# [[History sharing across sessions]]
# Append to file, clear session buffer, then reload — keeps history in sync across terminals
PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND; }history -a; history -c; history -r"

safe_source ~/.velcro.launchdarklyrc
export PATH="/opt/homebrew/opt/openjdk@11/bin:$PATH"
. "$HOME/.cargo/env"

# Something setting this can prevent Lazygit amend commit from opening in nvim
unset GIT_EDITOR

# [[Obsidian]]
export PATH="/Applications/Obsidian.app/Contents/MacOS:$PATH"

# [[Local .bashrc.local]] — source from root down to current directory
_source_bashrc_local() {
  local dirs=()
  local dir="$PWD"
  while [[ "$dir" != "/" ]]; do
    dirs+=("$dir")
    dir=$(dirname "$dir")
  done
  for ((i=${#dirs[@]}-1; i>=0; i--)); do
    [[ -f "${dirs[i]}/.bashrc.local" ]] && source "${dirs[i]}/.bashrc.local"
  done
}
_source_bashrc_local

# [[Zoxide]] — must be last to hook cd properly
command -v zoxide &>/dev/null && eval "$(zoxide init bash)"
