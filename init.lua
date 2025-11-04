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

    print("Loading modules through init_system...")

    -- First, require all modules so they can register themselves
    -- This does NOT initialize them, just registers them
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
            print("Registered: " .. module_name)
        else
            print("Warning: Failed to register " .. module_name)
        end
    end

    -- Determine which mouse management module to load (allows easy swapping)
    local config_loader = require("core.config_loader")
    local mouse_module_name = config_loader.get("mouse.management_module", "modules.mouse_management")

    -- Load feature modules (excluding expose for lazy loading)
    local feature_modules = {
        "modules/window_management",
        "modules/app_launcher",
        "modules/media_controls",
        mouse_module_name,
        "modules/wifi_automation",
        "modules/keystroke_visualizer",
        "modules/notch_hider"
    }

    for _, module_name in ipairs(feature_modules) do
        local success, module = pcall(require, module_name)
        if success then
            modules_loaded = modules_loaded + 1
            print("Registered: " .. module_name)
        else
            print("Warning: Failed to register " .. module_name)
        end
    end

    -- Now initialize all modules and their hotkeys through the proper module system
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

-- Lazy load window switcher on first Alt+Tab usage
local function cloneHotkey(list)
    local result = {}
    for i, value in ipairs(list) do
        result[i] = string.lower(value)
    end
    return result
end

local function splitHotkey(hotkey)
    if type(hotkey) ~= "table" or #hotkey == 0 then
        return nil, nil
    end

    local key = hotkey[#hotkey]
    local mods = {}
    for i = 1, #hotkey - 1 do
        mods[i] = string.lower(hotkey[i])
    end

    return mods, key
end

local switcherLoaded = false
local lazyBindings = {}

local function ensureWindowSwitcher(stepDirection)
    if switcherLoaded then
        local ok, module = pcall(require, "modules.window_expose")
        if ok and module.trigger then
            module.trigger(stepDirection or 1)
            return true
        end
        return ok
    end

    local ok, module = pcall(require, "modules.window_expose")
    if not ok then
        print("Failed to load window switcher: " .. tostring(module))
        return false
    end

    if module.ensureInitialized then
        module.ensureInitialized()
    elseif module.init then
        module.init()
    end

    for _, binding in ipairs(lazyBindings) do
        binding:delete()
    end
    lazyBindings = {}
    switcherLoaded = true

    if module.trigger then
        module.trigger(stepDirection or 1)
    end

    return true
end

local config_loader = require("core.config_loader")
local exposeHotkey = config_loader.get("hotkeys.system.expose", {"alt", "tab"})
local baseMods, exposeKey = splitHotkey(exposeHotkey)

if baseMods and exposeKey then
    local function bindLazy(mods, stepDirection)
        local binding = hs.hotkey.bind(mods, exposeKey, "Window Switcher (Loading...)", function()
            ensureWindowSwitcher(stepDirection)
        end)
        table.insert(lazyBindings, binding)
    end

    bindLazy(baseMods, 1)

    local withShift = cloneHotkey(baseMods)
    table.insert(withShift, "shift")
    bindLazy(withShift, -1)
end

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
