# [[Config]]
alias aliases="nvim ~/.bash_aliases"
alias bashup="source ~/.bashrc"
alias bashrc="nvim ~/.bashrc" 
alias terminalcfg="nvim /mnt/c/Users/dmbra/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json"

# [[Shell]]
alias shwap="fish"

# [[Utils]]
alias r="rip"
alias n="nvim"
alias cl="clear"
alias bat="batcat"
alias cat="batcat"
alias fdf="fdfind"

# [[Directories]]
alias cd.="cd .."
alias cd-="cd -"
alias cd~="cd ~"
alias la='ls -A'

# [[Git]]
# Creates a git directory over the entire $HOME, while hiding the directory
# elsewhere, allowing a hidden `cfg` alias to access the shadow work tree
alias cfg="/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME"
alias lg="lazygit"

# [[Language runtimes]]
alias prt="npx prettier --write ."
alias py10="python3.10"
alias py11="python3.11"
alias pipf="pip list --format=freeze > requirements.txt"

# [[~/.bashrc function aliases]]
alias l="yy"

# [[Conditionals]]
if [ RC_DIRCOLORS ]; then
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
fi
