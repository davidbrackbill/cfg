-- [[ Neovim Configuration ]]
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

require('config.options')
require('config.keymaps')
require('config.autocmds')
require('config.lazy-plugins')
require('config.lsp')
require('config.fzf')
require('config.treesitter')
require('config.ui')

-- flagpls: LD flag lookup (:Flagpls / <leader>fd). Plugin symlinked into lua/flagpls.lua.
require('flagpls').setup()
