-- Display Layout Module for Hammerspoon
-- Repairs external display ordering + primary display via displayplacer.

local logger = require("core.logger")
local config = require("core.config_loader")
local hotkey_utils = require("utils.hotkey_utils")
local notification_utils = require("utils.notification_utils")

local log = logger.getLogger("display_layout")
local MODULE_NAME = "display_layout"

local M = {}

local screen_watcher = nil
local caffeinate_watcher = nil
local pending_timer = nil
local retry_timer = nil
local attempt_count = 0
local second_external_enabled = true
local second_external_restore_cmd = nil  -- stored before disable; used to re-enable without profile matching

local function getConfig(path, default)
    return config.get("display_layout." .. path, default)
end

local function fileExists(path)
    if type(path) ~= "string" or path == "" then
        return false
    end
    return hs.fs.attributes(path) ~= nil
end

local function resolveDisplayplacerPath()
    local candidates = getConfig("displayplacer.paths", {
        "/opt/homebrew/bin/displayplacer",
        "/usr/local/bin/displayplacer",
    })

    if type(candidates) == "string" then
        candidates = {candidates}
    end

    if type(candidates) ~= "table" then
        log.w("displayplacer.paths config is invalid (not a table)")
        return nil
    end

    for _, path in ipairs(candidates) do
        if fileExists(path) then
            log.d(string.format("Resolved displayplacer path: %s", path))
            return path
        end
    end

    log.w(string.format("displayplacer not found in any candidate path: %s", table.concat(candidates, ", ")))
    return nil
end

