-- ~/.hammerspoon/network.lua
-- Network-triggered automations.

local M = {}

-- Launch AWS VPN Client on network reachability and close its window once open.
local VPN_BUNDLE = 'com.amazonaws.acvc.osx'

local function ensureVPN()
  if hs.application.find(VPN_BUNDLE) then return end  -- already running
  hs.application.open(VPN_BUNDLE)
  hs.timer.doAfter(4, function()
    local app = hs.application.find(VPN_BUNDLE)
    if app then
      local win = app:mainWindow()
      if win then win:close() end
    end
  end)
end

function M.startWatcher()
  local r = hs.network.reachability.internet()
  r:setCallback(function(_, flags)
    local reachable = (flags & hs.network.reachability.flags.reachable) > 0
    if reachable then ensureVPN() end
  end)
  r:start()

  -- Also run immediately in case we're already online at startup.
  local flags = r:status()
  if (flags & hs.network.reachability.flags.reachable) > 0 then ensureVPN() end

  return r
end

return M
