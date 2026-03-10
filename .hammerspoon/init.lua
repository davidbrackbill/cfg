-- ~/.hammerspoon/init.lua

require('hs.ipc')
hs.window.animationDuration = 0

local windows = require('windows')

-- Caps Lock (→ F18 via Karabiner)
hs.hotkey.bind({},        'f18', windows.cycle)
hs.hotkey.bind({ 'cmd' }, 'f18', windows.applyLayout)
