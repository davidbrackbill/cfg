-- ~/.hammerspoon/network.lua
-- Network-triggered automations.

local M = {}

local VPN_BUNDLE  = 'com.amazonaws.acvc.osx'
local VPN_PROFILE = 'aws vpn march 2026'
-- VPN tunnel assigns IPs in 172.16.x.x (seen on utun4 when connected)
local VPN_IP_PREFIX = '172.16.'

-- True if any utun interface has a 172.16.x.x address (= VPN tunnel is up)
local function isVpnConnected()
  for _, iface in ipairs(hs.network.interfaces()) do
    if iface:match('^utun') then
      local d = hs.network.interfaceDetails(iface)
      for _, addr in ipairs((d.IPv4 or {}).Addresses or {}) do
        if addr:sub(1, #VPN_IP_PREFIX) == VPN_IP_PREFIX then
          return true
        end
      end
    end
  end
  return false
end

-- True if el or any descendant contains the given text in title/value/description
local function subtreeContainsText(el, text)
  local attrs = { 'AXTitle', 'AXValue', 'AXDescription' }
  for _, attr in ipairs(attrs) do
    local v = el:attributeValue(attr) or ''
    if v:find(text, 1, true) then return true end
  end
  for _, child in ipairs(el:attributeValue('AXChildren') or {}) do
    if subtreeContainsText(child, text) then return true end
  end
  return false
end

-- Find the Connect button inside the row/cell that also contains profileName.
-- This prevents clicking the Connect button for a different profile row.
local function findProfileConnectButton(el, profileName)
  if not el then return nil end
  local children = el:attributeValue('AXChildren') or {}

  -- Collect any direct-child Connect buttons in this container
  local connectBtn
  for _, child in ipairs(children) do
    local role  = child:attributeValue('AXRole')  or ''
    local title = child:attributeValue('AXTitle') or ''
    if role == 'AXButton' and title:lower():find('connect', 1, true) then
      connectBtn = child
      break
    end
  end

  -- If this container has a Connect button AND contains the profile name, we found it
  if connectBtn and subtreeContainsText(el, profileName) then
    return connectBtn
  end

  -- Otherwise recurse
  for _, child in ipairs(children) do
    local found = findProfileConnectButton(child, profileName)
    if found then return found end
  end
  return nil
end

local connectDebounce

local function triggerConnect()
  -- Debounce: ignore rapid repeated calls (e.g. during OpenVPN SIGUSR1 reconnect)
  if connectDebounce then connectDebounce:stop() end
  connectDebounce = hs.timer.doAfter(3, function()
    if isVpnConnected() then return end  -- already up by now

    local app = hs.application.find(VPN_BUNDLE)
    if not app then return end

    app:activate()
    hs.timer.doAfter(0.5, function()
      local win = app:mainWindow()
      if not win then return end

      local ax  = hs.axuielement.windowElement(win)
      local btn = findProfileConnectButton(ax, VPN_PROFILE)
      if btn then
        btn:performAction('AXPress')
        -- Okta browser window will open automatically
      else
        hs.notify.new({
          title           = 'VPN: action needed',
          informativeText = 'Could not find Connect button — please connect to "' .. VPN_PROFILE .. '" manually.',
        }):send()
      end
    end)
  end)
end

local function ensureVPN()
  if not hs.application.find(VPN_BUNDLE) then
    hs.application.open(VPN_BUNDLE)
    hs.timer.doAfter(4, function()
      local app = hs.application.find(VPN_BUNDLE)
      if app then
        local win = app:mainWindow()
        if win then win:close() end
      end
      if not isVpnConnected() then triggerConnect() end
    end)
    return
  end

  if not isVpnConnected() then triggerConnect() end
end

function M.startWatcher()
  -- Watch for network interface changes (catches VPN connect/disconnect)
  local ifWatcher = hs.network.configuration.open()
  ifWatcher:setCallback(function() hs.timer.doAfter(2, ensureVPN) end)
  ifWatcher:monitorKeys({'State:/Network/Interface'}, false)
  ifWatcher:start()

  -- Wake from sleep
  hs.caffeinate.watcher.new(function(event)
    local w = hs.caffeinate.watcher
    if event == w.systemDidWake or event == w.screensDidWake then
      hs.timer.doAfter(5, ensureVPN)
    end
  end):start()

  -- Internet reachability
  local r = hs.network.reachability.internet()
  r:setCallback(function(_, flags)
    if (flags & hs.network.reachability.flags.reachable) > 0 then ensureVPN() end
  end)
  r:start()

  -- Run immediately at startup
  local flags = r:status()
  if (flags & hs.network.reachability.flags.reachable) > 0 then ensureVPN() end

  return r
end

return M
