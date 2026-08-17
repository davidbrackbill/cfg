-- ~/.hammerspoon/keys.lua
-- Key remaps (Karabiner sends F18/F19 for modified keys)

local M = {}
function M.bind()
  -- Shift+Caps Lock (via Karabiner → F20) — cycle windows backward
  hs.hotkey.bind({}, 'f20', require('windows').cycleWindowsReverse)

  -- Alt+Caps Lock (via Karabiner → F16) — switch screen
  hs.hotkey.bind({}, 'f16', require('windows').switchScreen)

  -- F18 — toggle between last two focused windows
  hs.hotkey.bind({}, 'f18', require('windows').toggleLastWindow)

  -- Cmd+F18 / Cmd+Shift+F18 — cycle Ghostty → Vivaldi → Obsidian (forward/back)
  hs.hotkey.bind({'cmd'},       'f18', function() require('windows').cycleHot(1)  end)
  hs.hotkey.bind({'cmd','shift'}, 'f18', function() require('windows').cycleHot(-1) end)
end

return M
