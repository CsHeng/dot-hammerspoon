-- Notification utilities for Hammerspoon
-- Provides functions for system notifications

local logger = require("core.logger")
local log = logger.getLogger("notification_utils")

local M = {}

-- Function to find built-in output device specifically
function M.getBuiltinOutputDevice()
    local all_devices = hs.audiodevice.allOutputDevices()
    for _, device in ipairs(all_devices) do
        local name = device:name()
        if name then
            local lower_name = name:lower()
            -- Look for built-in speakers/internal speakers
            if lower_name:find("built%-in") or lower_name:find("internal") or lower_name:find("macbook") then
                return device
            end
        end
    end
    -- Fallback: if we can't find built-in, return nil
    return nil
end

-- Function to send a persistent notification using hs.notify
-- Make Sure:
-- 1. Go to System Settings > Notifications > Hammerspoon
-- 2. Ensure:
-- • Notification Style is set to Banners (not Alerts)
-- • "Show in Notification Center" is enabled
-- • "Play sound for notifications" is optional
function M.sendPersistentNotification(title, text)
    log.d(string.format("Sending persistent notification: %s - %s", title, text))

    -- Register for notification center
    hs.notify.register("org.hammerspoon.Hammerspoon")

    local notification = hs.notify.new({
        title = title,
        informativeText = text,
        hasActionButton = false,
        soundName = hs.notify.defaultNotificationSound,
        autoWithdraw = false, -- Let macOS auto-dismiss it from screen
    })

    local success = notification:send()
    if success then
        log.i("Persistent notification sent successfully")
        return notification
    else
        log.e("Failed to send persistent notification")
        return nil
    end
end

-- Use osascript to send a proper system notification that stays in notification center
function M.sendMacOSNotification(title, message)
    log.d(string.format("Sending macOS notification: %s - %s", title, message))

    -- Escape quotes in title and message
    local escaped_title = title:gsub('"', '\\"')
    local escaped_message = message:gsub('"', '\\"')

    local script = string.format([[
        display notification "%s" with title "%s"
    ]], escaped_message, escaped_title)

    local success, output, err = hs.osascript.applescript(script)

    if success then
        log.i("macOS notification sent successfully")
        return true
    else
        log.e(string.format("Failed to send macOS notification: %s", tostring(err)))
        return false
    end
end

-- Send notification with fallback mechanism
function M.sendNotification(title, message, method)
    method = method or "auto"

    if method == "persistent" then
        return M.sendPersistentNotification(title, message)
    elseif method == "macos" then
        return M.sendMacOSNotification(title, message)
    elseif method == "auto" then
        -- Try macOS notification first, fallback to persistent
        local success = M.sendMacOSNotification(title, message)
        if not success then
            log.w("macOS notification failed, trying persistent notification")
            return M.sendPersistentNotification(title, message)
        end
        return success
    else
        log.w(string.format("Unknown notification method: %s", method))
        return false
    end
end

-- Simple alert notification (disappears quickly)
function M.sendAlert(message, duration)
    duration = duration or 2
    hs.alert.show(message, duration)
    log.d(string.format("Alert sent: %s (duration: %.1fs)", message, duration))
end

-- Audio control with notification
function M.setAudioVolume(device, volume, mute)
    if not device then
        log.e("No audio device provided")
        return false
    end

    local device_name = device:name() or "Unknown"
    local actions = {}

    if volume ~= nil then
        device:setVolume(volume)
        table.insert(actions, string.format("volume %d%%", math.floor(volume * 100)))
    end

    if mute ~= nil then
        device:setOutputMuted(mute)
        table.insert(actions, mute and "muted" or "unmuted")
    end

    if #actions > 0 then
        local action_str = table.concat(actions, ", ")
        log.i(string.format("Audio device '%s': %s", device_name, action_str))
        M.sendNotification("Audio", string.format("%s: %s", device_name, action_str))
    end

    return true
end

-- Toggle mute for built-in audio
function M.toggleBuiltinAudioMute()
    local builtin_device = M.getBuiltinOutputDevice()
    if builtin_device then
        local current_mute = builtin_device:outputMuted()
        M.setAudioVolume(builtin_device, nil, not current_mute)
        return true
    else
        log.w("Built-in audio device not found")
        M.sendNotification("Audio", "Built-in audio device not found")
        return false
    end
end

-- Get audio device information
function M.getAudioDeviceInfo()
    local info = {
        output_devices = {},
        input_devices = {},
        builtin_output = nil,
        default_output = nil,
        default_input = nil
    }

    -- Get output devices
    local output_devices = hs.audiodevice.allOutputDevices()
    for _, device in ipairs(output_devices) do
        local device_info = {
            name = device:name(),
            uid = device:uid(),
            is_builtin = M.getBuiltinOutputDevice() == device,
            is_default = device == hs.audiodevice.defaultOutputDevice(),
            volume = device:volume(),
            muted = device:outputMuted()
        }
        table.insert(info.output_devices, device_info)

        if device_info.is_builtin then
            info.builtin_output = device_info
        end
        if device_info.is_default then
            info.default_output = device_info
        end
    end

    -- Get input devices
    local input_devices = hs.audiodevice.allInputDevices()
    for _, device in ipairs(input_devices) do
        local device_info = {
            name = device:name(),
            uid = device:uid(),
            is_default = device == hs.audiodevice.defaultInputDevice(),
            volume = device:inputVolume(),
            muted = device:inputMuted()
        }
        table.insert(info.input_devices, device_info)

        if device_info.is_default then
            info.default_input = device_info
        end
    end

    return info
end

return M