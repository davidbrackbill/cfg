-- ~/.hammerspoon/init.lua
-- Only handles custom n/5ths layouts not available in Raycast.
-- Standard layouts (halves, thirds, fullscreen) handled by Raycast.

require('hs.ipc')  -- enables hs CLI: hs -c "fn()"
hs.window.animationDuration = 0

local function setFrame(win, x, y, w, h)
  local s = win:screen():frame()
  win:setFrame({ x = s.x + s.w * x, y = s.y + s.h * y, w = s.w * w, h = s.h * h })
end

-- Global functions callable via: hs -c "windowXxx()"
-- Layout: left=3/8, middle=3/8, right=1/4
function windowLeft()   setFrame(hs.window.focusedWindow(), 0,   0, 3/8, 1) end
function windowMiddle() setFrame(hs.window.focusedWindow(), 3/8, 0, 3/8, 1) end
function windowRight()  setFrame(hs.window.focusedWindow(), 6/8, 0, 2/8, 1) end
