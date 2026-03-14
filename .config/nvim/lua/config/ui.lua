-- [[ UI Configuration ]]

vim.api.nvim_create_autocmd('ColorScheme', {
  pattern = '*',
  callback = function()
    vim.api.nvim_set_hl(0, 'Comment',            { fg = '#8a8a8a', italic = true })
    vim.api.nvim_set_hl(0, '@comment',            { fg = '#8a8a8a', italic = true })
    vim.api.nvim_set_hl(0, '@lsp.type.comment',   { fg = '#8a8a8a', italic = true })
    vim.api.nvim_set_hl(0, '@variable.parameter', { fg = '#c0c0c0' })
  end,
})


if vim.g.neovide then
  vim.g.neovide_cursor_animation_length = 0
  vim.g.neovide_scroll_animation_length = 0
  vim.g.neovide_position_animation_length = 0
end
