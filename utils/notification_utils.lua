-- Provides functions for system notifications

local logger = require("core.logger")
local config = require("core.config_loader")
local log = logger.getLogger("notification_utils")

local M = {}

local function escapeForJavascript(str)
    str = str or ""
    str = tostring(str)
    str = str:gsub("\\", "\\\\")
    str = str:gsub("\"", "\\\"")
    str = str:gsub("\n", "\\n")
    str = str:gsub("\r", "\\r")
    str = str:gsub("\t", "\\t")
    return str
end

-- ---------------------------------------------------------------------------
-- Announcement resolution helpers
-- ---------------------------------------------------------------------------

local DEFAULT_ANNOUNCEMENT = {
    enabled = true,
    channel = "alert",
    duration = 1.2
}

local function shallowCopy(tbl)
    local copy = {}
    for k, v in pairs(tbl) do
        copy[k] = v
    end
    return copy
end

local function normalizeAnnouncementLayer(value)
    if value == nil then
        return nil
    end

    local valueType = type(value)
    if valueType == "boolean" then
        return value and {enabled = true} or {enabled = false}
    elseif valueType == "number" then
        return {enabled = true, duration = value}
    elseif valueType == "string" then
        return {enabled = true, channel = value}
    elseif valueType == "table" then
        local layer = shallowCopy(value)
        if layer.enabled == nil then
            layer.enabled = true
        end
        return layer
    end

    return nil
end

local function mergeAnnouncementLayers(base, layer)
    if not layer or layer.enabled == false then
        return nil
    end

    local result = base and shallowCopy(base) or shallowCopy(DEFAULT_ANNOUNCEMENT)
    for key, value in pairs(layer) do
        if key ~= "enabled" then
            result[key] = value
        end
    end
    result.enabled = true
    return result
end

local function resolveAnnouncementConfig(moduleName, eventId, overrideSpec)
    local announcementConfig = config.get("hotkeys_announcements", {})
    if type(announcementConfig) ~= "table" then
        announcementConfig = {}
    end

    local defaultLayer = normalizeAnnouncementLayer(announcementConfig.default)
    local moduleLayer = nil
    if moduleName and type(announcementConfig.modules) == "table" then
        moduleLayer = normalizeAnnouncementLayer(announcementConfig.modules[moduleName])
    end

    local bindingLayer = nil
    if type(announcementConfig.bindings) == "table" then
        if moduleName and eventId then
            bindingLayer = normalizeAnnouncementLayer(
                announcementConfig.bindings[string.format("%s.%s", moduleName, eventId)]
            )
        end
        if not bindingLayer and eventId then
            bindingLayer = normalizeAnnouncementLayer(announcementConfig.bindings[eventId])
        end
    end

    local result = nil
    local disabled = false

    local function applyLayer(layer, terminal)
        if disabled or not layer then
            return
        end

        if layer.enabled == false then
            result = nil
            if terminal then
                disabled = true
            end
            return
        end

        result = mergeAnnouncementLayers(result, layer)
    end

    applyLayer(defaultLayer, false)
    applyLayer(moduleLayer, false)
    applyLayer(bindingLayer, true)

    if disabled then
        return nil
    end

    local overrideLayer = normalizeAnnouncementLayer(overrideSpec)
    if overrideLayer then
        if overrideLayer.enabled == false then
            return nil
        end
        result = mergeAnnouncementLayers(result, overrideLayer)
    end

    return result
end

