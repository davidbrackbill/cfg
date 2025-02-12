# [[Options]]

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

shopt -s histappend
HISTSIZE=100000
HISTFILESIZE=1000000
# don't put duplicate lines or lines starting with space in the history.
HISTCONTROL=ignoreboth
HISTIGNORE='ls:bg:fg:history'
HISTTIMEFORMAT='%F %T '

PROMPT_DIRTRIM=1

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# Expand **
shopt -s globstar

shopt -s nullglob

shopt -s expand_aliases

shopt -s autocd

set -o vi

# Remove <alt-Num> in bash and any other readline program
bind -f ~/.inputrc

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# [[Sources]]

function safe_source {
    if [ "$#" -eq 1 ] && [ -s "$1" ]; then
	source "$1"
    fi
}

#   Reverse i search using fzf
safe_source /usr/share/doc/fzf/examples/key-bindings.bash

# enable completion if non-posix is ok
if ! shopt -oq posix; then
  safe_source /usr/share/bash-completion/bash_completion
  safe_source /etc/bash_completion 
fi

# Haskell
safe_source /home/david/.ghcup/env

# [[Exports]]

if [ -x /usr/bin/dircolors ]; then
    if [ -r ~/.dircolors ]; then
	eval "$(dircolors -b ~/.dircolors)" 
    else
	eval "$(dircolors -b)"
    fi
    export DIRCOLORS=true
fi

export EDITOR=nvim
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# Load node version manager
export NVM_DIR="$HOME/.nvm"
safe_source "$NVM_DIR/nvm.sh"
safe_source "$NVM_DIR/bash_completion"

export PNPM_HOME="/home/david/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# Load cargo
safe_source "$HOME/.cargo/env"

export GOPATH=$HOME/.go


# [[Functions.directory]]

function fr {
    # Find file (from [R]oot, by default)
    local dir="${1-"/"}"
    local args=${@:2}
    fdfind "." "$dir" --hidden --exclude "{.git, node_modules, __pycache,.npm,.cache}" |
        fzf-tmux --select-1 --query "${args-""}"
}

function f {
    # Find and open

    local path=$(fr "${HOME}" "${*}")
    
    # Open directory
    if [[ -d $path ]]; then
	cd "$path"
	return 1

    # Open file using nvim
    else
	cd "$(dirname "$path")"
	nvim "$path"
    fi
}

# CD to the dir Yazi exited from
function yy() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
	    cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}

function fl {
    # Find then [L]ist, if applicable
    f "${*}" || yy
}

function mkgo {
    [ "$1" ] && mkdir -p "$1" && cd "$1" 
}

# [[Functions.todo]]]]

#todo
function td {
    if [ "$1" ] 
        then echo $@ >> todo
    fi
    cl
    bat todo
}

#todo insert
function tdi {
    sed -i "$1i ${*:2}" todo
    cl
    bat todo
}

#todo remove
function tdr {
    # Delete first line if unspecified
    for del_line in ${@:-1}
    do
	# Mark lines before removing
	sed -i "${del_line}s/^/✓/" todo
    done
    cl
    # Print, archive, and delete marked lines
    grep "^✓" todo
    sed -n 's/^✓//p' todo | awk '{ print strftime("%Y-%m-%dT%H:%M:%SZ"), $0 }' >> .todo
    sed -i '/^✓/d' todo
    bat todo
}

#todo head
function tdh {
    cl && head -${1:-1} todo
}

#todo last
function tdl {
    cl
    # Print everything except the timestamp
    tail -n ${1:-1} .todo | tac | awk '{print substr($0, index($0, $2))}'
}

# [[Functions.python]]

function py {
    local usage="USAGE: py [minor_version=10] [command={'venv'|'test'}] [subcommand={'local'}]"
    local minor_version="${1-"10"}"
    local command="$2"
    local subcommand="$3"

    if ((minor_version < 10 || minor_version > 12)); then
	echo "ERROR: Minor version $minor_version not allowed"
	echo "$usage"

    elif [[ -z $command ]]; then
	eval "python3.$minor_version"

    elif [[ -f $command ]]; then
	eval "python3.$minor_version $command"

    elif [[ "$command" = "test" ]]; then
	eval "python3.$minor_version -m pytest $subcommand"

    elif [[ "$command" = "venv" ]]; then
	if [[ "$subcommand" = "local" ]]; then
	    # Make local venv if needed
	    if ! [[ -d "./venv__3_$minor_version" ]]; then
		echo "Making venv at ./venv__3_$minor_version"
		eval "python3.$minor_version -m venv venv__3_$minor_version"
	    fi
	    eval "source ./venv__3_$minor_version/bin/activate"
	else
	    eval ". /home/david/.global_venv/venv__3_$minor_version/bin/activate"
	fi

    else
	echo "ERROR: Command $command not allowed"
	echo "$usage"
    fi

}

function ta {
    if [ -n "${1}" ]]; then
	tmux a -t "${1}"
    else
	tmux ls
    fi
}

function ccpls {
    cc "$1.c" -o "./$1.out" && "./$1.out" "${@:2}"
}

function ccpp {
    g++ "$1.cpp" -o "./$1.out" && "./$1.out" "${@:2}"
}

# [[Aliases]]
# Should come after other sources to override any sourced aliases

safe_source ~/.bash_aliases
