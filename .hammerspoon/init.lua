-- ~/.hammerspoon/init.lua

require('hs.ipc')
hs.window.animationDuration = 0

local windows = require('windows')
local network = require('network')

-- Caps Lock (→ F18 via Karabiner) — go to last used window
hs.hotkey.bind({}, 'f18', windows.focusPrev)
-- Cmd+Caps Lock (→ Cmd+F18 via Karabiner) — hot app toggle
hs.hotkey.bind({ 'cmd' }, 'f18', windows.toggleHot)

-- Cmd+H (via Karabiner → F19) — focus Ghostty and send Alt+H
hs.hotkey.bind({}, 'f19', function()
  local app = hs.application.get('Ghostty') or hs.application.open('Ghostty')
  if app then
    app:activate()
    hs.timer.doAfter(0.05, function()
      hs.eventtap.keyStroke({ 'alt' }, 'h')
    end)
  end
end)

-- Auto-layout on display connect/disconnect
windows.startWatcher()

-- AWS VPN on network reachability
network.startWatcher()