local function parsePersistentIds(displayplacerListOutput)
    local ids = {}
    if type(displayplacerListOutput) ~= "string" then
        return ids
    end
    for id in displayplacerListOutput:gmatch("Persistent screen id:%s*([%w%-]+)") do
        ids[#ids + 1] = id
    end
    return ids
end

local function setFromList(list)
    local set = {}
    if type(list) ~= "table" then
        return set
    end
    for _, value in ipairs(list) do
        set[value] = true
    end
    return set
end

local function requiredIdsFromScreens(screens)
    local required = {}
    if type(screens) ~= "table" then
        return required
    end
    for _, screen in ipairs(screens) do
        if type(screen) == "table" and type(screen.id) == "string" and screen.id ~= "" then
            required[#required + 1] = screen.id
        end
    end
    return required
end

local function profileMatches(profile, detectedIds)
    if type(profile) ~= "table" then
        return false
    end

    local require_total_screens = profile.require_total_screens
    if type(require_total_screens) == "number" and require_total_screens > 0 then
        if #detectedIds ~= require_total_screens then
            log.d(string.format("Profile screen count mismatch: required=%d, detected=%d", require_total_screens, #detectedIds))
            return false
        end
    end

    local screens = profile.screens or {}
    local required_ids = profile.required_ids or requiredIdsFromScreens(screens)
    local id_set = setFromList(detectedIds)

    for _, required_id in ipairs(required_ids) do
        if not id_set[required_id] then
            log.d(string.format("Profile missing required screen id: %s", required_id))
            return false
        end
    end

    return true
end

local function normalizeOrigin(origin)
    if type(origin) == "table" then
        local x = origin.x or origin[1]
        local y = origin.y or origin[2]
        if type(x) == "number" and type(y) == "number" then
            return x, y
        end
    end
    return nil, nil
end

local function buildDisplayplacerArg(screen)
    if type(screen) ~= "table" then
        return nil, "invalid screen spec"
    end
    if type(screen.id) ~= "string" or screen.id == "" then
        return nil, "missing screen id"
    end

    local parts = {"id:" .. screen.id}

    if type(screen.res) == "string" and screen.res ~= "" then
        parts[#parts + 1] = "res:" .. screen.res
    end
    if screen.hz ~= nil then
        parts[#parts + 1] = "hz:" .. tostring(screen.hz)
    end
    if screen.color_depth ~= nil then
        parts[#parts + 1] = "color_depth:" .. tostring(screen.color_depth)
    end
    if screen.enabled ~= nil then
        parts[#parts + 1] = "enabled:" .. tostring(screen.enabled)
    end
    if type(screen.scaling) == "string" and screen.scaling ~= "" then
        parts[#parts + 1] = "scaling:" .. screen.scaling
    end

    local x, y = normalizeOrigin(screen.origin)
    if x ~= nil and y ~= nil then
        parts[#parts + 1] = string.format("origin:(%d,%d)", x, y)
    end

    if screen.degree ~= nil then
        parts[#parts + 1] = "degree:" .. tostring(screen.degree)
    end
    if screen.quiet ~= nil then
        parts[#parts + 1] = "quiet:" .. tostring(screen.quiet)
    end

    return string.format("%q", table.concat(parts, " "))
end

local function buildDisplayplacerCommand(displayplacerPath, screens)
    if type(screens) ~= "table" or #screens == 0 then
        return nil, "no screens configured"
    end

    local args = {}
    for _, screen in ipairs(screens) do
        local arg, err = buildDisplayplacerArg(screen)
        if not arg then
            return nil, err
        end
        args[#args + 1] = arg
    end

    return displayplacerPath .. " " .. table.concat(args, " ")
end

local function getProfileOrder(profiles)
    local order = getConfig("profile_order", {"home", "office"})
    if type(order) == "table" and #order > 0 then
        return order
    end

    local keys = {}
    if type(profiles) == "table" then
        for key, _ in pairs(profiles) do
            keys[#keys + 1] = key
        end
    end

    table.sort(keys)
    return keys
end

local function applyMatchingProfile(reason)
    if getConfig("enabled", true) ~= true then
        log.d("display_layout module is disabled")
        return false, "display_layout disabled"
    end

    local profiles = getConfig("profiles", {})
    if type(profiles) ~= "table" then
        log.w("No profiles configured in display_layout.profiles")
        return false, "no profiles configured"
    end

    local displayplacerPath = resolveDisplayplacerPath()
    if not displayplacerPath then
        return false, "displayplacer not found"
    end

    log.d("Running displayplacer list to detect connected screens")
    local listOutput, okList, _, rcList = hs.execute(displayplacerPath .. " list")
    if not okList then
        log.w(string.format("displayplacer list failed (rc=%s): %s", tostring(rcList), tostring(listOutput)))
        return false, "displayplacer list failed"
    end

    local ids = parsePersistentIds(listOutput)
    log.d(string.format("Detected %d screen(s): %s", #ids, table.concat(ids, ", ")))

    local appliedKey = nil
    local appliedProfile = nil

    for _, profileKey in ipairs(getProfileOrder(profiles)) do
        local profile = profiles[profileKey]
        if type(profile) == "table" and profile.enabled ~= false then
            log.d(string.format("Checking profile '%s'...", profileKey))
            if profileMatches(profile, ids) then
                appliedKey = profileKey
                appliedProfile = profile
                log.d(string.format("Profile '%s' matched", profileKey))
                break
            end
        end
    end

    if not appliedKey or not appliedProfile then
        log.d(string.format("No profile matches current %d display(s)", #ids))
        return false, "no profile matches current displays"
    end

    local cmd, err = buildDisplayplacerCommand(displayplacerPath, appliedProfile.screens)
    if not cmd then
        log.e("Failed to build displayplacer command: " .. tostring(err))
        return false, "invalid profile config"
    end

    log.d(string.format("Executing displayplacer command for profile '%s'", appliedKey))
    local output, okApply, _, rcApply = hs.execute(cmd)
    if not okApply then
        log.w(string.format("displayplacer apply failed (rc=%s): %s", tostring(rcApply), tostring(output)))
        return false, "apply failed"
    end

    log.i(string.format("Applied display profile '%s' (reason=%s)", tostring(appliedKey), tostring(reason)))
    return true, appliedKey
end

local function cancelTimers()
    if pending_timer then
        pending_timer:stop()
        pending_timer = nil
    end
    if retry_timer then
        retry_timer:stop()
        retry_timer = nil
    end
end

local function shouldNotify(reason)
    local notifications = getConfig("notifications", {})
    if type(notifications) ~= "table" then
        return reason == "hotkey"
    end
    if reason == "hotkey" then
        return notifications.show_on_hotkey ~= false
    end
    return notifications.show_on_auto_repair == true
end

local function repairDisplayLayout(reason)
    local success, result = applyMatchingProfile(reason)
    if not success then
        local message = tostring(result)
        log.d(string.format("Display repair skipped/failed (reason=%s): %s", tostring(reason), message))
        if shouldNotify(reason) then
            notification_utils.announce(MODULE_NAME, "repair_failed", {
                message = message,
                duration = 1.0,
                override = true
            })
        end
        return false
    end

    local appliedKey = tostring(result)
    -- A full-profile repair implies all screens are enabled again
    second_external_enabled = true
    second_external_restore_cmd = nil
    if shouldNotify(reason) then
        notification_utils.announce(MODULE_NAME, "repair_ok", {
            message = string.format("Display layout repaired (%s)", appliedKey),
            duration = 0.8,
            override = true
        })
    end

    return true
end

local function scheduleRepair(reason)
    cancelTimers()
    attempt_count = 0

    -- Preserve user's explicit disable intent; hotkey (⌃⌘⌥L) overrides and restores everything
    if not second_external_enabled and reason ~= "hotkey" then
        log.d(string.format("scheduleRepair: skipping (second external user-disabled, reason=%s)", reason))
        return
    end

    log.d(string.format("Scheduling repair (reason=%s)", reason))

    local auto = getConfig("auto_repair", {})
    local delay = type(auto) == "table" and auto.delay_seconds or nil
    if type(delay) ~= "number" then
        delay = 2.0
    end
    local retry_interval = type(auto) == "table" and auto.retry_interval_seconds or nil
    if type(retry_interval) ~= "number" then
        retry_interval = 2.0
    end
    local max_attempts = type(auto) == "table" and auto.max_attempts or nil
    if type(max_attempts) ~= "number" then
        max_attempts = 3
    end

    if reason == "hotkey" then
        delay = 0
        max_attempts = 1
    end

    log.d(string.format("Repair config: delay=%.1fs, retry_interval=%.1fs, max_attempts=%d", delay, retry_interval, max_attempts))

    local function attempt()
        attempt_count = attempt_count + 1
        log.d(string.format("Repair attempt %d/%d (reason=%s)", attempt_count, max_attempts, reason))
        if repairDisplayLayout(reason) then
            cancelTimers()
            return
        end
        if attempt_count < max_attempts then
            log.d(string.format("Scheduling retry in %.1fs", retry_interval))
            retry_timer = hs.timer.doAfter(retry_interval, attempt)
        else
            log.d(string.format("Max attempts (%d) reached, giving up", max_attempts))
        end
    end

    pending_timer = hs.timer.doAfter(delay, attempt)
end

-- Finds the current matching profile and builds:
--   restoreCmd: full displayplacer command for extended mode (all screens independent)
--   mirrorCmd:  displayplacer command that mirrors second external onto first external
-- Uses displayplacer "id:<main>+<mirror> ..." syntax for mirroring.
-- The second external is the 2nd non-internal (scaling != "on") screen by x-origin.
local function buildToggleInfo()
    local displayplacerPath = resolveDisplayplacerPath()
    if not displayplacerPath then
        log.w("buildToggleInfo: displayplacer not found")
        return nil, nil
    end

    local listOutput, ok = hs.execute(displayplacerPath .. " list")
    if not ok then
        log.w("buildToggleInfo: displayplacer list failed")
        return nil, nil
    end

    local ids = parsePersistentIds(listOutput)
    local profiles = getConfig("profiles", {})

    local matchedProfile = nil
    for _, profileKey in ipairs(getProfileOrder(profiles)) do
        local profile = profiles[profileKey]
        if type(profile) == "table" and profile.enabled ~= false then
            if profileMatches(profile, ids) then
                matchedProfile = profile
                log.d(string.format("buildToggleInfo: matched profile '%s'", profileKey))
                break
            end
        end
    end

    if not matchedProfile then
        log.d("buildToggleInfo: no profile matched current display topology")
        return nil, nil
    end

    -- Build restore command (full profile, extended mode)
    local restoreCmd, err = buildDisplayplacerCommand(displayplacerPath, matchedProfile.screens)
    if not restoreCmd then
        log.w("buildToggleInfo: failed to build restore command: " .. tostring(err))
        return nil, nil
    end

    -- Sort screens by x-origin, classify into internal / externals
    local screens = {}
    for _, s in ipairs(matchedProfile.screens or {}) do
        screens[#screens + 1] = s
    end
    table.sort(screens, function(a, b)
        local ax = type(a.origin) == "table" and (a.origin.x or a.origin[1] or 0) or 0
        local bx = type(b.origin) == "table" and (b.origin.x or b.origin[1] or 0) or 0
        return ax < bx
    end)

    local firstExternal = nil
    local secondExternal = nil
    local otherScreens = {}
    local externalCount = 0
    for _, s in ipairs(screens) do
        if s.scaling ~= "on" then
            externalCount = externalCount + 1
            if externalCount == 1 then
                firstExternal = s
            elseif externalCount == 2 then
                secondExternal = s
            else
                otherScreens[#otherScreens + 1] = s
            end
        else
            otherScreens[#otherScreens + 1] = s
        end
    end

    if not firstExternal or not secondExternal then
        log.d("buildToggleInfo: fewer than 2 external screens in matched profile")
        return nil, nil
    end

    -- Build mirror command: merge first+second external into one arg via "id:<first>+<second>"
    -- The first ID is the "Optimize for" screen; uses first external's res/origin/etc.
    local mirrorFirst = {}
    for k, v in pairs(firstExternal) do
        mirrorFirst[k] = v
    end
    mirrorFirst.id = firstExternal.id .. "+" .. secondExternal.id

    local mirrorScreens = {}
    for _, s in ipairs(otherScreens) do
        mirrorScreens[#mirrorScreens + 1] = s
    end
    mirrorScreens[#mirrorScreens + 1] = mirrorFirst

    local mirrorCmd, mirrorErr = buildDisplayplacerCommand(displayplacerPath, mirrorScreens)
    if not mirrorCmd then
        log.w("buildToggleInfo: failed to build mirror command: " .. tostring(mirrorErr))
        return nil, nil
    end

    log.d(string.format("buildToggleInfo: firstExternal=%s, secondExternal=%s", firstExternal.id, secondExternal.id))
    return restoreCmd, mirrorCmd
end

local function toggleSecondExternal()
    local displayplacerPath = resolveDisplayplacerPath()
    if not displayplacerPath then
        notification_utils.announce(MODULE_NAME, "toggle_no_tool", {
            message = "displayplacer not found",
            duration = 1.5,
            override = true
        })
        return
    end

    if not second_external_enabled then
        -- Unmirror: restore extended mode via stored restore command.
        log.i("toggleSecondExternal: restoring extended mode")
        if second_external_restore_cmd then
            local output, ok = hs.execute(second_external_restore_cmd)
            if not ok then
                log.w(string.format("toggleSecondExternal: restore failed: %s", tostring(output)))
                notification_utils.announce(MODULE_NAME, "toggle_restore_failed", {
                    message = "Failed to restore extended mode",
                    duration = 1.5,
                    override = true
                })
                return
            end
            second_external_restore_cmd = nil
        else
            -- Fallback after config reload (restore cmd lost); re-apply profile.
            log.w("toggleSecondExternal: no restore cmd stored, falling back to profile repair")
            scheduleRepair("hotkey")
        end
        second_external_enabled = true
        notification_utils.announce(MODULE_NAME, "toggle_extended", {
            message = "Second external: extended",
            duration = 1.0,
            override = true
        })
        return
    end

    -- Mirror second external onto first external.
    local restoreCmd, mirrorCmd = buildToggleInfo()
    if not restoreCmd or not mirrorCmd then
        notification_utils.announce(MODULE_NAME, "toggle_not_found", {
            message = "Second external display not found",
            duration = 1.5,
            override = true
        })
        return
    end

    log.i("toggleSecondExternal: mirroring second external onto first")
    local output, ok = hs.execute(mirrorCmd)
    if ok then
        second_external_restore_cmd = restoreCmd
        second_external_enabled = false
        notification_utils.announce(MODULE_NAME, "toggle_mirrored", {
            message = "Second external: mirrored",
            duration = 1.0,
            override = true
        })
    else
        log.w(string.format("toggleSecondExternal: mirror failed: %s", tostring(output)))
        notification_utils.announce(MODULE_NAME, "toggle_failed", {
            message = "Failed to mirror second external",
            duration = 1.5,
            override = true
        })
    end
end

function M.init()
    log.i("Initializing display layout module")

    local repairHotkey = getConfig("hotkeys.repair_display_layout", {"ctrl", "cmd", "alt", "L"})
    local mods, key = hotkey_utils.parseHotkey(repairHotkey)

    if key then
        hotkey_utils.bind(mods, key, {
            module = MODULE_NAME,
            id = "repair_display_layout",
            description = "Repair display layout",
            toast = false,
            pressed = function()
                log.i("Event: hotkey triggered (repair_display_layout)")
                scheduleRepair("hotkey")
            end
        })
        log.d(string.format("Hotkey bound: %s+%s (repair_display_layout)", table.concat(mods, "+"), key))
    else
        log.w("display_layout.hotkeys.repair_display_layout is invalid; skipping hotkey bind")
    end

    local toggleHotkey = getConfig("hotkeys.toggle_second_external", {"ctrl", "cmd", "alt", "D"})
    local toggleMods, toggleKey = hotkey_utils.parseHotkey(toggleHotkey)

    if toggleKey then
        hotkey_utils.bind(toggleMods, toggleKey, {
            module = MODULE_NAME,
            id = "toggle_second_external",
            description = "Toggle second external display",
            toast = false,
            pressed = function()
                log.i("Event: hotkey triggered (toggle_second_external)")
                toggleSecondExternal()
            end
        })
        log.d(string.format("Hotkey bound: %s+%s (toggle_second_external)", table.concat(toggleMods, "+"), toggleKey))
    else
        log.w("display_layout.hotkeys.toggle_second_external is invalid; skipping hotkey bind")
    end

    local auto = getConfig("auto_repair", {})
    if type(auto) == "table" and auto.enabled == false then
        log.i("Auto repair disabled (display_layout.auto_repair.enabled=false)")
        return
    end

    screen_watcher = hs.screen.watcher.new(function()
        log.i("Event: screen topology changed")
        scheduleRepair("screen_changed")
    end)
    screen_watcher:start()
    log.d("Screen watcher started")

    caffeinate_watcher = hs.caffeinate.watcher.new(function(eventType)
        if eventType == hs.caffeinate.watcher.screensDidWake then
            log.i("Event: screensDidWake")
            scheduleRepair("wake")
        elseif eventType == hs.caffeinate.watcher.systemDidWake then
            log.i("Event: systemDidWake")
            scheduleRepair("wake")
        elseif eventType == hs.caffeinate.watcher.sessionDidBecomeActive then
            log.i("Event: sessionDidBecomeActive")
            scheduleRepair("wake")
        elseif eventType == hs.caffeinate.watcher.screensDidUnlock then
            log.i("Event: screensDidUnlock")
            scheduleRepair("wake")
        end
    end)
    caffeinate_watcher:start()
    log.d("Caffeinate watcher started")

    -- Initial best-effort repair after startup.
    log.i("Event: startup")
    scheduleRepair("startup")

    log.i("Display layout module initialized")
end

-- Register module with init system
local init_system = require("core.init_system")
init_system.registerModule("modules.display_layout", {
    init = M.init,
    dependencies = {
        "utils.notification_utils",
    }
})

return M
