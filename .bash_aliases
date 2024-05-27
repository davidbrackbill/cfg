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

#   Directories
alias d="cd ~"
alias d.="cd .."
alias d-="cd -"
alias d~="cd ~"
alias cd.="cd .."
alias cd-="cd -"
alias cd~="cd ~"

# Tmux
alias tl="tmux ls"
alias ta="tmux a -t"

#   Git
alias gitc="git commit -am"
alias lg="lazygit"

# Config-tracking
alias cfg="/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME"

#   Programs
alias pyc="sh /opt/pycharm-2023.2/bin/pycharm.sh"
alias chr="google-chrome"
alias idea="sh /opt/idea-IU-232.8660.185/bin/idea.sh"
alias idea_="sh /opt/idea-IU-232.8660.185/bin/idea.sh >/dev/null 2>&1"
alias neo4j="/home/david/Programs/neo4j-desktop-1.5.8-x86_64.AppImage"

#   NPM
alias npmdev="npm run dev -- --open" 
alias prt="npx prettier --write ."

#   Python
alias py="python3.10"
alias py1="python3.11"
alias create_venv="python3.10 -m venv venv"
alias venv=". /home/david/venv/venv__3_10/bin/activate"
alias venv_local="source ./venv/bin/activate"
alias pipf="pip list --format=freeze > requirements.txt"
alias pyt="py -m pytest"

# Reliant on `# User functions` in `~/.bashrc`
alias l="yy"
