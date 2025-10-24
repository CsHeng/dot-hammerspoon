-- Simplified init.lua for Hammerspoon
-- Working version with modular architecture

-- Essential hotkeys (always available)
hs.hotkey.bind({"ctrl", "cmd", "alt"}, "R", "Hammerspoon Reloading...", function()
    hs.reload()
end)

hs.hotkey.bind({"ctrl", "cmd", "alt"}, "H", "Hammerspoon Console", function()
    hs.openConsole()
end)

-- Load new modular system
local function loadModularSystem()
    local modules_loaded = 0

    -- Load core utilities
    local utility_modules = {
        "utils/app_utils",
        "utils/display_utils",
        "utils/notification_utils",
        "utils/window_utils"
    }

    for _, module_name in ipairs(utility_modules) do
        local success, module = pcall(require, module_name)
        if success then
            modules_loaded = modules_loaded + 1
        else
            print("Warning: Failed to load " .. module_name)
        end
    end

    -- Load feature modules (excluding expose for lazy loading)
    local feature_modules = {
        "modules/window_management",
        "modules/app_launcher",
        "modules/media_controls",
        "modules/mouse_management",
        "modules/wifi_automation",
        "modules/keystroke_visualizer"
    }

    for _, module_name in ipairs(feature_modules) do
        local success, module = pcall(require, module_name)
        if success then
            modules_loaded = modules_loaded + 1
        else
            print("Warning: Failed to load " .. module_name)
        end
    end

    -- Initialize all modules and their hotkeys
    local init_system = require("core.init_system")
    local init_success = init_system.loadAllModules()
    if init_success then
        print("All modules initialized successfully")
    else
        print("Warning: Some modules failed to initialize")
    end

    return modules_loaded
end

-- Load the modular system
local modules_loaded_count = loadModularSystem()
print("Hammerspoon loaded " .. modules_loaded_count .. " modules")

-- Success notification
hs.alert.show("Hammerspoon loaded")

-- Lazy load window_expose module to avoid slow startup
local expose_loaded = false
local function loadExpose()
    if not expose_loaded then
        local success, expose_module = pcall(require, "modules.window_expose")
        if success then
            expose_loaded = true
            print("Window expose module loaded")
        else
            print("Failed to load window expose module: " .. tostring(expose_module))
        end
    end
end

-- Create a temporary hotkey that will load expose on first use
hs.hotkey.bind({"ctrl", "cmd"}, "tab", "Expose (Loading...)", function()
    loadExpose()
    -- The actual expose hotkey is now loaded, so we can trigger it
    hs.timer.doAfter(0.1, function()
        hs.eventtap.keyStroke({"ctrl", "cmd"}, "tab")
    end)
end)

-- Debug function
hs.debugHammerspoon = {
    reload = function() hs.reload() end,
    console = function() hs.openConsole() end,
    status = function()
        print("=== Hammerspoon Status ===")
        print("Configuration: Modular")
        print("Modules loaded: " .. modules_loaded_count)
        print("Use Ctrl+Cmd+Alt+H for console")
        print("============================")
    end
}

print("Hammerspoon configuration loaded")
print("Use hs.debugHammerspoon.status() for debug info")
print("Press Ctrl+Cmd+Alt+H for console")