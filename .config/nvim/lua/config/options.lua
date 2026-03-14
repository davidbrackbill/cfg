-- [[ Vim options ]]

-- Set highlight on search
vim.o.hlsearch = false

vim.wo.number = false

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
vim.wo.signcolumn = 'yes:1'

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

-- Allow command-line to pop up when needed
vim.o.cmdheight = 0

-- Defer clipboard setup to avoid blocking startup
vim.schedule(function()
  vim.opt.clipboard = 'unnamedplus'
end)

-- Environment files
vim.g.python3_host_prog = vim.fn.exepath('python3')
vim.env.BASH_ENV = "~/.bash_aliases"
