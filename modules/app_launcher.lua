-- Application Launcher Module for Hammerspoon
-- Handles application launching, toggling, and management
-- Separated from media controls and mouse bindings for better modularity

local logger = require("core.logger")
local config = require("core.config_loader")
local app_utils = require("utils.app_utils")
local notification_utils = require("utils.notification_utils")

local log = logger.getLogger("app_launcher")

local M = {}

-- Get configuration values
local function getHotkeyConfig(path)
    return config.get("hotkeys." .. path)
end

local function getAppConfig(path)
    return config.get("applications." .. path)
end

-- Initialize application launcher
function M.init()
    log.i("Initializing application launcher module")

    -- Setup application hotkeys
    M.setupAppHotkeys()

    -- Setup application restart hotkeys
    M.setupRestartHotkeys()

    -- Setup protection hotkeys
    M.setupProtectionHotkeys()

    log.i("Application launcher module initialized")
end

-- Setup application launching hotkeys
function M.setupAppHotkeys()
    local launcher_apps = getAppConfig("launcher_apps") or {}
    local launcher_modifier = getHotkeyConfig("launcher.modifier") or {"cmd", "alt"}

    log.i(string.format("Setting up %d application launcher hotkeys", #launcher_apps))

    -- Register toggle app hotkeys
    hs.fnutils.each(launcher_apps, function(entry)
        if entry.key and entry.appname then
            local hotkey_desc = string.format("Launch/Toggle %s", entry.appname)
            hs.hotkey.bind(entry.modifier or launcher_modifier, entry.key, hotkey_desc, function()
                M.launchOrToggleApp(entry.appname, entry.bundleid)
            end)
            log.d(string.format("Registered hotkey: %s+%s -> %s",
                table.concat(entry.modifier or launcher_modifier, "+"),
                entry.key, entry.appname))
        end
    end)
end

-- Setup application restart hotkeys
function M.setupRestartHotkeys()
    local problematic_apps = getAppConfig("problematic_apps") or {}

    log.i(string.format("Setting up %d application restart hotkeys", #problematic_apps))

    hs.fnutils.each(problematic_apps, function(entry)
        if entry.key and entry.appname then
            local hotkey_desc = string.format("Restart %s", entry.appname)
            hs.hotkey.bind(entry.modifier, entry.key, hotkey_desc, function()
                M.restartApp(entry.appname, entry.bundleid)
            end)
            log.d(string.format("Registered restart hotkey: %s+%s -> %s",
                table.concat(entry.modifier, "+"),
                entry.key, entry.appname))
        end
    end)
end

-- Setup protection hotkeys
function M.setupProtectionHotkeys()
    -- Double-press Cmd + Q to Quit protection
    local cmdq_hotkey = getHotkeyConfig("protection.cmd_q") or {"cmd", "q"}
    local protection_delay = 0.5 -- seconds

    local cmdq_state = {
        pressed = false,
        timer = nil
    }

    hs.hotkey.bind(cmdq_hotkey[1], cmdq_hotkey[2], "Protected Quit", function()
        if cmdq_state.pressed then
            -- Second press: Quit the frontmost app
            local app = hs.application.frontmostApplication()
            if app then
                log.i(string.format("Force quitting application: %s", app:name()))
                app:kill()
            end
            cmdq_state.pressed = false
            if cmdq_state.timer then
                cmdq_state.timer:stop()
            end
        else
            -- First press: Set state and start timer
            cmdq_state.pressed = true
            cmdq_state.timer = hs.timer.doAfter(protection_delay, function()
                cmdq_state.pressed = false
            end)
            notification_utils.sendAlert("Press Cmd+Q again to quit", protection_delay)
        end
    end)

    log.i("Setup Cmd+Q protection hotkey")
end

-- Launch or toggle application
function M.launchOrToggleApp(app_name, bundle_id)
    log.i(string.format("Launch/toggle app: %s (%s)", app_name, bundle_id or "unknown"))

    local success = app_utils.toggleApp(app_name, bundle_id)
    if success then
        notification_utils.sendNotification("Applications",
            string.format("%s toggled", app_name), "macos")
    else
        log.w(string.format("Failed to toggle app: %s", app_name))
    end
end

-- Launch application by name or bundle ID
function M.launchApp(identifier)
    log.i(string.format("Launch app: %s", identifier))

    local success = app_utils.focusApp(identifier)
    if success then
        notification_utils.sendNotification("Applications",
            string.format("Launched: %s", identifier), "macos")
    else
        log.w(string.format("Failed to launch app: %s", identifier))
    end
end

-- Restart application
function M.restartApp(app_name, bundle_id)
    log.i(string.format("Restart app: %s (%s)", app_name, bundle_id or "unknown"))

    app_utils.restartApp(app_name, bundle_id)
    notification_utils.sendNotification("Applications",
        string.format("Restarted: %s", app_name), "macos")
end

-- Kill application (force quit)
function M.killApp(identifier, force)
    force = force ~= false -- Default to true

    log.i(string.format("Kill app: %s (force: %s)", identifier, tostring(force)))

    local success = app_utils.killApp(identifier, force)
    if success then
        notification_utils.sendNotification("Applications",
            string.format("Killed: %s", identifier), "macos")
    else
        log.w(string.format("Failed to kill app: %s", identifier))
    end
end

-- Hide application
function M.hideApp(identifier)
    log.i(string.format("Hide app: %s", identifier))

    local app = app_utils.getApp(identifier)
    if app then
        app:hide()
        log.i(string.format("Hidden application: %s", app:name() or identifier))
        return true
    else
        log.w(string.format("Failed to hide app: %s", identifier))
        return false
    end
end

-- Focus application by name or bundle ID
function M.focusApp(identifier)
    log.i(string.format("Focus app: %s", identifier))

    local success = app_utils.focusApp(identifier)
    if success then
        log.i(string.format("Focused application: %s", identifier))
    else
        log.w(string.format("Failed to focus app: %s", identifier))
    end
    return success
end

-- Get list of running applications
function M.listRunningApps()
    log.d("Getting list of running applications")

    local apps = app_utils.listRunningApps()
    log.i(string.format("Found %d running applications", #apps))

    return apps
end

-- Search for application by name
function M.findApp(search_term)
    log.d(string.format("Searching for app: %s", search_term))

    local all_apps = hs.application.runningApplications()
    local found_apps = {}

    for _, app in ipairs(all_apps) do
        if app:kind() == 0 then -- Regular applications
            local app_name = app:name()
            if app_name and app_name:lower():find(search_term:lower()) then
                table.insert(found_apps, {
                    name = app_name,
                    bundle_id = app:bundleID(),
                    hidden = app:isHidden(),
                    frontmost = app:isFrontmost()
                })
            end
        end
    end

    log.i(string.format("Found %d apps matching '%s'", #found_apps, search_term))
    return found_apps
end

-- Cycle through applications
function M.cycleApps(direction, app_filter)
    direction = direction or 1 -- 1 for forward, -1 for backward
    log.d(string.format("Cycling apps (direction: %d)", direction))

    local current_app = hs.application.frontmostApplication()
    if not current_app then
        log.d("No current application for cycling")
        return false
    end

    local all_apps = hs.application.runningApplications()
    local visible_apps = {}

    -- Filter applications
    for _, app in ipairs(all_apps) do
        if app:kind() == 0 and not app:isHidden() then
            if not app_filter or app_filter(app) then
                table.insert(visible_apps, app)
            end
        end
    end

    if #visible_apps < 2 then
        log.d("Not enough applications for cycling")
        return false
    end

    -- Find current app index
    local current_index = 0
    for i, app in ipairs(visible_apps) do
        if app == current_app then
            current_index = i
            break
        end
    end

    if current_index == 0 then
        log.d("Current app not found in visible apps")
        current_index = 1
    end

    -- Calculate next index
    local next_index = current_index + direction
    if next_index > #visible_apps then
        next_index = 1
    elseif next_index < 1 then
        next_index = #visible_apps
    end

    -- Activate next app
    local next_app = visible_apps[next_index]
    if next_app then
        next_app:activate()
        log.i(string.format("Cycled to app: %s", next_app:name() or "Unknown"))
        return true
    end

    return false
end

-- Launch applications from configuration
function M.launchStartupApps()
    local startup_config = getAppConfig("startup") or {}

    if not startup_config.auto_launch then
        log.i("Startup app auto-launch disabled")
        return
    end

    local startup_apps = startup_config.apps or {}
    log.i(string.format("Launching %d startup applications", #startup_apps))

    for _, app_config in ipairs(startup_apps) do
        if app_config.bundleid then
            local delay = app_config.delay or 0
            hs.timer.doAfter(delay, function()
                M.launchApp(app_config.bundleid)
            end)
            log.d(string.format("Scheduled startup app: %s (delay: %ds)", app_config.bundleid, delay))
        end
    end
end

-- Get application launcher status
function M.getStatus()
    local running_apps = M.listRunningApps()
    local focused_app = hs.application.frontmostApplication()

    return {
        running_apps_count = #running_apps,
        focused_app = focused_app and focused_app:name() or "None",
        protection_enabled = true, -- Cmd+Q protection
        startup_apps_configured = getAppConfig("startup.auto_launch") or false
    }
end

-- Print debugging information
function M.debug()
    local status = M.getStatus()
    local running_apps = M.listRunningApps()

    log.i("Application Launcher Debug Info:")
    log.i(string.format("  Running apps: %d", status.running_apps_count))
    log.i(string.format("  Focused app: %s", status.focused_app))
    log.i(string.format("  Protection enabled: %s", tostring(status.protection_enabled)))
    log.i(string.format("  Startup apps configured: %s", tostring(status.startup_apps_configured)))

    if #running_apps > 0 then
        log.i("  Running applications:")
        for _, app in ipairs(running_apps) do
            local status_str = string.format("%s %s %s",
                app.frontmost and "[Front]" or "       ",
                app.hidden and "[Hidden]" or "        ",
                app.name or "Unknown")
            log.i(string.format("    %s", status_str))
        end
    end
end

-- Register module with init system
local init_system = require("core.init_system")
init_system.registerModule("modules.app_launcher", {
    init = M.init,
    dependencies = {
        "utils.app_utils",
        "utils.notification_utils"
    }
})

return M