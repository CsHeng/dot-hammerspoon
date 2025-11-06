-- Mouse Management (Spaces) Module for Hammerspoon
-- Alternative implementation that uses hs.spaces to change Mission Control spaces

local logger = require("core.logger")
local config = require("core.config_loader")
local app_utils = require("utils.app_utils")
local hotkey_utils = require("utils.hotkey_utils")

local spaces = hs.spaces
local screen = hs.screen

local log = logger.getLogger("mouse_management_spaces")
local MODULE_NAME = "mouse_management_spaces"

local M = {}

-- Global taps
local scroll_flip_tap = nil
local mouse_button_tap = nil
local consumed_mouse_buttons = {}

-- Helpers --------------------------------------------------------------------

local function getHotkeyConfig(path)
    return config.get("hotkeys." .. path)
end

local function describeModifiers(mods)
    if type(mods) ~= "table" then
        return tostring(mods)
    end
    local copy = {}
    for _, m in ipairs(mods) do
        table.insert(copy, m)
    end
    return table.concat(copy, "+")
end

local function spacesAvailable()
    return spaces and spaces.spacesForScreen and spaces.activeSpaceOnScreen and spaces.gotoSpace
end

local function sendFallbackKeystroke(delta)
    local modifiers = getHotkeyConfig("mouse.modifier") or {"fn", "ctrl"}
    local key = delta > 0 and "right" or "left"
    hs.eventtap.keyStroke(modifiers, key, 0)
    log.d(string.format("Fallback keystroke sent: %s+%s", describeModifiers(modifiers), key))
    return true
end

local function switchSpace(delta)
    if not spacesAvailable() then
        log.w("hs.spaces unavailable; using keystroke fallback")
        return sendFallbackKeystroke(delta)
    end

    local current_screen = hs.mouse.getCurrentScreen() or screen.mainScreen()
    if not current_screen then
        log.w("Could not determine current screen for space switching")
        return sendFallbackKeystroke(delta)
    end

    local screen_spaces = spaces.spacesForScreen(current_screen)
    if not screen_spaces or #screen_spaces == 0 then
        log.d("No spaces found for current screen; using fallback")
        return sendFallbackKeystroke(delta)
    end

    local active_space = spaces.activeSpaceOnScreen(current_screen)
    if not active_space then
        log.d("Unable to determine active space; using fallback")
        return sendFallbackKeystroke(delta)
    end

    local current_index = hs.fnutils.indexOf(screen_spaces, active_space)
    if not current_index then
        log.d("Active space not present in screen space list; using fallback")
        return sendFallbackKeystroke(delta)
    end

    local target_space = screen_spaces[current_index + delta]
    if not target_space then
        log.d("No adjacent space in requested direction")
        return true -- consume event without fallback to avoid duplicate actions
    end

    local ok, err = pcall(function()
        spaces.gotoSpace(target_space)
    end)

    if not ok then
        log.w(string.format("hs.spaces.gotoSpace failed (%s); using fallback", tostring(err)))
        return sendFallbackKeystroke(delta)
    end

    log.i(string.format("Switched to space %s (delta: %d)", tostring(target_space), delta))
    return true
end

local function handleMiddleClick()
    if app_utils.isBrowser() then
        log.d("Middle click inside browser; letting application handle it")
        return false
    end

    local modifiers = getHotkeyConfig("mouse.modifier") or {"fn", "ctrl"}
    hs.eventtap.keyStroke(modifiers, "up", 0)
    log.d(string.format("Trigger Mission Control via %s+up", describeModifiers(modifiers)))
    return true
end

-- Module lifecycle -----------------------------------------------------------

function M.setupScrollReversal()
    log.i("Setting up mouse scroll reversal (spaces variant)")

    scroll_flip_tap = hs.eventtap.new({hs.eventtap.event.types.scrollWheel}, function(event)
        local is_mouse_scroll = event:getProperty(hs.eventtap.event.properties.scrollWheelEventIsContinuous) == 0
        if not is_mouse_scroll then
            return false
        end

        local vertical = event:getProperty(hs.eventtap.event.properties.scrollWheelEventDeltaAxis1)
        event:setProperty(hs.eventtap.event.properties.scrollWheelEventDeltaAxis1, -vertical)
        log.d("Reversed mouse scroll direction")
        return true, {event}
    end)

    scroll_flip_tap:start()
    log.i("Mouse scroll reversal enabled")
end

function M.setupMouseButtons()
    log.i("Setting up mouse button bindings (spaces variant)")

    local fallback_modifier = getHotkeyConfig("mouse.modifier") or {"fn", "ctrl"}
    local modifier_label = describeModifiers(fallback_modifier)
    local shortcut_prefix = modifier_label ~= "" and (modifier_label .. "+") or ""
    log.i(string.format("Mouse button 2 -> %sup (Mission Control fallback)", shortcut_prefix))
    log.i("Mouse button 3/5 -> Switch space forward")
    log.i("Mouse button 4 -> Switch space backward")

    mouse_button_tap = hs.eventtap.new({
        hs.eventtap.event.types.otherMouseDown,
        hs.eventtap.event.types.otherMouseUp
    }, function(event)
        local event_type = event:getType()
        local button = event:getProperty(hs.eventtap.event.properties.mouseEventButtonNumber)

        if event_type == hs.eventtap.event.types.otherMouseDown then
            local consumed = false
            if button == 2 then
                consumed = handleMiddleClick()
            elseif button == 3 or button == 5 then
                log.d(string.format("Mouse button %s -> switch space forward", tostring(button)))
                consumed = switchSpace(1)
            elseif button == 4 then
                log.d("Mouse button 4 -> switch space backward")
                consumed = switchSpace(-1)
            end

            if consumed then
                consumed_mouse_buttons[button] = true
            end
            return consumed
        elseif event_type == hs.eventtap.event.types.otherMouseUp then
            local consumed = consumed_mouse_buttons[button]
            consumed_mouse_buttons[button] = nil
            return consumed or false
        end

        return false
    end)

    mouse_button_tap:start()
    log.i("Mouse button bindings enabled")
