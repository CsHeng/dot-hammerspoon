local log = hs.logger.new("utils", "info")

local M = {}

-- Utility to check if frontmost app is a browser
M.isBrowser = function()
    local app = hs.application.frontmostApplication()
    local bundleIDs = {
        "com.apple.Safari",
        "com.microsoft.edgemac",
        "com.google.Chrome"
    }
    return hs.fnutils.contains(bundleIDs, app:bundleID())
end

M.toggleApp = function(appname, bundleid)
    log.i("toggleApp: " .. tostring(appname) .. " " .. tostring(bundleid))
    -- get app by bundleid
    local app = hs.application.get(bundleid)
    if app then
        if app:isFrontmost() then
            app:hide()
        else
            app:activate()
        end
    else
        hs.application.launchOrFocus(appname)
    end
end

M.restartApp = function(appname, bundleid)
    log.i("restartApp: " .. tostring(appname) .. " " .. tostring(bundleid))
    -- get app by bundleid
    local app = hs.application.get(bundleid)
    if app then
        app:kill()
        hs.timer.doAfter(5, function()
            hs.application.launchOrFocusByBundleID(bundleid)
        end)
    end
end

-- Function to find built-in output device specifically
M.getBuiltinOutputDevice = function()
    local allDevices = hs.audiodevice.allOutputDevices()
    for _, device in ipairs(allDevices) do
        local name = device:name():lower()
        -- Look for built-in speakers/internal speakers
        if name:find("built%-in") or name:find("internal") or name:find("macbook") then
            return device
        end
    end
    -- Fallback: if we can't find built-in, return nil
    return nil
end

-- Function to send a persistent notification
-- Make Sure:
-- 1.	Go to System Settings > Notifications > Hammerspoon
-- 2.	Ensure:
-- •	Notification Style is set to Banners (not Alerts)
-- •	“Show in Notification Center” is enabled
-- •	“Play sound for notifications” is optional
M.sendPersistentNotification = function(title, text)
    -- for keep in notification center.
    hs.notify.register("org.hammerspoon.Hammerspoon")

    local notification = hs.notify.new({
        title = title,
        informativeText = text,
        hasActionButton = false,
        soundName = hs.notify.defaultNotificationSound,
        autoWithdraw = false,  -- Let macOS auto-dismiss it from screen
    })
    notification:send()
    return notification
end

-- Use osascript to send a proper system notification that stays in notification center
M.sendMacOSNotification = function(title, message)
    local script = string.format([[
        display notification "%s" with title "%s"
    ]], message:gsub('"', '\\"'), title:gsub('"', '\\"'))

    local success, output, err = hs.osascript.applescript(script)
    if not success then
        hs.alert.show("Notification failed: " .. tostring(err))
    end
end

return M
