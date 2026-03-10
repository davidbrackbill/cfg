-- ~/.hammerspoon/windows.lua
-- Window cycling (Caps Lock / F18) and display-aware layout (Cmd+Caps Lock).

local M = {}

-- ── config ────────────────────────────────────────────────────────────────────

-- Cycle order: these apps come first (by priority), then remaining windows by MRU.
local PRIORITY_BUNDLES = {
  'com.mitchellh.ghostty',
  'com.vivaldi.Vivaldi',
  'md.obsidian',
  'com.tinyspeck.slackmacgap',
}

-- ── helpers ───────────────────────────────────────────────────────────────────

local function setFrame(win, screen, x, y, w, h)
  local s = screen:frame()
  win:setFrame({ x = s.x + s.w * x, y = s.y + s.h * y, w = s.w * w, h = s.h * h })
end

local function mainWin(bundleId)
  local app = hs.application.find(bundleId)
  return app and app:mainWindow()
end

-- ── window cycling ────────────────────────────────────────────────────────────

local wf = hs.window.filter.new():setDefaultFilter({ visible = true, currentSpace = true })

local function buildCycleList()
  local allWins   = wf:getWindows(hs.window.filter.sortByFocusedLast)
  local priorityWins, priorityIds = {}, {}

  for _, bundleId in ipairs(PRIORITY_BUNDLES) do
    local win = mainWin(bundleId)
    if win then
      table.insert(priorityWins, win)
      priorityIds[win:id()] = true
    end
  end

  local result = priorityWins
  for _, win in ipairs(allWins) do
    if not priorityIds[win:id()] then
      table.insert(result, win)
    end
  end
  return result
end

function M.toggleHot()
  local hot = {
    { id = 'com.mitchellh.ghostty',   win = mainWin('com.mitchellh.ghostty') },
    { id = 'com.vivaldi.Vivaldi',     win = mainWin('com.vivaldi.Vivaldi') },
    { id = 'md.obsidian',             win = mainWin('md.obsidian') },
  }
  local focusedId = (hs.window.focusedWindow() and
                     hs.window.focusedWindow():application():bundleID()) or ''
  local currentIdx = 0
  for i, entry in ipairs(hot) do
    if entry.id == focusedId then currentIdx = i; break end
  end
  -- advance to next entry that has a window open
  for offset = 1, #hot do
    local next = hot[(currentIdx + offset - 1) % #hot + 1]
    if next.win then next.win:focus(); return end
  end
end

function M.cycle()
  local focused   = hs.window.focusedWindow()
  local focusedId = focused and focused:id()
  local list      = buildCycleList()
  if #list < 2 then return end

  local currentIdx = 0
  for i, win in ipairs(list) do
    if win:id() == focusedId then currentIdx = i; break end
  end

  list[(currentIdx % #list) + 1]:focus()
end


-- ── display-aware layout ──────────────────────────────────────────────────────

function M.applyLayout()
  local screen  = hs.screen.mainScreen()
  local f       = screen:frame()
  local ratio   = f.w / f.h

  local ghostty  = mainWin('com.mitchellh.ghostty')
  local vivaldi  = mainWin('com.vivaldi.Vivaldi')
  local obsidian = mainWin('md.obsidian')
  local slack    = mainWin('com.tinyspeck.slackmacgap')

  if f.w == 1352 then
    -- Built-in Retina (1352×878): maximize all
    for _, win in ipairs({ ghostty, vivaldi, obsidian, slack }) do
      if win then win:maximize() end
    end

  elseif ratio > 2.0 then
    -- Ultrawide: ghostty middle 1/3 full height,
    --            vivaldi right 1/3 top 2/3, obsidian right 1/3 bottom 1/3,
    --            slack maximized
    if ghostty  then setFrame(ghostty,  screen, 1/3, 0,   1/3, 1  ) end
    if vivaldi  then setFrame(vivaldi,  screen, 2/3, 0,   1/3, 2/3) end
    if obsidian then setFrame(obsidian, screen, 2/3, 2/3, 1/3, 1/3) end
    if slack    then slack:maximize() end

  else
    -- Dell 4K: ghostty left 3/8, vivaldi middle 3/8, obsidian right 1/4,
    --          slack maximized
    if ghostty  then setFrame(ghostty,  screen, 0,   0, 3/8, 1) end
    if vivaldi  then setFrame(vivaldi,  screen, 3/8, 0, 3/8, 1) end
    if obsidian then setFrame(obsidian, screen, 6/8, 0, 2/8, 1) end
    if slack    then slack:maximize() end
  end
end

-- ── CLI helpers (hs -c "windowXxx()") ────────────────────────────────────────
-- Operate on focused window's own screen. Layout: left=3/8, middle=3/8, right=1/4

local function setFrameFocused(x, y, w, h)
  local win = hs.window.focusedWindow()
  if win then setFrame(win, win:screen(), x, y, w, h) end
end

function windowLeft()   setFrameFocused(0,   0, 3/8, 1) end
function windowMiddle() setFrameFocused(3/8, 0, 3/8, 1) end
function windowRight()  setFrameFocused(6/8, 0, 2/8, 1) end

-- ── screen watcher ───────────────────────────────────────────────────────────
-- Re-applies layout automatically when displays are connected/disconnected.

function M.startWatcher()
  local sw = hs.screen.watcher.new(function()
    hs.timer.doAfter(1.5, M.applyLayout)  -- delay for screens to settle
  end)
  sw:start()
  return sw
end

return M
