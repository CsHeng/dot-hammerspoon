hs.hotkey.bind({"ctrl", "cmd", "alt"}, "R", "Hammerspoon Reloading...", function()
    hs.reload()
end)

hs.hotkey.bind({"ctrl", "cmd", "alt"}, "H", "Hammerspoon Console", function()
    hs.openConsole()
end)

require("mouse_reverse_scroll")
require("key_bindings")
require("window")
require("wifi")
require("keycastr")

-- Load expose module
-- require("expose")

-- Lazy load expose module to avoid slow startup
local exposeLoaded = false
local function loadExpose()
    if not exposeLoaded then
        require("expose")
        exposeLoaded = true
    end
end

-- Create a temporary hotkey that will load expose on first use, will be overrided when expose module loaded.
hs.hotkey.bind({"ctrl", "cmd"}, "tab", "Expose (Loading...)", function()
    loadExpose()
    -- The actual expose hotkey is now loaded, so we can trigger it
    -- by simulating the same key combination
    hs.timer.doAfter(0.1, function()
        hs.eventtap.keyStroke({"ctrl", "cmd"}, "tab")
    end)
end)

hs.alert.show("Hammerspoon loaded")
