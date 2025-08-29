-- [[ Keymaps ]]
-- See `:help vim.keymap.set()`

-- Ignores
vim.api.nvim_del_keymap("", "gx") -- long which-key description
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Commands
vim.keymap.set("", ";", ":")
vim.keymap.set('c', '<c-k>', '<up>')
vim.keymap.set('c', '<c-j>', '<down>')
vim.keymap.set('n', 'QQ', ':q! <cr>', { desc = 'Quit, no save' })
vim.keymap.set('n', 'qq', ':q <cr>', { desc = 'Quit' })

local function clip()
  vim.opt.clipboard = 'unnamedplus'
  vim.cmd('normal! "+y')
end
vim.keymap.set('v', '<c-c>', clip, { desc = 'Clip to system' })
vim.keymap.set('v', 'Y', clip, { desc = 'Clip to system' })

vim.keymap.set('n', '||', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', '\\\\', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })

-- Leaders
vim.keymap.set('n', '<leader>p', '"0p', { desc = 'Paste yank' })
vim.keymap.set('n', '<leader>l', ':b#<cr>', { desc = 'Last buffer' })
vim.keymap.set('n', '<leader>f', ':Format <cr>', { desc = 'Format' })
vim.keymap.set('n', '<leader>s', ':%s/', { desc = 'Sub text' })
vim.keymap.set('n', '<leader>;', ':tabnew | r ! ', { desc = 'Tab!' })
vim.keymap.set('n', '<leader><Tab>', ':tabNext <cr>', { desc = 'Next tab' })

