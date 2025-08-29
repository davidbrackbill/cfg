-- [[ Vim options ]]

-- Set highlight on search
vim.o.hlsearch = false

-- Make line numbers default
vim.wo.number = true

-- Enable mouse mode
vim.o.mouse = 'a'

vim.o.breakindent = true
vim.o.undofile = true

-- Autowrite when exiting buffer
vim.o.autowriteall = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

-- Allow command-line to pop up when needed
vim.o.cmdheight = 0

-- NOTE: Leader selection must precede plugins
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Environment files
vim.g.python3_host_prog = '/usr/bin/python3'
vim.env.BASH_ENV = "~/.bash_aliases"
