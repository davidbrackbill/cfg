-- [[ UI Configuration ]]

-- [[ Custom colors \ themes ]]
local WKGroups = { 'WhichKey', 'WhichKeyTitle', 'WhichKeyNormal', 'WhichKeyDesc', 'WhichKeyGroup', 'WhichKeyBorder' }
for _, group in ipairs(WKGroups) do
  -- FG: Onedark, BG: transparent
  vim.api.nvim_set_hl(0, group, { fg = "#abb2bf", bg = "NONE" })
end

if vim.g.neovide then
  vim.g.neovide_cursor_animation_length = 0
  vim.g.neovide_scroll_animation_length = 0
  vim.g.neovide_position_animation_length = 0
end
