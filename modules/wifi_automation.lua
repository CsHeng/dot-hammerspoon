-- WiFi Automation Module for Hammerspoon
-- Handles WiFi network change detection and automation

local logger = require("core.logger")
local config = require("core.config_loader")
local notification_utils = require("utils.notification_utils")

local log = logger.getLogger("wifi_automation")

local M = {}

local function formatMessage(template, value)
    if type(template) ~= "string" then
        return tostring(template)
    end

    local ok, result = pcall(string.format, template, value)
    if ok then
        return result
    end

    log.w(string.format("Failed to format WiFi notification message '%s': %s", template, tostring(result)))
    return template
end

-- Global variables
local wifi_watcher = nil
local last_ssid = nil

-- Get configuration values
local function getWiFiConfig(path)
    return config.get("wifi." .. path)
end

-- Initialize WiFi automation
function M.init()
    log.i("Initializing WiFi automation module")

    -- Setup location services workaround if enabled
    M.setupLocationWorkaround()

    -- Setup WiFi watcher
    M.setupWiFiWatcher()

    log.i("WiFi automation module initialized")
end

-- Setup location services workaround
function M.setupLocationWorkaround()
    local use_workaround = getWiFiConfig("behavior.use_location_workaround") or true
    if not use_workaround then
        log.d("Location services workaround disabled")
        return
    end

    if hs.location.servicesEnabled() then
        hs.location.start()
        local location = hs.location.get()
        if location then
            if getWiFiConfig("location.log_location") then
                log.i("Location workaround successful")
                log.i(string.format("  Latitude: %s", tostring(location.latitude)))
                log.i(string.format("  Longitude: %s", tostring(location.longitude)))
            end
        else
            log.w("Location workaround: Unable to retrieve location")
        end
        hs.location.stop()
    else
        log.w("Location services are not enabled - network detection may be limited")
    end
end

-- Setup WiFi watcher
function M.setupWiFiWatcher()
    local monitor_enabled = getWiFiConfig("monitoring.enabled") or true
    if not monitor_enabled then
        log.i("WiFi monitoring disabled")
        return
    end

    wifi_watcher = hs.wifi.watcher.new(M.onSSIDChanged):start()
    last_ssid = hs.wifi.currentNetwork()

    if last_ssid then
        log.d(string.format("WiFi watcher seeded with current network: %s", last_ssid))
    else
        log.d("WiFi watcher seeded with no active network")
    end

    log.i("WiFi watcher started")
end

-- Handle SSID changes
function M.onSSIDChanged()
    local new_ssid = hs.wifi.currentNetwork()
    local notify_changes = getWiFiConfig("behavior.notify_on_change") or true

    -- Handle disconnection
    if not new_ssid then
        local previous_ssid = last_ssid
        local info

        if previous_ssid then
            info = string.format("%s Disconnected", tostring(previous_ssid))
        else
            info = "WiFi Disconnected"
        end

        log.i(info)

        if notify_changes then
            local messages = getWiFiConfig("notifications.messages") or {}
            local message = messages.disconnected or "%s Disconnected"
            local label = previous_ssid or "WiFi"
            notification_utils.sendNotification("WiFi Changed", formatMessage(message, label))
        end

        last_ssid = nil
        return
    end

    -- Skip if no change
    if new_ssid == last_ssid then return end

    local info = string.format("%s Connected", new_ssid)
    log.i(info)

    -- Handle work networks (audio muting)
    if getWiFiConfig("behavior.mute_on_work_networks") then
        M.handleWorkNetwork(new_ssid, info)
    end

    -- Send connection notification
    if notify_changes then
        local messages = getWiFiConfig("notifications.messages") or {}
        local message = messages.connected or "%s Connected"
        notification_utils.sendNotification("WiFi Changed", formatMessage(message, new_ssid))
    end

    last_ssid = new_ssid
end

