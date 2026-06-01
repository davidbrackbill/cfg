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
local function findProfileConnectButton(el, profileName, depth)
  if not el then return nil end
  depth = depth or 0
  if depth > 20 then return nil end  -- Prevent infinite recursion from circular refs

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
    local found = findProfileConnectButton(child, profileName, depth + 1)
    if found then return found end
  end
  return nil
end

-- Core click logic (no debounce) - used by both launch and reconnect paths
local function clickConnectButton(retryCount)
  retryCount = retryCount or 0
  if isVpnConnected() then return end

  local app = hs.application.find(VPN_BUNDLE)
  if not app then return end

  app:activate()
  hs.timer.doAfter(1, function()
    local win = app:mainWindow()
    if not win then
      -- Window won't appear - quit and relaunch to force a window
      print(">>> No window, relaunching app")
      app:kill()
      hs.timer.doAfter(2, function()
        hs.application.open(VPN_BUNDLE)
        hs.timer.doAfter(10, function() clickConnectButton(0) end)
      end)
      return
    end

    local ax  = hs.axuielement.windowElement(win)
    local btn = findProfileConnectButton(ax, VPN_PROFILE)
    if btn then
      print(">>> Clicking Connect button")
      btn:performAction('AXPress')

      -- Wait 15s, then close window
      hs.timer.doAfter(15, function()
        print(">>> Closing window")
        local app = hs.application.find(VPN_BUNDLE)
        if app then
          local win = app:mainWindow()
          if win then win:close() end
        end
      end)
    else
      if retryCount < 5 then
        print(">>> Button not found, retrying in 2s (attempt " .. (retryCount + 1) .. ")")
        hs.timer.doAfter(2, function() clickConnectButton(retryCount + 1) end)
      else
        hs.notify.new({
          title           = 'VPN: action needed',
          informativeText = 'Could not find Connect button — please connect to "' .. VPN_PROFILE .. '" manually.',
        }):send()
      end
    end
  end)
end

local ensureVpnDebounce
local sleepWatcher
local ifWatcher

local function ensureVPN()
  -- Already connected? Nothing to do
  if isVpnConnected() then return end

  -- Debounce: stop previous attempt if ensureVPN called rapidly
  if ensureVpnDebounce then ensureVpnDebounce:stop() end

  local app = hs.application.find(VPN_BUNDLE)
  local appWasRunning = app ~= nil

  -- Launch if not running
  if not app then
    print(">>> Launching VPN app")
    hs.application.open(VPN_BUNDLE)
  end

  -- Schedule connect attempt (longer delay if we just launched)
  local delay = appWasRunning and 3 or 10
  print(">>> Will attempt connect in " .. delay .. "s (app was " .. (appWasRunning and "running" or "launched") .. ")")

  ensureVpnDebounce = hs.timer.doAfter(delay, function()
    if isVpnConnected() then return end

    local app = hs.application.find(VPN_BUNDLE)
    if not app then return end

    -- Activate app and let clickConnectButton handle window detection with retries
    app:activate()
    hs.timer.doAfter(1, function()
      clickConnectButton()
    end)
  end)
end

function M.startWatcher()
  -- Watch for network interface changes (catches VPN connect/disconnect)
  ifWatcher = hs.network.configuration.open()
  ifWatcher:setCallback(function() hs.timer.doAfter(2, ensureVPN) end)
  ifWatcher:monitorKeys({'State:/Network/Interface'}, false)
  ifWatcher:start()

  -- Wake from sleep (must store reference to prevent GC)
  sleepWatcher = hs.caffeinate.watcher.new(function(event)
    local w = hs.caffeinate.watcher
    if event == w.systemDidWake or event == w.screensDidWake then
      hs.timer.doAfter(5, ensureVPN)
    end
  end)
  sleepWatcher:start()

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
