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

local ok, flagpls = pcall(require, 'flagpls')
if ok then flagpls.setup() end
