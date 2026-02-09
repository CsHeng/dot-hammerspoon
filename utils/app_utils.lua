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

local function appLabel(app)
    if not app then
        return "nil"
    end
    return string.format("%s(%s)", tostring(app:name()), tostring(app:bundleID()))
end

local function bringWindowToFront(win)
    if not win then
        return
    end

    if win:isMinimized() then
        win:unminimize()
    end

    win:focus()
    win:raise()
end

local function activateAppRobust(app)
    if not app then
        return false
    end

    if app:isHidden() then
        app:unhide()
    end

    local win = app:focusedWindow() or app:mainWindow()
    bringWindowToFront(win)
    app:activate(true)
    bringWindowToFront(app:focusedWindow() or app:mainWindow())

    if not app:isFrontmost() then
        return false
    end

    return true
end

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

    local app = (bundle_id and hs.application.get(bundle_id)) or hs.application.get(app_name)
    if app then
        -- Application is running
        local active_win = app:focusedWindow() or app:mainWindow()
        local should_hide = app:isFrontmost() and not app:isHidden() and active_win and not active_win:isMinimized()
        if should_hide then
            -- Hide the application
            app:hide()
            log.d(string.format("Hid running application: %s", app_name))
            return {success = true, action = "hide", running = true}
        else
            -- Bring to front
            local success = activateAppRobust(app)
            log.d(string.format("Activated running application robustly: %s", app_name))
            return {success = success, action = "activate", running = true}
        end
    else
        -- Application not running, launch it
        local success
        if bundle_id and bundle_id ~= "" then
            success = hs.application.launchOrFocusByBundleID(bundle_id)
        else
            success = hs.application.launchOrFocus(app_name)
        end
        log.d(string.format("Launched new application process: %s (success: %s)", app_name, tostring(success)))
        return {success = success, action = "launch", running = false}
    end
end

-- Restart an application
function M.restartApp(app_name, bundle_id, restart_delay)
    restart_delay = restart_delay or 0
    log.i(string.format("restartApp: %s %s (delay: %ds)", tostring(app_name), tostring(bundle_id), restart_delay))

    local app = bundle_id and hs.application.get(bundle_id) or hs.application.get(app_name)

    local function doLaunch()
        if bundle_id then
            hs.application.launchOrFocusByBundleID(bundle_id)
        else
            hs.application.launchOrFocus(app_name)
        end
        log.i(string.format("Launched %s after restart", app_name))
    end

    if app then
        log.i(string.format("Killing %s before restart", app:name() or app_name))
        app:kill()
        if restart_delay > 0 then
            hs.timer.doAfter(restart_delay, doLaunch)
        else
            doLaunch()
        end
    else
        log.i(string.format("%s not running, launching directly", app_name))
        doLaunch()
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
    if type(identifier) == "string" and identifier ~= "" then
        return hs.appfinder.appFromName(identifier)
    end

    return nil
end

-- Focus application by name or bundle ID
function M.focusApp(identifier)
    local app = M.getApp(identifier)
    if app then
        return activateAppRobust(app)
    end

    local success = hs.application.launchOrFocus(identifier)
    if not success and type(identifier) == "string" and identifier:find("%.") then
        success = hs.application.launchOrFocusByBundleID(identifier)
    end

    if not success then
        log.w(string.format("Application not found: %s", identifier))
    end
    return success
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
