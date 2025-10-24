-- Window Expose Module for Hammerspoon
-- Provides window expose functionality with thumbnail previews

local logger = require("core.logger")
local config = require("core.config_loader")

local log = logger.getLogger("window_expose")

local M = {}

-- Global variables
local expose = nil
local expose_loaded = false

-- Get configuration values
local function getHotkeyConfig(path)
    return config.get("hotkeys." .. path)
end

-- Initialize window expose module
function M.init()
    log.i("Initializing window expose module")

    -- Setup expose lazy loading
    M.setupLazyLoading()

    log.i("Window expose module initialized")
end

-- Setup lazy loading for expose
function M.setupLazyLoading()
    local expose_hotkey = getHotkeyConfig("system.expose") or {"ctrl", "cmd", "tab"}

    -- Create a temporary hotkey that will load expose on first use
    hs.hotkey.bind(expose_hotkey[1], expose_hotkey[2], "Expose (Loading...)", function()
        M.loadExpose()

        -- The actual expose hotkey will be loaded, so we can trigger it
        -- by simulating the same key combination after a delay
        hs.timer.doAfter(0.1, function()
            hs.eventtap.keyStroke(expose_hotkey[1], expose_hotkey[2])
        end)
    end)

    log.i("Setup lazy loading for expose")
end

-- Load expose module
function M.loadExpose()
    if not expose_loaded then
        log.i("Loading expose functionality")

        -- Configure expose with default settings
        expose = hs.expose.new(nil, {
            onlyActiveApplication = false,
            showThumbnails = true,
            includeOtherSpaces = true,      -- Show windows from other spaces
            includeNonVisible = true,       -- Include hidden/minimized windows
        })

        -- Bind the actual expose hotkey
        local expose_hotkey = getHotkeyConfig("system.expose") or {"ctrl", "cmd", "tab"}
        hs.hotkey.bind(expose_hotkey[1], expose_hotkey[2], "Expose", function()
            if expose then
                expose:toggleShow()
                log.i("Toggled window expose")
            end
        end)

        expose_loaded = true
        log.i("Expose module loaded successfully")
    end
end

-- Check if expose is loaded
function M.isLoaded()
    return expose_loaded
end

-- Toggle expose visibility
function M.toggle()
    if not expose_loaded then
        M.loadExpose()
    end

    if expose then
        expose:toggleShow()
        log.i("Toggled window expose")
        return true
    end

    return false
end

-- Show expose
function M.show()
    if not expose_loaded then
        M.loadExpose()
    end

    if expose then
        expose:show()
        log.i("Showed window expose")
        return true
    end

    return false
end

-- Hide expose
function M.hide()
    if expose and expose_loaded then
        expose:hide()
        log.i("Hid window expose")
        return true
    end

    return false
end

-- Get expose status
function M.getStatus()
    return {
        loaded = expose_loaded,
        visible = expose and expose:isVisible() or false,
        functionality_available = hs.expose ~= nil
    }
end

-- Print debugging information
function M.debug()
    local status = M.getStatus()

    log.i("Window Expose Debug Info:")
    log.i(string.format("  Loaded: %s", tostring(status.loaded)))
    log.i(string.format("  Visible: %s", tostring(status.visible)))
    log.i(string.format("  Functionality available: %s", tostring(status.functionality_available)))

    if status.functionality_available then
        log.i("  Hammerspoon expose API is available")
    else
        log.w("  Hammerspoon expose API is not available")
    end
end

-- Register module with init system
local init_system = require("core.init_system")
init_system.registerModule("modules.window_expose", {
    init = M.init
})

return M