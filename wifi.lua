local utils = require("utils")
local log = hs.logger.new("wifi", "info")

-- workaround for network nil(will request location permission)
if hs.location.servicesEnabled() then
    hs.location.start()
    local location = hs.location.get()
    if location then
        log.i("Current Location:")
        log.i("Latitude: " .. location.latitude)
        log.i("Longitude: " .. location.longitude)
        log.i("Altitude: " .. location.altitude)
        log.i("Horizontal Accuracy: " .. location.horizontalAccuracy)
        log.i("Vertical Accuracy: " .. location.verticalAccuracy)
    else
        log.i("Unable to retrieve location information.")
    end
    hs.location.stop()
else
    log.i("Location services are not enabled.")
end

local mutedSSIDs = {
    ["Jiatu"] = true,
    ["Jiatu-Legacy"] = true,
    ["Shanqu"] = true,
}

local lastSSID = nil

local function onSSIDChanged()
    local newSSID = hs.wifi.currentNetwork()

    local info = nil
    -- Handle disconnection
    if lastSSID and not newSSID then
        info = string.format("%s Disconnected", tostring(lastSSID))
        log.i(info)
        utils.sendMacOSNotification("WiFi Changed", info)
        lastSSID = nil
        return
    end

    -- Skip if no change
    if newSSID == lastSSID then return end

    info = string.format("%s Connected", newSSID)
    log.i(info)

    -- Mute built-in audio for work networks
    if mutedSSIDs[newSSID] then
        local builtinDevice = utils.getBuiltinOutputDevice()
        if builtinDevice then
            builtinDevice:setVolume(0)
            builtinDevice:setOutputMuted(true)
            info = string.format("Work Mode: %s, Built-in Audio Muted (%s)", info, builtinDevice:name())
        else
            info = string.format("Work Mode: %s, Built-in Audio Device Not Found", info)
        end
    end

    utils.sendMacOSNotification("WiFi Changed", info)
    lastSSID = newSSID
end

wifiWatcher = hs.wifi.watcher.new(onSSIDChanged):start()