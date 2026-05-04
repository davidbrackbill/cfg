# Source .bashrc for non-interactive shells (e.g. Claude Code Bash tool)
[[ -f ~/.bashrc ]] && source ~/.bashrc

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