-- Handle work network behavior
function M.handleWorkNetwork(ssid, info)
    local muted_ssids = getWiFiConfig("muted_ssids") or {}
    local show_notifications = getWiFiConfig("audio.show_notifications") or true

    if muted_ssids[ssid] then
        local builtin_device = notification_utils.getBuiltinOutputDevice()
        if builtin_device then
            -- Mute the device
            builtin_device:setVolume(0)
            builtin_device:setOutputMuted(true)

            local messages = getWiFiConfig("notifications.messages") or {}
            local message = messages.work_mode or "Work Mode: %s, Built-in Audio Muted (%s)"
            local full_info = string.format(message, info, builtin_device:name() or "Unknown")

            log.i(full_info)

            if show_notifications then
                notification_utils.sendNotification("WiFi Changed", full_info)
            end
        else
            local messages = getWiFiConfig("notifications.messages") or {}
            local message = messages.device_not_found or "Work Mode: %s, Built-in Audio Device Not Found"
            local full_info = string.format(message, info)

            log.w(full_info)

            if show_notifications then
                notification_utils.sendNotification("WiFi Changed", full_info)
            end
        end
    else
        -- Optional: unmute when leaving work network
        if getWiFiConfig("behavior.unmute_on_leave") and last_ssid and muted_ssids[last_ssid] then
            local builtin_device = notification_utils.getBuiltinOutputDevice()
            if builtin_device then
                builtin_device:setOutputMuted(false)
                local restore_volume = getWiFiConfig("audio.restore_volume") or 0.5
                builtin_device:setVolume(restore_volume)

                log.i(string.format("Left work network, unmuted built-in audio, volume restored to %d%%", restore_volume * 100))

                if show_notifications then
                    notification_utils.sendNotification("WiFi Changed", "Left work network, audio unmuted")
                end
            end
        end
    end
end

-- Get current network information
function M.getNetworkInfo()
    local current_ssid = hs.wifi.currentNetwork()
    local interfaces = hs.network.interfaces()

    return {
        current_ssid = current_ssid,
        last_ssid = last_ssid,
        interfaces = interfaces,
        wifi_available = hs.wifi.available(),
        location_enabled = hs.location.servicesEnabled()
    }
end

-- Check if current network is a work network
function M.isWorkNetwork()
    local current_ssid = hs.wifi.currentNetwork()
    if not current_ssid then return false end

    local muted_ssids = getWiFiConfig("muted_ssids") or {}
    return muted_ssids[current_ssid] or false
end

-- Get network profile for current network
function M.getCurrentNetworkProfile()
    local current_ssid = hs.wifi.currentNetwork()
    if not current_ssid then return nil end

    local profiles = getWiFiConfig("network_profiles") or {}
    return profiles[current_ssid] or profiles.default
end

-- Manually trigger SSID change check
function M.checkNetworkChange()
    log.i("Manual network change check triggered")
    M.onSSIDChanged()
end

-- Stop WiFi automation
function M.stop()
    if wifi_watcher then
        wifi_watcher:stop()
        wifi_watcher = nil
        log.i("WiFi watcher stopped")
    end
end

-- Restart WiFi automation
function M.restart()
    M.stop()
    M.init()
    log.i("WiFi automation restarted")
end

-- Get WiFi automation status
function M.getStatus()
    local network_info = M.getNetworkInfo()

    return {
        watcher_enabled = wifi_watcher ~= nil,
        current_network = network_info.current_ssid or "Disconnected",
        is_work_network = M.isWorkNetwork(),
        wifi_available = network_info.wifi_available,
        location_enabled = network_info.location_enabled
    }
end

-- Print debugging information
function M.debug()
    local status = M.getStatus()
    local network_info = M.getNetworkInfo()
    local profile = M.getCurrentNetworkProfile()

    log.i("WiFi Automation Debug Info:")
    log.i(string.format("  Watcher enabled: %s", tostring(status.watcher_enabled)))
    log.i(string.format("  Current network: %s", status.current_network))
    log.i(string.format("  Is work network: %s", tostring(status.is_work_network)))
    log.i(string.format("  WiFi available: %s", tostring(status.wifi_available)))
    log.i(string.format("  Location enabled: %s", tostring(status.location_enabled)))
    log.i(string.format("  Network interfaces: %d", #network_info.interfaces))

    if profile then
        log.i("  Current network profile:")
        log.i(string.format("    Status: %s", profile.status or "unknown"))
        if profile.apps and #profile.apps > 0 then
            log.i(string.format("    Apps to launch: %d", #profile.apps))
        end
    end
end

-- Register module with init system
local init_system = require("core.init_system")
init_system.registerModule("modules.wifi_automation", {
    init = M.init,
    dependencies = {
        "utils.notification_utils"
    }
})

return M