end

function M.setupMouseHotkeys()
    hotkey_utils.bind({"ctrl", "cmd", "alt"}, "=", {
        module = MODULE_NAME,
        id = "speed_up",
        description = "Mouse Speed Up",
        pressed = function()
            M.adjustMouseSpeed(0.1)
        end,
        announce = {
            id = "mouse_speed_unavailable",
            enabled = true,
            duration = 1.2,
            message = "Mouse speed adjustment not available"
        }
    })

    hotkey_utils.bind({"ctrl", "cmd", "alt"}, "-", {
        module = MODULE_NAME,
        id = "speed_down",
        description = "Mouse Speed Down",
        pressed = function()
            M.adjustMouseSpeed(-0.1)
        end,
        announce = {
            id = "mouse_speed_unavailable",
            enabled = true,
            duration = 1.2,
            message = "Mouse speed adjustment not available"
        }
    })

    hotkey_utils.bind({"ctrl", "cmd", "alt"}, "\\", {
        module = MODULE_NAME,
        id = "toggle_acceleration",
        description = "Toggle Mouse Acceleration",
        pressed = function()
            M.toggleMouseAcceleration()
        end,
        announce = {
            id = "mouse_accel_unavailable",
            enabled = true,
            duration = 1.2,
            message = "Mouse acceleration toggle not available"
        }
    })

    log.i("Mouse utility hotkeys registered")
    log.d("Center mouse function available via mouse_management_spaces.centerMouseOnWindow()")
end

function M.setupPasteDefeat()
    local paste_hotkey = getHotkeyConfig("protection.paste_defeat") or {"cmd", "alt", "V"}

    local mods, key = hotkey_utils.parseHotkey(paste_hotkey)
    if not key then
        log.e("Paste defeat hotkey configuration is invalid")
        return
    end

    hotkey_utils.bind(mods, key, {
        module = MODULE_NAME,
        description = "Paste Defeat",
        pressed = function()
            local clipboard_content = hs.pasteboard.getContents()
            if clipboard_content and clipboard_content ~= "" then
                hs.eventtap.keyStrokes(clipboard_content)
                log.i("Paste defeat: pasted clipboard content")
            else
                log.w("Paste defeat: clipboard empty")
            end
        end
    })

    log.i("Paste defeat hotkey registered")
end

function M.init()
    log.i("Initializing mouse management (spaces)")
    M.setupScrollReversal()
    M.setupMouseButtons()
    M.setupMouseHotkeys()
    M.setupPasteDefeat()
    log.i("Mouse management (spaces) initialized")
end

-- Utility helpers ------------------------------------------------------------

function M.adjustMouseSpeed(delta)
    log.w("Mouse speed adjustment not implemented")
end

function M.toggleMouseAcceleration()
    log.w("Mouse acceleration toggle not implemented")
end

function M.centerMouseOnWindow()
    local win = hs.window.focusedWindow()
    if not win then
        log.d("Center mouse: no focused window")
        return
    end

    local frame = win:frame()
    if not frame then
        log.w("Center mouse: failed to obtain frame")
        return
    end

    local center_x = frame.x + frame.w / 2
    local center_y = frame.y + frame.h / 2
    hs.mouse.absolutePosition({x = center_x, y = center_y})
    log.i(string.format("Centered mouse at (%.0f, %.0f)", center_x, center_y))
end

function M.getMouseInfo()
    local position = hs.mouse.absolutePosition()
    local current_screen = hs.mouse.getCurrentScreen()

    return {
        x = position.x,
        y = position.y,
        screen = current_screen and current_screen:name() or "Unknown",
        screen_frame = current_screen and current_screen:frame() or nil
    }
end

function M.stop()
    if scroll_flip_tap then
        scroll_flip_tap:stop()
        scroll_flip_tap = nil
    end

    if mouse_button_tap then
        mouse_button_tap:stop()
        mouse_button_tap = nil
    end

    consumed_mouse_buttons = {}
    log.i("Mouse management (spaces) stopped")
end

function M.restart()
    M.stop()
    M.init()
    log.i("Mouse management (spaces) restarted")
end

function M.getStatus()
    local info = M.getMouseInfo()
    return {
        spaces_driver = spacesAvailable(),
        scroll_reversal_enabled = scroll_flip_tap ~= nil,
        mouse_buttons_enabled = mouse_button_tap ~= nil,
        mouse_position = string.format("(%.0f, %.0f)", info.x, info.y),
        current_screen = info.screen
    }
end

function M.debug()
    local status = M.getStatus()
    log.i("Mouse Management (Spaces) Debug Info:")
    log.i(string.format("  Spaces driver available: %s", tostring(status.spaces_driver)))
    log.i(string.format("  Scroll reversal: %s", tostring(status.scroll_reversal_enabled)))
    log.i(string.format("  Mouse buttons: %s", tostring(status.mouse_buttons_enabled)))
    log.i(string.format("  Mouse position: %s", status.mouse_position))
    log.i(string.format("  Current screen: %s", status.current_screen))
end

-- Module registration --------------------------------------------------------

local init_system = require("core.init_system")
init_system.registerModule("modules.mouse_management_spaces", {
    init = M.init,
    dependencies = {
        "utils.app_utils"
    }
})

return M
