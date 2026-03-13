-- ~/.hammerspoon/keys.lua
-- Key remaps (Karabiner sends F18/F19 for modified keys)

local M = {}

function M.bind()
    -- Caps Lock (→ F18 via Karabiner) — go to last used window
    hs.hotkey.bind({}, 'f18', require('windows').focusPrev)
    -- Cmd+Caps Lock (→ Cmd+F18 via Karabiner) — hot app toggle
    hs.hotkey.bind({ 'cmd' }, 'f18', require('windows').toggleHot)

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
