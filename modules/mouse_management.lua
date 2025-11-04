-- Mouse Management Module for Hammerspoon
-- Handles mouse scroll reversal, button bindings, and special mouse features

local logger = require("core.logger")
local config = require("core.config_loader")
local app_utils = require("utils.app_utils")
local hotkey_utils = require("utils.hotkey_utils")

local log = logger.getLogger("mouse_management")

local M = {}

-- Global variables for mouse event taps
local scroll_flip_tap = nil
local mouse_button_tap = nil

-- Get configuration values
local function getHotkeyConfig(path)
    return config.get("hotkeys." .. path)
end

local function getAppConfig(path)
    return config.get("applications." .. path)
end

-- Initialize mouse management
function M.init()
    log.i("Initializing mouse management module")

    -- Setup mouse scroll reversal
    M.setupScrollReversal()

    -- Setup mouse button bindings
    M.setupMouseButtons()

    -- Setup mouse utility hotkeys
    M.setupMouseHotkeys()

    -- Setup paste defeat
    M.setupPasteDefeat()

    log.i("Mouse management module initialized")
end

-- Setup mouse scroll reversal
function M.setupScrollReversal()
    log.i("Setting up mouse scroll reversal")

    scroll_flip_tap = hs.eventtap.new({hs.eventtap.event.types.scrollWheel}, function(event)
        -- Check if this is a mouse scroll (not trackpad)
        local is_mouse_scroll = event:getProperty(hs.eventtap.event.properties.scrollWheelEventIsContinuous) == 0

        if is_mouse_scroll then
            -- Flip vertical scroll (Axis1), horizontal (Axis2) remains unchanged
            local vertical = event:getProperty(hs.eventtap.event.properties.scrollWheelEventDeltaAxis1)

            event:setProperty(hs.eventtap.event.properties.scrollWheelEventDeltaAxis1, -vertical)
            log.d("Reversed mouse scroll direction")
            return true, {event}
        end

        return false
    end)

    scroll_flip_tap:start()
    log.i("Mouse scroll reversal enabled")
end

-- Setup mouse button bindings
function M.setupMouseButtons()
    log.i("Setting up mouse button bindings")

    local mouse_modifier = getHotkeyConfig("mouse.modifier") or {"fn", "ctrl"}

    mouse_button_tap = hs.eventtap.new({
        hs.eventtap.event.types.otherMouseDown,
        -- hs.eventtap.event.types.otherMouseUp -- Uncomment if needed
    }, function(event)
        local button = event:getProperty(hs.eventtap.event.properties.mouseEventButtonNumber)

        if button == 2 and not app_utils.isBrowser() then
            -- Back button - show mission control equivalent
            log.d("Mouse button 2: Mission control")
            hs.eventtap.keyStroke(mouse_modifier, "up", 0)
            return true
        elseif button == 3 then
            -- Forward button - show application windows
            log.d("Mouse button 3: Application windows")
            hs.eventtap.keyStroke(mouse_modifier, "right", 0)
            return true
        elseif button == 4 then
            -- Side button 1 - custom action
            log.d("Mouse button 4: Custom action")
            hs.eventtap.keyStroke(mouse_modifier, "left", 0)
            return true
        end

        return false
    end)

    mouse_button_tap:start()
    log.i("Mouse button bindings enabled")
end

-- Setup mouse utility hotkeys
function M.setupMouseHotkeys()
    -- Mouse speed adjustment
    hotkey_utils.bind({"ctrl", "cmd", "alt"}, "=", {
        description = "Mouse Speed Up",
        pressed = function()
            M.adjustMouseSpeed(0.1)
        end
    })

    hotkey_utils.bind({"ctrl", "cmd", "alt"}, "-", {
        description = "Mouse Speed Down",
        pressed = function()
            M.adjustMouseSpeed(-0.1)
        end
    })

    -- Mouse acceleration toggle
    hotkey_utils.bind({"ctrl", "cmd", "alt"}, "\\", {
        description = "Toggle Mouse Acceleration",
        pressed = function()
            M.toggleMouseAcceleration()
        end
    })

    -- Center mouse on focused window
    hotkey_utils.bind({"ctrl", "cmd", "alt"}, "m", {
        description = "Center Mouse on Window",
        pressed = function()
            M.centerMouseOnWindow()
        end
    })

    log.i("Setup mouse utility hotkeys")
end

-- Setup paste defeat (bypass paste blocking)
function M.setupPasteDefeat()
    local paste_hotkey = getHotkeyConfig("protection.paste_defeat") or {"cmd", "alt", "V"}

    local paste_mods, paste_key = hotkey_utils.parseHotkey(paste_hotkey)
    if not paste_key then
        log.e("Paste defeat hotkey configuration is invalid")
        return
    end

    hotkey_utils.bind(paste_mods, paste_key, {
        description = "Paste Defeat",
        pressed = function()
            local clipboard_content = hs.pasteboard.getContents()
            if clipboard_content and clipboard_content ~= "" then
                hs.eventtap.keyStrokes(clipboard_content)
                log.i("Paste defeat: Pasted clipboard content")
            else
                log.w("Paste defeat: No clipboard content")
            end
        end
    })

    log.i("Setup paste defeat hotkey")
end