local function computeAnnouncementPayload(moduleName, eventId, payload)
    payload = payload or {}

    local override = payload.override

    local announcement = resolveAnnouncementConfig(moduleName, eventId, override)
    if not announcement or announcement.enabled == false then
        return nil
    end

    local message = payload.message

    if type(payload.message_fn) == "function" then
        local ok, generated = pcall(payload.message_fn, payload)
        if ok and generated and generated ~= "" then
            message = generated
        elseif not ok then
            log.w(string.format("Announcement message_fn failed for %s.%s: %s",
                tostring(moduleName), tostring(eventId), tostring(generated)))
        end
    end

    if not message or message == "" then
        local configuredMessage = announcement.message or payload.configured_message
        if type(configuredMessage) == "string" then
            if type(payload.message_args) == "table" and #payload.message_args > 0 then
                local ok, formatted = pcall(string.format, configuredMessage, table.unpack(payload.message_args))
                if ok then
                    message = formatted
                else
                    log.w(string.format("Failed to format announcement message for %s.%s: %s",
                        tostring(moduleName), tostring(eventId), tostring(formatted)))
                end
            else
                message = configuredMessage
            end
        elseif type(configuredMessage) == "function" then
            local ok, generated = pcall(configuredMessage, payload)
            if ok and generated and generated ~= "" then
                message = generated
            end
        end
    end

    if (not message or message == "") and payload.default_message then
        message = payload.default_message
    end

    if not message or message == "" then
        return nil
    end

    local channel = payload.channel or announcement.channel or payload.preferred_channel or DEFAULT_ANNOUNCEMENT.channel
    local duration = payload.duration or announcement.duration or payload.preferred_duration or DEFAULT_ANNOUNCEMENT.duration
    local alertStyle = payload.alert_style or announcement.alert_style or payload.preferred_alert_style
    local title = payload.title or announcement.title or payload.preferred_title

    local finalPayload = {
        channel = channel or "alert",
        duration = duration,
        alert_style = alertStyle,
        title = title,
        message = message,
        metadata = payload.metadata
    }

    return finalPayload
end

function M.shouldAnnounce(moduleName, eventId, overrideSpec)
    local resolved = resolveAnnouncementConfig(moduleName, eventId, overrideSpec)
    return resolved ~= nil
end

function M.announce(moduleName, eventId, payload)
    local finalPayload = computeAnnouncementPayload(moduleName, eventId, payload)
    if not finalPayload then
        return false
    end

    local channel = string.lower(tostring(finalPayload.channel or "alert"))
    local message = tostring(finalPayload.message)
    local duration = tonumber(finalPayload.duration) or DEFAULT_ANNOUNCEMENT.duration

    if channel == "alert" or channel == "toast" then
        local style = finalPayload.alert_style
        if type(style) == "table" then
            hs.alert.show(message, style, duration)
        else
            hs.alert.show(message, duration)
        end
        log.d(string.format("Alert announcement displayed (%s.%s): %s",
            tostring(moduleName), tostring(eventId), message))
        return true
    elseif channel == "persistent" then
        local title = finalPayload.title or moduleName or "Notification"
        local notification = M.sendPersistentNotification(title, message)
        return notification ~= nil
    elseif channel == "macos" or channel == "notification" then
        local title = finalPayload.title or moduleName or "Notification"
        return M.sendMacOSNotification(title, message)
    else
        log.w(string.format("Unknown announcement channel '%s' for %s.%s",
            tostring(channel), tostring(moduleName), tostring(eventId)))
    end

    return false
end

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
        withdrawAfter = 0,
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
    title = title or ""
    message = message or ""

    log.d(string.format("Sending macOS notification (JXA): %s - %s", title, message))

    local script = string.format([[
        var app = Application.currentApplication();
        app.includeStandardAdditions = true;
        app.displayNotification("%s", {withTitle: "%s"});
    ]], escapeForJavascript(message), escapeForJavascript(title))

    local success, _, err = hs.osascript.javascript(script)

    if not success then
        log.e(string.format("Failed to send macOS notification: %s", tostring(err)))
    else
        log.i("macOS notification sent successfully")
    end

    return success
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
function M.sendAlert(message, duration, opts)
    opts = opts or {}
    opts.message = message
    opts.duration = duration or opts.duration
    opts.channel = "alert"
    opts.module = opts.module or "global"
    opts.id = opts.id or "alert"
    return M.announce(opts.module, opts.id, opts)
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
