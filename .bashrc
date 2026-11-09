# Available in all shells
cfg() { git --git-dir="$HOME/.cfg" --work-tree="$HOME" "$@"; }
safe_source() { [ "$#" -eq 1 ] && [ -s "$1" ] && source "$1"; }

# [[Env]] — before the interactive guard so `termag ssh box -- cmd` gets it too
safe_source "$HOME/.zshenv"
safe_source "$HOME/.cargo/env"
safe_source "$HOME/.local/bin/env"
safe_source ~/.git.env
safe_source ~/.ld.env

case ":$PATH:" in *":$HOME/.local/bin:"*) ;; *) export PATH="$HOME/.local/bin:$PATH" ;; esac
export PATH="$HOME/bin:$HOME/db/bin:$PATH:$HOME/go/bin"

export NVM_DIR="$HOME/.nvm"
safe_source "$NVM_DIR/nvm.sh"

export GOENV_ROOT="$HOME/.goenv"
export PATH="$GOENV_ROOT/bin:$GOENV_ROOT/shims:$PATH"
export GOTOOLCHAIN=local

export PYENV_ROOT="$HOME/.pyenv"
[ -d "$PYENV_ROOT" ] && export PATH="$PYENV_ROOT/bin:$PYENV_ROOT/shims:$PATH"

export EDITOR=nvim
export VISUAL=nvim

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
safe_source /usr/share/doc/fzf/examples/key-bindings.bash
safe_source /usr/share/bash-completion/bash_completion
safe_source ~/.bash_aliases

export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

command -v fd &>/dev/null || { command -v fdfind &>/dev/null && alias fd=fdfind; }

# [[FZF]]
export FZF_DEFAULT_COMMAND='fd --hidden --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --exclude .git'

# [[Functions]]

# Fuzzy find and open: dirs→yazi, files→nvim
f() {
    local path
    path=$(fd --hidden --exclude .git | fzf --tmux 80% --select-1 --query "$*")
    [[ -z "$path" ]] && return
    if [[ -d "$path" ]]; then
        yy "$path"
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

gitfind() {
    local input=$1 url host path pattern dir repo
    local skip=(go .cache .npm .nvm .pyenv .rustup .goenv .cargo .local .oh-my-zsh)
    local roots=()

    url=${input,,}
    if [[ $input != *://* && $input != *@* && $input != *:* ]]; then
        url=github.com/$url
    fi
    url=${url#*://}
    url=${url#*@}
    url=${url/://}
    url=${url%/}
    url=${url%.git}

    host=${url%%/*}
    path=${url#*/}
    pattern="^\s*url\s*=.*${host//./\\.}[:/]${path//./\\.}(\.git)?/?\s*$"

    for dir in "$HOME"/* "$HOME"/.[!.]*; do
        [[ -d $dir ]] || continue
        [[ " ${skip[*]} " == *" ${dir##*/} "* ]] && continue
        roots+=("$dir")
    done

    fd -H -t f '^config$' "${roots[@]}" -E node_modules -X rg -l -i "$pattern" 2>/dev/null |
        while read -r config; do
            repo=${config%/config}
            echo "${repo%/.git}"
        done
}

# [[Bazel cleanup]]
bazel-orphanage() {
  local dirs=()
  for dir in "$HOME"/.cache/bazel/_bazel_"$USER"/*/; do
    local ws=$(cat "$dir/DO_NOT_BUILD_HERE" 2>/dev/null | head -1)
    if [[ -n "$ws" && ! -d "$ws" ]]; then
      echo "Orphaned: $ws"
      dirs+=("$dir")
    fi
  done
  if [[ ${#dirs[@]} -gt 0 ]]; then
    echo "Removing ${#dirs[@]} orphaned output bases..."
    chmod -R u+w "${dirs[@]}" && rm -rf "${dirs[@]}"
    echo "Done"
  else
    echo "No orphaned Bazel output bases found"
  fi
}

# Bazel CI tests need aws to be logged in
command -v aws-check &>/dev/null && alias bazel='aws-check && command bazel'

# [[Goenv]] — shell integration (PATH set above)
command -v goenv &>/dev/null && eval "$(goenv init -)"

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

# Something setting this can prevent Lazygit amend commit from opening in nvim
unset GIT_EDITOR

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

# [[termag]] — first-connect setup banner until the box is set up
if [ ! -f "$HOME/.termag-setup-complete" ] && command -v termag-setup &>/dev/null; then
  termag-setup --banner
fi

# ---- Utilities ----

# herdr move TABNAME WORKSPACE: move a tab in the current Herdr workspace to another workspace.
# Other herdr subcommands pass straight through to the real binary.
herdr() {
  if [ "${1:-}" != "move" ]; then
    command herdr "$@"
    return
  fi
  shift
  if [ "$#" -ne 2 ]; then
    echo "usage: herdr move TABNAME_IN_CURRENT_SPACE WORKSPACE_TO_MOVE_TO" >&2
    return 2
  fi
  local tab_name="$1" dest="$2" src_ws tab_ids tab_id dest_ws pane first=1 new_tab="" out
  if [ -z "${HERDR_WORKSPACE_ID:-}" ]; then
    echo "herdr move: not inside a Herdr-managed pane" >&2
    return 1
  fi
  src_ws="$HERDR_WORKSPACE_ID"

  tab_ids=$(command herdr tab list --workspace "$src_ws" \
    | jq -r --arg n "$tab_name" '.result.tabs[] | select((.label | ascii_downcase) == ($n | ascii_downcase)) | .tab_id')
  if [ -z "$tab_ids" ]; then
    echo "herdr move: no tab named '$tab_name' in this workspace" >&2
    return 1
  fi
  if [ "$(printf '%s\n' "$tab_ids" | wc -l)" -gt 1 ]; then
    echo "herdr move: more than one tab named '$tab_name' in this workspace" >&2
    return 1
  fi
  tab_id="$tab_ids"

  dest_ws=$(command herdr workspace list \
    | jq -r --arg d "$dest" '.result.workspaces[] | select(.workspace_id == $d or ((.label | ascii_downcase) == ($d | ascii_downcase))) | .workspace_id' \
    | head -n 1)
  if [ -z "$dest_ws" ]; then
    echo "herdr move: no workspace matching '$dest'" >&2
    return 1
  fi
  if [ "$dest_ws" = "$src_ws" ]; then
    echo "herdr move: '$tab_name' is already in that workspace" >&2
    return 1
  fi

  # Move the tab's panes in list order: the first creates the tab in the destination, the rest split into it.
  for pane in $(command herdr pane list --workspace "$src_ws" \
    | jq -r --arg t "$tab_id" '.result.panes[] | select(.tab_id == $t) | .pane_id'); do
    if [ "$first" -eq 1 ]; then
      out=$(command herdr pane move "$pane" --new-tab --workspace "$dest_ws" --label "$tab_name" --no-focus)
      new_tab=$(printf '%s' "$out" | jq -r '.result.move_result.created_tab.tab_id')
      first=0
    else
      command herdr pane move "$pane" --tab "$new_tab" --split right --no-focus >/dev/null
    fi
  done
  if [ "$first" -eq 1 ]; then
    echo "herdr move: tab '$tab_name' has no panes to move" >&2
    return 1
  fi
  echo "moved '$tab_name' to workspace $dest_ws (tab $new_tab)"
}
