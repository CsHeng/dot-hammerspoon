-- Application utilities for Hammerspoon
-- Provides functions for application management and detection

local logger = require("core.logger")
local log = logger.getLogger("app_utils")

local M = {}

-- Browser bundle IDs for detection
local browser_bundle_ids = {
    "com.apple.Safari",
    "com.microsoft.edgemac",
    "com.google.Chrome"
}

-- Check if frontmost app is a browser
function M.isBrowser()
    local app = hs.application.frontmostApplication()
    if not app then
        return false
    end

    local bundle_id = app:bundleID()
    return bundle_id and hs.fnutils.contains(browser_bundle_ids, bundle_id)
end

-- Toggle application visibility
function M.toggleApp(app_name, bundle_id)
    log.i(string.format("toggleApp: %s %s", tostring(app_name), tostring(bundle_id)))

    local app = hs.application.get(bundle_id)
    if app then
        -- Application is running
        if app:isFrontmost() then
            -- Hide the application
            app:hide()
            log.d(string.format("Hid running application: %s", app_name))
            return {success = true, action = "hide", running = true}
        else
            -- Bring to front
            app:activate()
            log.d(string.format("Activated running application: %s", app_name))
            return {success = true, action = "activate", running = true}
        end
    else
        -- Application not running, launch it
        local success = hs.application.launchOrFocus(app_name)
        log.d(string.format("Launched new application process: %s (success: %s)", app_name, tostring(success)))
        return {success = success, action = "launch", running = false}
    end
end

-- Restart an application
function M.restartApp(app_name, bundle_id)
    log.i(string.format("restartApp: %s %s", tostring(app_name), tostring(bundle_id)))

    local app = hs.application.get(bundle_id)
    if app then
        app:kill()
        hs.timer.doAfter(5, function()
            hs.application.launchOrFocusByBundleID(bundle_id)
        end)
    end
end

-- Get application by name or bundle ID
function M.getApp(identifier)
    -- First try as bundle ID
    local app = hs.application.get(identifier)
    if app then
        return app
    end

    -- Then try as app name
    return hs.application.get(identifier)
end

-- Focus application by name or bundle ID
function M.focusApp(identifier)
    local app = M.getApp(identifier)
    if app then
        app:activate()
        return true
    end

    log.w(string.format("Application not found: %s", identifier))
    return false
end

-- List all running applications
function M.listRunningApps()
    local apps = hs.application.runningApplications()
    local app_list = {}

    for _, app in ipairs(apps) do
        if app:kind() == 0 then -- Regular applications
            table.insert(app_list, {
                name = app:name(),
                bundle_id = app:bundleID(),
                hidden = app:isHidden(),
                frontmost = app:isFrontmost()
            })
        end
    end

    return app_list
end

-- Kill application by name or bundle ID
function M.killApp(identifier, force)
    local app = M.getApp(identifier)
    if app then
        if force then
            app:kill9()
        else
            app:kill()
        end
        log.i(string.format("Killed application: %s", identifier))
        return true
    end

    log.w(string.format("Application not found: %s", identifier))
    return false
end

return M