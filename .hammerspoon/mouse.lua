-- ~/.hammerspoon/mouse.lua
-- Per-device mouse sensitivity via hidutil
-- Values are HIDMouseAcceleration: multiply desired acceleration by 65536
-- e.g. 1.0 = 65536, 2.0 = 131072, 0.5 = 32768, 0 = no acceleration

local M = {}

local DEFAULT = 196608  -- 3.0 — default for unrecognized mice

local profiles = {
    ["045e:0039"] = 131072,  -- Microsoft 5-Button Mouse (2.0)
    ["046d:????"] = 0,       -- Logitech (fill in product ID; 0.0 = no acceleration)
}

local function setAcceleration(vendorID, productID, value)
    local cmd = string.format(
        "hidutil property --matching '{\"VendorID\":%d,\"ProductID\":%d}' --set '{\"HIDMouseAcceleration\":%d}'",
        vendorID, productID, value
    )
    local ok, out, _ = hs.execute(cmd)
    if not ok then
        hs.notify.show("Mouse Sensitivity", "", "hidutil failed: " .. (out or ""))
    end
end

local watcher = hs.usb.watcher.new(function(device)
    if device.eventType ~= "added" then return end
    -- Only act on mice (usagePage 1 = generic desktop, usage 2 = mouse)
    if device.usagePage ~= 1 or device.usage ~= 2 then return end
    local key = string.format("%04x:%04x", device.vendorID, device.productID)
    local value = profiles[key] or DEFAULT
    setAcceleration(device.vendorID, device.productID, value)
    hs.notify.show("Mouse", device.productName or key,
        string.format("Sensitivity → %.2f", value / 65536))
end)

function M.startWatcher()
    watcher:start()
end

return M
