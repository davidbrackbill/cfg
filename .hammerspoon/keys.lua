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

-- Key tapped alone quickly (pressed & released within `threshold`, with no
-- other key/modifier touched meanwhile) → jump to the last-focused window.
-- Mirrors Karabiner's left-shift-alone-to-escape pattern (100ms), but done
-- in Hammerspoon since Karabiner can't gate this on "no other key touched".
local function bindTapToLastWindow(keyName, threshold)
  threshold = threshold or 0.1
  local downAt = nil
  local usedWithOther = false

  local tap = hs.eventtap.new(
    { hs.eventtap.event.types.keyDown, hs.eventtap.event.types.keyUp, hs.eventtap.event.types.flagsChanged },
    function(e)
      local etype = e:getType()
      local isTargetKey = hs.keycodes.map[keyName] == e:getKeyCode()

      if etype == hs.eventtap.event.types.flagsChanged then
        local flags = e:getFlags()
        if downAt and (flags.cmd or flags.alt or flags.shift or flags.ctrl or flags.fn) then
          usedWithOther = true
        end
        return false
      end

      if not isTargetKey then
        if downAt then usedWithOther = true end
        return false
      end

      if etype == hs.eventtap.event.types.keyDown then
        if not downAt then
          downAt = hs.timer.secondsSinceEpoch()
          usedWithOther = false
        end
      elseif etype == hs.eventtap.event.types.keyUp then
        if downAt then
          local heldFor = hs.timer.secondsSinceEpoch() - downAt
          if not usedWithOther and heldFor < threshold then
            require('windows').focusPrev()
          end
        end
        downAt = nil
        usedWithOther = false
      end

      return false
    end
  )
  tap:start()
  return tap
end

function M.bind()
    -- Caps Lock (→ F18 via Karabiner), tapped alone within 100ms →
    -- jump back to the last-focused window
    M.capsLockTapWatcher = bindTapToLastWindow('f18', 0.15)

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
