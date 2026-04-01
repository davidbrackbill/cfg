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
    -- Caps Lock (→ F18 via Karabiner) — single tap cycles windows, double-tap switches screen
    hs.hotkey.bind({}, 'f18', makeDoubleTapHandler(
      require('windows').cycleWindows,
      require('windows').switchScreen,
      0.2
    ))

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
end

return M
