-- Keystroke Visualizer (KeyCastr) Module for Hammerspoon
-- Modularized version with configuration separation and improved structure

local logger = require("core.logger")
local config = require("core.config_loader")
local hotkey_utils = require("utils.hotkey_utils")

local log = logger.getLogger("keystroke_visualizer")
local MODULE_NAME = "keystroke_visualizer"

local M = {}

-- State variables
local keystroke_drawings = {}
local drag_initial = nil
local offset_position = {x = 0, y = 0}
local continuous_text = ""
local last_input_time = 0

-- Event taps
local key_event_tap = nil
local mouse_event_tap = nil
local drag_event_tap = nil
local cleanup_timer = nil

-- Get configuration values
local function getKeyCastrConfig(path)
    return config.get("keycastr." .. path)
end

local function getHotkeyConfig(path)
    return config.get("hotkeys." .. path)
end

-- Initialize keystroke visualizer
function M.init()
    log.i("Initializing keystroke visualizer module")

    -- Setup toggle hotkeys
    M.setupToggleHotkeys()

    -- Setup event tracking
    M.setupEventTracking()

    -- Setup dragging
    M.setupDragging()

    log.i("Keystroke visualizer module initialized")
end

-- Setup toggle hotkeys
function M.setupToggleHotkeys()
    local toggle_key = getHotkeyConfig("keycastr.toggle") or {"ctrl", "cmd", "alt", "k"}
    local circle_key = getHotkeyConfig("keycastr.click_circle") or {"ctrl", "cmd", "alt", "c"}
    local continuous_key = getHotkeyConfig("keycastr.continuous") or {"ctrl", "cmd", "alt", "i"}

    hotkey_utils.bind(toggle_key, {
        module = MODULE_NAME,
        id = "toggle",
        description = "Toggle Keystroke Visualizer",
        toast = {
            id = "toggle",
            enabled = true,
            duration = 1.5,
            message_fn = function()
                local enabled = getKeyCastrConfig("enabled")
                return "KeyCastr: " .. (enabled and "Enabled" or "Disabled")
            end
        },
        pressed = M.toggleKeystrokes
    })
    hotkey_utils.bind(circle_key, {
        module = MODULE_NAME,
        id = "click_circle",
        description = "Toggle Click Circle",
        toast = {
            id = "click_circle",
            enabled = true,
            duration = 1.5,
            message_fn = function()
                local show_circle = getKeyCastrConfig("show_click_circle")
                return "Click Circle: " .. (show_circle and "Enabled" or "Disabled")
            end
        },
        pressed = M.toggleClickCircle
    })
    hotkey_utils.bind(continuous_key, {
        module = MODULE_NAME,
        id = "continuous",
        description = "Toggle Continuous Input",
        toast = {
            id = "continuous",
            enabled = true,
            duration = 1.5,
            message_fn = function()
                local enabled = getKeyCastrConfig("continuous_input.enabled")
                return "Continuous Input: " .. (enabled and "Enabled" or "Disabled")
            end
        },
        pressed = M.toggleContinuousInput
    })

    log.i("Setup keystroke visualizer hotkeys")
end

-- Toggle keystroke visualization
function M.toggleKeystrokes()
    local enabled = not getKeyCastrConfig("enabled")
    config.set("keycastr.enabled", enabled)

    if not enabled then
        M.clearAllDrawings()
    end

    log.i(string.format("Toggled keystroke visualization: %s", tostring(enabled)))
end

-- Toggle click circle visualization
function M.toggleClickCircle()
    local show_circle = not getKeyCastrConfig("show_click_circle")
    config.set("keycastr.show_click_circle", show_circle)

    log.i(string.format("Toggled click circle: %s", tostring(show_circle)))
end

-- Toggle continuous input mode
function M.toggleContinuousInput()
    local enabled = not getKeyCastrConfig("continuous_input.enabled")
    config.set("keycastr.continuous_input.enabled", enabled)

    continuous_text = ""
    log.i(string.format("Toggled continuous input: %s", tostring(enabled)))
end

-- Clear all drawings
function M.clearAllDrawings()
    for _, item in ipairs(keystroke_drawings) do
        item.canvas:delete()
    end
    keystroke_drawings = {}
    continuous_text = ""
    log.d("Cleared all keystroke drawings")
end

-- Simple drawing function for text
function M.drawEvent(text, event_type, is_modifier)
    if not getKeyCastrConfig("enabled") then return end

    local now = hs.timer.secondsSinceEpoch()
    local screen = hs.screen.mainScreen()
    local frame = screen:frame()

    -- Calculate text dimensions
    local font_size = getKeyCastrConfig("font_size") or 24
    local padding = getKeyCastrConfig("padding") or 4
    local text_width = hs.drawing.getTextDrawingSize(text, {size = font_size}).w

    local box_width = text_width + (padding * 2)
    local box_height = font_size + (padding * 2)

    -- Position calculation
    local position = M.getPositionForScreen(screen)
    local margin = getKeyCastrConfig("margin") or 6

    -- Calculate Y position based on existing drawings
    local y_offset = 0
    for _, item in ipairs(keystroke_drawings) do
        y_offset = y_offset + item.canvas:frame().h + margin
    end

    local x = position.x
    local y = position.y - y_offset

    -- Create drawing
    local drawing = hs.canvas.new({x = x, y = y, w = box_width, h = box_height})

    -- Background
    local bg_color = getKeyCastrConfig("colors.background") or {hex = "#333333", alpha = 0.8}
    drawing:appendElements({
        type = "rectangle",
        action = "fill",
        roundedRectRadii = {xRadius = 5, yRadius = 5},
        fillColor = bg_color
    })

    -- Text
    local text_color = getKeyCastrConfig("colors.text") or {hex = "#FFFFFF"}
    drawing:appendElements({
        type = "text",
        text = text,
        textSize = font_size,
        textColor = text_color,
        textAlignment = "center",
        frame = {x = padding, y = padding/2, w = text_width, h = font_size}
    })

    -- Make it appear on all spaces
    drawing:behavior({"canJoinAllSpaces", "stationary"})
    drawing:show()

    -- Add to active drawings
    table.insert(keystroke_drawings, {
        canvas = drawing,
        time = now,
        screen = screen:id(),
        isContinuous = (event_type == "keyboard" and not is_modifier and text:len() > 1)
    })

    -- Remove oldest if exceed max
    local max_displayed = getKeyCastrConfig("max_displayed") or 6
    while #keystroke_drawings > max_displayed do
        local old = table.remove(keystroke_drawings)
        old.canvas:delete()
    end

    log.d(string.format("Drew event: %s (type: %s)", text, event_type))
