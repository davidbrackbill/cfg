-- ~/.hammerspoon/keys.lua
-- Key remaps (Karabiner sends F18/F19 for modified keys)

local M = {}

-- Generic double-tap detector
local function makeDoubleTapHandler(singleFn, doubleFn, threshold)
  threshold = threshold or 0.2
  local tapCount = 0
  local timer = nil

  return function()
    tapCount = tapCount + 1
    if timer then timer:stop() end

    if tapCount == 1 then
      timer = hs.timer.doAfter(threshold, function()
        singleFn()
        tapCount = 0
        timer = nil
      end)
    elseif tapCount == 2 then
      doubleFn()
      tapCount = 0
      timer = nil
    end
  end
end

function M.bind()
    -- Caps Lock (→ F18 via Karabiner) — toggle between last two windows on current screen
    hs.hotkey.bind({}, 'f18', require('windows').toggleLastWindow)

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

    -- Shift+Caps Lock (via Karabiner → F20) — cycle windows backward
    hs.hotkey.bind({}, 'f20', require('windows').cycleWindowsReverse)

    -- Alt+Caps Lock (via Karabiner → F16) — switch screen
    hs.hotkey.bind({}, 'f16', require('windows').switchScreen)
end

return M
