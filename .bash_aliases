# - SETTINGS
#  Always expand aliases
#  https://stackoverflow.com/a/19819036/19839971
shopt -s expand_aliases

#  Include hidden `.` folders in glob
#  https://stackoverflow.com/questions/14352290/listing-only-directories-using-ls-in-bash#comment62049196_14352330
shopt -s nullglob

# - ALIASES
alias aliases="nvim ~/.bash_aliases"
alias bashup=". ~/.bashrc"
alias bashrc="nvim ~/.bashrc" 

#   Shell utils
alias r="rip"
alias n="nvim"
alias cl="clear"
alias bat="batcat"
alias cat="batcat"
alias b="batcat"
alias fdf="fdfind"
alias mk="mkdir"

#   Directories
alias d.="cd .."
alias d-="cd -"
alias d~="cd ~"
alias cd.="cd .."
alias cd-="cd -"
alias cd~="cd ~"

#   Git
alias gitc="git commit -am"
alias lg="lazygit"

# Config-tracking
alias cfg="/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME"

# WSL Config
alias wsl_json="nvim /mnt/c/Users/dmbra/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json"

#   Programs
alias pyc="sh /opt/pycharm-2023.2/bin/pycharm.sh"
alias clion="sh /opt/clion-2024.2/bin/clion.sh"
alias chr="google-chrome"
alias idea="sh /opt/idea-IU-232.8660.185/bin/idea.sh"
alias neo4j="/home/david/Programs/neo4j-desktop-1.5.8-x86_64.AppImage"

#   NPM
alias dev="run dev -- --open" 
alias prt="npx prettier --write ."

#   Python
alias py10="python3.10"
alias py11="python3.11"
alias pipf="pip list --format=freeze > requirements.txt"

# Reliant on `# User functions` in `~/.bashrc`
alias l="yy"

# Semantically reliant on .bashrc functions
alias ntd="nvim todo"
