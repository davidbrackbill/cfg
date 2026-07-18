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
safe_source "$HOME/.ghcup/env"
safe_source "$HOME/.cargo/env"
safe_source ~/.git.env
safe_source ~/.ld.env
safe_source ~/.ecrrc
safe_source ~/.bash_aliases
safe_source ~/.velcro.launchdarklyrc

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

# Docker
export PATH="/Applications/Docker.app/Contents/Resources/bin:$PATH"

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

# [[Bazel cleanup]]
bazel-orphanage() {
  local dirs=()
  for dir in /private/var/tmp/_bazel_db/*/; do
    local ws=$(cat "$dir/DO_NOT_BUILD_HERE" 2>/dev/null | head -1)
    if [[ -n "$ws" && ! -d "$ws" ]]; then
      echo "Orphaned: $ws"
      dirs+=("$dir")
    fi
  done
  if [[ ${#dirs[@]} -gt 0 ]]; then
    echo "Removing ${#dirs[@]} orphaned output bases..."
    sudo rm -rf "${dirs[@]}"
    echo "Done"
  else
    echo "No orphaned Bazel output bases found"
  fi
}

# Bazel CI tests need aws to be logged in
alias bazel='aws-check && command bazel'

# [[Mise]] — use shims (faster than eval activate which costs ~1.3s)
export PATH="$HOME/.local/share/mise/shims:$PATH"

# [[Goenv]]
export GOENV_ROOT="$HOME/.goenv"
export PATH="$GOENV_ROOT/versions/1.26.2/bin:$PATH"
export GOTOOLCHAIN=local
export GO_BUILD_DEFINITIONS="$GOENV_ROOT/plugins/go-build/share/go-build"

# [[Starship prompt]] — cache init script, invalidate when the binary changes
if command -v starship &>/dev/null; then
    _starship_bin="$(command -v starship)"
    _starship_cache="$HOME/.cache/starship_init.bash"
    if [[ ! -f "$_starship_cache" || "$_starship_bin" -nt "$_starship_cache" ]]; then
        mkdir -p "$HOME/.cache"
        starship init bash --print-full-init > "$_starship_cache"
    fi
    source "$_starship_cache"
    unset _starship_bin _starship_cache
fi
[ -n "$TMUX" ] && PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND; }~/.tmux/plugins/tmux-continuum/scripts/continuum_save.sh"

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
    dir="${dir%/*}"
    [[ -z "$dir" ]] && dir="/"
  done
  for ((i=${#dirs[@]}-1; i>=0; i--)); do
    [[ -f "${dirs[i]}/.bashrc.local" ]] && source "${dirs[i]}/.bashrc.local"
  done
}
_source_bashrc_local


# [[Zoxide]] — must be last to hook cd properly; cache init script like starship above
if command -v zoxide &>/dev/null; then
    _zoxide_bin="$(command -v zoxide)"
    _zoxide_cache="$HOME/.cache/zoxide_init.bash"
    if [[ ! -f "$_zoxide_cache" || "$_zoxide_bin" -nt "$_zoxide_cache" ]]; then
        mkdir -p "$HOME/.cache"
        zoxide init bash > "$_zoxide_cache"
    fi
    source "$_zoxide_cache"
    unset _zoxide_bin _zoxide_cache
fi
