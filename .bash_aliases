# [[Config]]
alias aliases="nvim ~/.bash_aliases"
alias bashup="source ~/.bashrc"
alias bashrc="nvim ~/.bashrc"

# [[Utils]]
command -v rip &>/dev/null && alias r="rip"
alias n="nvim"
alias cl="clear"
if command -v bat &>/dev/null; then alias cat="bat"; elif command -v batcat &>/dev/null; then alias bat="batcat" cat="batcat"; fi
command -v zoxide &>/dev/null && alias cd='z'
command -v zoxide &>/dev/null && alias zz='zi'
command -v csvlens &>/dev/null && alias csv='csvlens'

# [[Directories]]
alias cd.="cd .."
alias cd-="cd -"
alias cd~="cd ~"
command -v eza &>/dev/null && alias ls="eza"
alias grep="grep --color=auto"
alias l="yy"

# [[Git]]
alias lg="lazygit"

# [[Agents]]
alias c='claude'
alias ch='claude --model claude-haiku-5-5'
alias cs='claude --model claude-sonnet-5-5'
alias co='claude --model claude-opus-5-5'
alias cur='agent'
alias kimi='kimicoder'