-- Adjust mouse speed
function M.adjustMouseSpeed(delta)
    -- This requires additional tools or permissions on macOS
    log.w("Mouse speed adjustment not implemented")
    hs.alert.show("Mouse speed adjustment not available")
end

-- Toggle mouse acceleration
function M.toggleMouseAcceleration()
    -- This requires additional tools or permissions on macOS
    log.w("Mouse acceleration toggle not implemented")
    hs.alert.show("Mouse acceleration toggle not available")
end

-- Center mouse on focused window
function M.centerMouseOnWindow()
    local win = hs.window.focusedWindow()
    if not win then
        log.d("No focused window for mouse centering")
        return
    end

    local frame = win:frame()
    if not frame then
        log.w("Failed to get window frame for mouse centering")
        return
    end

    local center_x = frame.x + frame.w / 2
    local center_y = frame.y + frame.h / 2

    hs.mouse.setAbsolutePosition({x = center_x, y = center_y})
    log.i(string.format("Centered mouse on window at (%.0f, %.0f)", center_x, center_y))
end

-- Get current mouse position and screen
function M.getMouseInfo()
    local position = hs.mouse.getAbsolutePosition()
    local screen = hs.mouse.getCurrentScreen()

    return {
        x = position.x,
        y = position.y,
        screen = screen and screen:name() or "Unknown",
        screen_frame = screen and screen:frame() or nil
    }
end

-- Move mouse to specific position
function M.moveMouse(x, y, relative)
    if relative then
        local current = hs.mouse.getAbsolutePosition()
        x = current.x + x
        y = current.y + y
    end

    hs.mouse.setAbsolutePosition({x = x, y = y})
    log.i(string.format("Moved mouse to (%.0f, %.0f)", x, y))
end

-- Click mouse button
function M.clickMouse(button, double_click)
    button = button or "left"
    double_click = double_click or false

    local button_map = {
        left = 0,
        right = 1,
        middle = 2
    }

    local button_code = button_map[button]
    if not button_code then
        log.w(string.format("Unknown mouse button: %s", button))
        return false
    end

    local event_type = double_click and "otherMouseDoubleClicked" or "otherMouseDown"

    local event = hs.eventtap.event.newMouseEvent(event_type, {x = 0, y = 0}, {})
    event:setProperty(hs.eventtap.event.properties.mouseEventButtonNumber, button_code)
    event:post()

    -- Send mouse up event
    local up_event = hs.eventtap.event.newMouseEvent("otherMouseUp", {x = 0, y = 0}, {})
    up_event:setProperty(hs.eventtap.event.properties.mouseEventButtonNumber, button_code)
    up_event:post()

    log.i(string.format("Clicked %s mouse button%s", button, double_click and " (double)" or ""))
    return true
end

-- Scroll in specific direction
function M.scroll(amount, direction)
    direction = direction or "vertical"

    local property
    if direction == "vertical" then
        property = hs.eventtap.event.properties.scrollWheelEventDeltaAxis1
    elseif direction == "horizontal" then
        property = hs.eventtap.event.properties.scrollWheelEventDeltaAxis2
    else
        log.w(string.format("Unknown scroll direction: %s", direction))
        return false
    end

    local event = hs.eventtap.event.newEvent(hs.eventtap.event.types.scrollWheel, {x = 0, y = 0}, {})
    event:setProperty(property, amount)
    event:post()

    log.i(string.format("Scrolled %s: %d", direction, amount))
    return true
end

-- Stop mouse management (cleanup)
function M.stop()
    if scroll_flip_tap then
        scroll_flip_tap:stop()
        scroll_flip_tap = nil
    end

    if mouse_button_tap then
        mouse_button_tap:stop()
        mouse_button_tap = nil
    end

    log.i("Mouse management stopped")
end

-- Restart mouse management
function M.restart()
    M.stop()
    M.init()
    log.i("Mouse management restarted")
end

-- Get mouse management status
function M.getStatus()
    local mouse_info = M.getMouseInfo()

    return {
        scroll_reversal_enabled = scroll_flip_tap ~= nil,
        mouse_buttons_enabled = mouse_button_tap ~= nil,
        paste_defeat_enabled = true,
        mouse_position = string.format("(%.0f, %.0f)", mouse_info.x, mouse_info.y),
        current_screen = mouse_info.screen
    }
end

-- Print debugging information
function M.debug()
    local status = M.getStatus()
    local mouse_info = M.getMouseInfo()

    log.i("Mouse Management Debug Info:")
    log.i(string.format("  Scroll reversal enabled: %s", tostring(status.scroll_reversal_enabled)))
    log.i(string.format("  Mouse buttons enabled: %s", tostring(status.mouse_buttons_enabled)))
    log.i(string.format("  Paste defeat enabled: %s", tostring(status.paste_defeat_enabled)))
    log.i(string.format("  Mouse position: %s", status.mouse_position))
    log.i(string.format("  Current screen: %s", status.current_screen))

    if mouse_info.screen_frame then
        local frame = mouse_info.screen_frame
        log.i(string.format("  Screen frame: %.0fx%.0f at %.0f,%.0f",
            frame.w, frame.h, frame.x, frame.y))
    end
end

-- Register module with init system
local init_system = require("core.init_system")
init_system.registerModule("modules.mouse_management", {
    init = M.init,
    dependencies = {
        "utils.app_utils"
    }
})

return M
