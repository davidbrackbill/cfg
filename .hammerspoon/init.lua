-- ~/.hammerspoon/init.lua

require('hs.ipc')
hs.window.animationDuration = 0

local windows = require('windows')
local network = require('network')

-- Caps Lock (→ F18 via Karabiner)
hs.hotkey.bind({},        'f18', windows.cycle)
hs.hotkey.bind({ 'cmd' }, 'f18', windows.applyLayout)

-- Auto-layout on display connect/disconnect
windows.startWatcher()

-- AWS VPN on network reachability
network.startWatcher()
