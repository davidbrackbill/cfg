-- ~/.hammerspoon/keys.lua
-- Key remaps (Karabiner sends F18/F19 for modified keys)

local M = {}
function M.bind()
  -- Shift+Caps Lock (via Karabiner → F20) — cycle windows backward
  hs.hotkey.bind({}, 'f20', require('windows').cycleWindowsReverse)

  -- Alt+Caps Lock (via Karabiner → F16) — switch screen
  hs.hotkey.bind({}, 'f16', require('windows').switchScreen)
end

return M
