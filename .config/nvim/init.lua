-- [[ Neovim Configuration ]]
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

require('config.options')
require('config.keymaps')
require('config.autocmds')
require('config.lazy-plugins')
require('config.lsp')
require('config.telescope')
require('config.treesitter')
require('config.ui')