end

-- Get position for screen
function M.getPositionForScreen(screen)
    local config_position = getKeyCastrConfig("position") or {x = 30, y = nil}
    local screen_margin = getKeyCastrConfig("screen_edge_margin") or 20
    local frame = screen:frame()

    local x = config_position.x + offset_position.x
    local y = config_position.y

    -- If y is nil, position at bottom of screen
    if y == nil then
        y = frame.h - screen_margin - (getKeyCastrConfig("font_size") or 24)
    end

    return {
        x = x,
        y = y + offset_position.y
    }
end

-- Format keystroke text
function M.formatKeystroke(event)
    local modifiers = event:getFlags()
    local key_code = event:getKeyCode()
    local key = hs.keycodes.map[key_code]

    if not key then return nil end

    -- Check display mode
    local display_mode = getKeyCastrConfig("display_mode") or "all_modifiers"
    local has_command = modifiers.cmd
    local has_any_modifier = modifiers.cmd or modifiers.alt or modifiers.shift or modifiers.ctrl

    if display_mode == "command_only" and not has_command then
        return nil
    elseif display_mode == "all_modifiers" and not has_any_modifier then
        return nil
    end

    -- Get key and modifier symbols from config
    local special_keys = getKeyCastrConfig("special_keys") or {}
    local modifier_symbols = getKeyCastrConfig("modifier_symbols") or {}

    local is_modifier = false
    if modifier_symbols[key] then
        is_modifier = true
        return modifier_symbols[key], is_modifier
    end

    -- Build modifier prefix
    local mod_text = ""
    if modifiers.ctrl then mod_text = mod_text .. (modifier_symbols.ctrl or "⌃") end
    if modifiers.alt then mod_text = mod_text .. (modifier_symbols.alt or "⌥") end
    if modifiers.cmd then mod_text = mod_text .. (modifier_symbols.cmd or "⌘") end

    -- Handle shift
    local key_text = ""
    if modifiers.shift then
        if key:len() == 1 and key:match("[a-zA-Z]") then
            key_text = key:upper()
        else
            mod_text = mod_text .. (modifier_symbols.shift or "⇧")
            local raw = special_keys[key] or key
            if raw == key and type(raw) == "string" then
                key_text = string.upper(raw)
            else
                key_text = raw
            end
        end
    else
        local raw = special_keys[key] or key
        if raw == key and type(raw) == "string" then
            key_text = string.upper(raw)
        else
            key_text = raw
        end
    end

    if mod_text ~= "" then
        is_modifier = true
    end

    return mod_text .. key_text, is_modifier
end

-- Clean up expired keystrokes
function M.cleanupExpiredKeystrokes()
    local now = hs.timer.secondsSinceEpoch()
    local duration = getKeyCastrConfig("duration") or 1.5
    local fade_duration = getKeyCastrConfig("fade_out_duration") or 0.3

    local i = #keystroke_drawings
    while i > 0 do
        local item = keystroke_drawings[i]
        if now - item.time >= duration then
            item.canvas:delete(fade_duration)
            table.remove(keystroke_drawings, i)
        end
        i = i - 1
    end
end

-- Setup event tracking (simplified version)
function M.setupEventTracking()
    -- Key event tracking
    key_event_tap = hs.eventtap.new({
        hs.eventtap.event.types.keyDown,
        hs.eventtap.event.types.flagsChanged
    }, function(event)
        if not getKeyCastrConfig("enabled") then return false end

        local text, is_modifier = M.formatKeystroke(event)
        if text then
            M.drawEvent(text, "keyboard", is_modifier)
        end

        return false
    end)

    key_event_tap:start()

    -- Cleanup timer
    cleanup_timer = hs.timer.doEvery(0.5, M.cleanupExpiredKeystrokes)

    log.i("Setup event tracking")
end

-- Setup dragging (simplified version)
function M.setupDragging()
    local draggable = getKeyCastrConfig("draggable") or false
    if not draggable then return end

    -- Basic dragging setup would go here
    log.i("Setup dragging")
end

-- Get keystroke visualizer status
function M.getStatus()
    return {
        enabled = getKeyCastrConfig("enabled") or false,
        drawings_count = #keystroke_drawings,
        show_click_circle = getKeyCastrConfig("show_click_circle") or false,
        continuous_input = getKeyCastrConfig("continuous_input.enabled") or false
    }
end

-- Register module with init system
local init_system = require("core.init_system")
init_system.registerModule("modules.keystroke_visualizer", {
    init = M.init
})

return M
