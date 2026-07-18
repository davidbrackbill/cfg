-- [[ Autocommands ]]

-- Auto reload buffers changed on disk (e.g. by an external tool) instead of prompting
vim.o.autoread = true
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
  callback = function()
    if vim.bo.buftype == "" then
      pcall(vim.cmd, "checktime")
    end
  end,
  desc = "Check for external file changes",
})

-- Auto save on focus lost (only if the buffer actually has unsaved changes)
vim.api.nvim_create_autocmd({ "FocusLost", "BufLeave", "BufWinLeave", "InsertLeave" }, {
  -- nested = true, -- for format on save
  callback = function()
    if vim.bo.modified and vim.bo.filetype ~= "" and vim.bo.buftype == "" then
      pcall(vim.cmd, "silent! w")
    end
  end,
  desc = "Auto Save",
})

-- Disable hard line wrapping in git commit messages
vim.api.nvim_create_autocmd("FileType", {
  pattern = "gitcommit",
  callback = function()
    vim.opt_local.textwidth = 0
    vim.opt_local.formatoptions:remove("t")
  end,
  desc = "No hard wrap in git commits",
})

-- [[ Highlight on yank ]]
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})
