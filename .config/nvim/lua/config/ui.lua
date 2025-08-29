-- [[ UI Configuration ]]

-- [[ Configure Wilder ]]
local wilder = require('wilder')
wilder.setup({ modes = { ':', '/', '?' } })

wilder.set_option('pipeline', {
  wilder.branch(
    wilder.cmdline_pipeline(),
    wilder.search_pipeline()
  ),
})

wilder.set_option('renderer', wilder.wildmenu_renderer({
  highlighter = wilder.basic_highlighter(),
}))

-- [[ Custom colors \ themes ]]
local WKGroups = { 'WhichKey', 'WhichKeyTitle', 'WhichKeyNormal', 'WhichKeyDesc', 'WhichKeyGroup', 'WhichKeyBorder' }
for _, group in ipairs(WKGroups) do
  -- FG: Onedark, BG: transparent
  vim.api.nvim_set_hl(0, group, { fg = "#abb2bf", bg = "NONE" })
end