-- Media Controls Module for Hammerspoon
-- Handles media playback controls and system audio controls
-- Separated from application launcher for better modularity

local logger = require("core.logger")
local config = require("core.config_loader")
local notification_utils = require("utils.notification_utils")
local hotkey_utils = require("utils.hotkey_utils")

local log = logger.getLogger("media_controls")
local MODULE_NAME = "media_controls"
local brightness = hs.brightness

local M = {}

-- Get configuration values
local function getHotkeyConfig(path)
    return config.get("hotkeys." .. path)
end

local function getAppConfig(path)
    return config.get("applications." .. path)
end

-- Initialize media controls
function M.init()
    log.i("Initializing media controls module")

    -- Setup media control hotkeys
    M.setupMediaHotkeys()

    -- Setup audio device controls
    M.setupAudioControls()

    -- Setup system controls
    M.setupSystemControls()

    log.i("Media controls module initialized")
end

-- Setup media control hotkeys
function M.setupMediaHotkeys()
    local media_controls = getAppConfig("media_controls") or {}

    log.i(string.format("Setting up %d media control hotkeys", #media_controls))

    hs.fnutils.each(media_controls, function(entry)
        if entry.key and entry.action then
            local desc = entry.description or string.format("Media: %s", entry.action)
            local modifiers = entry.modifier or getHotkeyConfig("media.modifier") or {"ctrl", "cmd", "alt"}
            hotkey_utils.bind(modifiers, entry.key, {
                module = MODULE_NAME,
                description = desc,
                announce = false,
                pressed = function()
                    M.sendMediaKeyEvent(entry.action)
                end
            })
            log.d(string.format("Registered media hotkey: %s+%s -> %s",
                table.concat(modifiers, "+"), entry.key, entry.action))
        end
    end)
end

-- Setup audio device controls
function M.setupAudioControls()
    -- Note: Volume up/down are handled by media_controls configuration
    -- to avoid duplicate hotkey registration
    -- Only setup mute toggle here

    -- Mute toggle
    hotkey_utils.bind({"ctrl", "cmd", "alt"}, "m", {
        module = MODULE_NAME,
        description = "Audio: Toggle Mute",
        announce = false,
        pressed = function()
            M.toggleMute()
        end
    })

    log.i("Setup audio device control hotkeys (mute only)")
end

-- Setup system controls
function M.setupSystemControls()
    -- Brightness controls (if supported)
    hotkey_utils.bind({"ctrl", "cmd", "alt"}, "[", {
        module = MODULE_NAME,
        description = "Brightness Down",
        announce = false,
        pressed = function()
            M.adjustBrightness(-0.05)
        end
    })

    hotkey_utils.bind({"ctrl", "cmd", "alt"}, "]", {
        module = MODULE_NAME,
        description = "Brightness Up",
        announce = false,
        pressed = function()
            M.adjustBrightness(0.05)
        end
    })

    -- Keyboard backlight (if supported)
    hotkey_utils.bind({"ctrl", "cmd", "alt"}, ";", {
        module = MODULE_NAME,
        description = "Keyboard Backlight Down",
        announce = false,
        pressed = function()
            M.adjustKeyboardBacklight(-0.1)
        end
    })

    hotkey_utils.bind({"ctrl", "cmd", "alt"}, "'", {
        module = MODULE_NAME,
        description = "Keyboard Backlight Up",
        announce = false,
        pressed = function()
            M.adjustKeyboardBacklight(0.1)
        end
    })

    log.i("Setup system control hotkeys")
end

-- Send media key event
function M.sendMediaKeyEvent(action)
    log.i(string.format("Sending media key event: %s", action))

    local success, err = pcall(function()
        -- Create and send key event
        local key_event = hs.eventtap.event.newSystemKeyEvent(action, true)
        key_event:post()
        hs.timer.doAfter(0.01, function()
            local key_event = hs.eventtap.event.newSystemKeyEvent(action, false)
            key_event:post()
        end)
    end)

    if success then
        local eventId = string.lower(tostring(action))
        notification_utils.announce(MODULE_NAME, "media_" .. eventId, {
            message = string.format("Media: %s", action),
            duration = 0.5,
            override = true,
            metadata = {action = action}
        })
    else
        log.e(string.format("Failed to send media key event: %s", err))
    end
end

-- Adjust system volume
function M.adjustVolume(delta)
    local device = hs.audiodevice.defaultOutputDevice()
    if not device then
        log.w("No default output device found")
        return
    end

    local current_volume = device:volume()
    if current_volume == nil then
        log.w("Failed to get current volume")
        return
    end

    local new_volume = math.max(0, math.min(1, current_volume + delta))
    device:setVolume(new_volume)

    local volume_percent = math.floor(new_volume * 100)
    log.i(string.format("Volume set to %d%%", volume_percent))
    notification_utils.announce(MODULE_NAME, "volume", {
        message = string.format("Volume: %d%%", volume_percent),
        duration = 0.5,
        override = true
    })
end

-- Toggle mute
function M.toggleMute()
    local device = hs.audiodevice.defaultOutputDevice()
    if not device then
        log.w("No default output device found")
        return
    end

    local current_mute = device:outputMuted()
    device:setOutputMuted(not current_mute)

    local status = not current_mute and "Muted" or "Unmuted"
    log.i(string.format("Audio %s", status))
    notification_utils.announce(MODULE_NAME, "mute_toggle", {
        message = string.format("Audio: %s", status),
        duration = 0.5,
        override = true
    })
end

-- Get current audio devices information
function M.getAudioDeviceInfo()
    local info = {
        default_output = nil,
        all_outputs = {},
        default_input = nil,
        all_inputs = {}
    }

    -- Output devices
    local output_devices = hs.audiodevice.allOutputDevices()
    for _, device in ipairs(output_devices) do
        local device_info = {
            name = device:name(),
            uid = device:uid(),
            is_default = device == hs.audiodevice.defaultOutputDevice(),
            volume = device:volume(),
            muted = device:outputMuted()
        }
        table.insert(info.all_outputs, device_info)

        if device_info.is_default then
            info.default_output = device_info
        end
    end

    -- Input devices
    local input_devices = hs.audiodevice.allInputDevices()
    for _, device in ipairs(input_devices) do
        local device_info = {
            name = device:name(),
            uid = device:uid(),
            is_default = device == hs.audiodevice.defaultInputDevice(),
            volume = device:inputVolume(),
            muted = device:inputMuted()
        }
        table.insert(info.all_inputs, device_info)

        if device_info.is_default then
            info.default_input = device_info
        end
    end

    return info
end

-- Cycle output devices
function M.cycleOutputDevices()
    local devices = hs.audiodevice.allOutputDevices()
    if #devices < 2 then
        log.d("Not enough output devices to cycle")
        return false
    end

    local current_device = hs.audiodevice.defaultOutputDevice()
    if not current_device then
        log.w("No current output device")
        return false
    end

    -- Find current device index
    local current_index = 0
    for i, device in ipairs(devices) do
        if device == current_device then
            current_index = i
            break
        end
    end

    if current_index == 0 then
        log.w("Current device not found in device list")
        return false
    end

    -- Select next device
    local next_index = current_index % #devices + 1
    local next_device = devices[next_index]

    next_device:setDefaultOutputDevice()
    local deviceName = next_device:name() or "Unknown"
    log.i(string.format("Switched output device to: %s", deviceName))
    notification_utils.announce(MODULE_NAME, "cycle_output", {
        message = string.format("Audio: %s", deviceName),
        duration = 1.0,
        override = true
    })

    return true
end

-- Adjust screen brightness
function M.adjustBrightness(delta)
    local current_brightness = M.getBrightness()
    if current_brightness == nil then
        log.w("Failed to get current brightness")
        return
    end

    local new_brightness = math.max(0, math.min(1, current_brightness + delta))
    M.setBrightness(new_brightness)

    local brightness_percent = math.floor(new_brightness * 100)
    log.i(string.format("Brightness set to %d%%", brightness_percent))
    notification_utils.announce(MODULE_NAME, "brightness", {
        message = string.format("Brightness: %d%%", brightness_percent),
        duration = 0.5,
        override = true
    })
end

-- Get current screen brightness
function M.getBrightness()
    if not brightness or not brightness.get then
        log.w("Brightness API is unavailable")
        return nil
    end

    local ok, current = pcall(brightness.get)
    if not ok then
        log.w(string.format("Failed to get brightness: %s", tostring(current)))
        return nil
    end

    if type(current) ~= "number" then
        log.w("Brightness API returned unexpected value")
        return nil
    end

    return math.max(0, math.min(1, current / 100))
end

-- Set screen brightness
function M.setBrightness(level)
    if not brightness or not brightness.set then
        log.w("Brightness API is unavailable")
        return
    end

    local percent = math.floor(math.max(0, math.min(1, level)) * 100 + 0.5)
    local ok, err = pcall(brightness.set, percent)
    if not ok then
        log.w(string.format("Failed to set brightness: %s", tostring(err)))
    end
end

-- Adjust keyboard backlight
function M.adjustKeyboardBacklight(delta)
    -- This requires additional tools or permissions on macOS
    log.w("Keyboard backlight adjustment not implemented")
    notification_utils.announce(MODULE_NAME, "keyboard_backlight_unavailable", {
        message = "Keyboard backlight not available",
        duration = 1.0,
        override = true
    })
end

-- Get media controls status
function M.getStatus()
    local audio_info = M.getAudioDeviceInfo()
    local brightness = M.getBrightness()

    return {
        output_device = audio_info.default_output and audio_info.default_output.name or "None",
        output_volume = audio_info.default_output and audio_info.default_output.volume or 0,
        output_muted = audio_info.default_output and audio_info.default_output.muted or false,
        input_device = audio_info.default_input and audio_info.default_input.name or "None",
        brightness = brightness,
        media_controls_enabled = true
    }
end

-- Print debugging information
function M.debug()
    local status = M.getStatus()
    local audio_info = M.getAudioDeviceInfo()

    log.i("Media Controls Debug Info:")
    log.i(string.format("  Output device: %s", status.output_device))
    log.i(string.format("  Output volume: %d%%", math.floor(status.output_volume * 100)))
    log.i(string.format("  Output muted: %s", tostring(status.output_muted)))
    log.i(string.format("  Input device: %s", status.input_device))
    local brightness_pct = status.brightness and math.floor(status.brightness * 100) or nil
    log.i(string.format("  Brightness: %s", brightness_pct and (brightness_pct .. "%") or "Unavailable"))
    log.i(string.format("  Media controls enabled: %s", tostring(status.media_controls_enabled)))

    if #audio_info.all_outputs > 1 then
        log.i("  Available output devices:")
        for _, device in ipairs(audio_info.all_outputs) do
            local default_mark = device.is_default and " [Default]" or ""
            log.i(string.format("    %s%s (%d%%, %s)",
                device.name or "Unknown", default_mark,
                math.floor((device.volume or 0) * 100),
                device.muted and "Muted" or "Unmuted"))
        end
    end
end

-- Register module with init system
local init_system = require("core.init_system")
init_system.registerModule("modules.media_controls", {
    init = M.init,
    dependencies = {
        "utils.notification_utils"
    }
})

return M
