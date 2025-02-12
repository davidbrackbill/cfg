# [[Config]]
alias aliases="nvim ~/.bash_aliases"
alias bashup="source ~/.bashrc"
alias bashrc="nvim ~/.bashrc" 
alias wsl_json="nvim /mnt/c/Users/dmbra/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json"

# [[Shell]]
alias shwap="fish"

# [[Utils]]
alias r="rip"
alias n="nvim"
alias cl="clear"
alias bat="batcat"
alias cat="batcat"
alias b="batcat"
alias fdf="fdfind"
alias mk="mkdir"

# [[Directories]]
alias d.="cd .."
alias d-="cd -"
alias d~="cd ~"
alias cd.="cd .."
alias cd-="cd -"
alias cd~="cd ~"

# [[Git]]
# Creates a git directory over the entire $HOME, while hiding the directory
# elsewhere, allowing a hidden `cfg` alias to access the shadow work tree
alias cfg="/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME"
alias gitc="git commit -am"
alias gitst="git status"
alias gitl="git log"
alias cfgc="cfg commit -am"
alias cfgst="cfg status"
alias cfgl="cfg log"
alias lg="lazygit"

# [[GUIs]]
alias pyc="sh /opt/pycharm-2023.2/bin/pycharm.sh"
alias clion="sh /opt/clion-2024.2/bin/clion.sh"
alias chr="google-chrome"
alias idea="sh /opt/idea-IU-232.8660.185/bin/idea.sh"
alias neo4j="/home/david/Programs/neo4j-desktop-1.5.8-x86_64.AppImage"

# [[Language runtimes]]
alias dev="run dev -- --open" 
alias prt="npx prettier --write ."
alias py10="python3.10"
alias py11="python3.11"
alias pipf="pip list --format=freeze > requirements.txt"

# [[~/.bashrc function aliases]]
alias l="yy"
alias ntd="nvim todo"
