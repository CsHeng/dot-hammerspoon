-- Display Layout Module for Hammerspoon
-- Repairs external display ordering + primary display via displayplacer.
-- Office second-external input toggle uses m1ddc because displayplacer cannot
-- reliably soft-disable/enable a display.

local logger = require("core.logger")
local config = require("core.config_loader")
local hotkey_utils = require("utils.hotkey_utils")
local notification_utils = require("utils.notification_utils")

local log = logger.getLogger("display_layout")
local MODULE_NAME = "display_layout"
local SECOND_EXTERNAL_STATE_KEY = "display_layout.second_external_toggle_state"

local OFFICE_PROFILE_KEYS = {
    office = true,
    office_open = true,
    office_typec = true,
    office_typec_open = true,
}

local TOGGLE_PROFILE_KEYS = {
    home = true,
    home_open = true,
    office = true,
    office_open = true,
    office_typec = true,
    office_typec_open = true,
}

local M = {}

local screen_watcher = nil
local caffeinate_watcher = nil
local pending_timer = nil
local retry_timer = nil
local attempt_count = 0
local second_external_state = {
    on_mac_input = true,
    uuid = nil,
    command = "input",
    mac_input = nil,
    alt_input = nil,
    mac_label = "DisplayPort 1",
    alt_label = "HDMI 1",
    reconnect_delay_seconds = 2.0,
}

local function getConfig(path, default)
    return config.get("display_layout." .. path, default)
end

local function notify(key, message, duration)
    notification_utils.announce(MODULE_NAME, key, {
        message = message,
        duration = duration or 1.0,
        override = true
    })
end

local function fileExists(path)
    if type(path) ~= "string" or path == "" then
        return false
    end
    return hs.fs.attributes(path) ~= nil
end

local function resolveToolPath(configPath, defaultCandidates, label)
    local candidates = getConfig(configPath, defaultCandidates)

    if type(candidates) == "string" then
        candidates = {candidates}
    end

    if type(candidates) ~= "table" then
        log.w(string.format("%s config is invalid (not a table): %s", label, configPath))
        return nil
    end

    for _, path in ipairs(candidates) do
        if fileExists(path) then
            log.d(string.format("Resolved %s path: %s", label, path))
            return path
        end
    end

    log.w(string.format("%s not found in any candidate path: %s", label, table.concat(candidates, ", ")))
    return nil
end

local function resolveDisplayplacerPath()
    return resolveToolPath("displayplacer.paths", {
        "/opt/homebrew/bin/displayplacer",
        "/usr/local/bin/displayplacer",
    }, "displayplacer")
end

local function resolveM1ddcPath()
    return resolveToolPath("m1ddc.paths", {
        "/opt/homebrew/bin/m1ddc",
        "/usr/local/bin/m1ddc",
    }, "m1ddc")
end

local function normalizeSecondExternalState(state)
    local normalized = {}

    normalized.on_mac_input = state.on_mac_input ~= false
    normalized.profile_key = type(state.profile_key) == "string" and state.profile_key or nil
    normalized.uuid = type(state.uuid) == "string" and state.uuid or nil
    normalized.command = state.command == "input-alt" and "input-alt" or "input"
    normalized.mac_input = type(state.mac_input) == "number" and state.mac_input or nil
    normalized.alt_input = type(state.alt_input) == "number" and state.alt_input or nil
    normalized.mac_label = type(state.mac_label) == "string" and state.mac_label or "DisplayPort 1"
    normalized.alt_label = type(state.alt_label) == "string" and state.alt_label or "HDMI 1"
    normalized.reconnect_delay_seconds = type(state.reconnect_delay_seconds) == "number" and state.reconnect_delay_seconds or 2.0

    return normalized
end

local function saveSecondExternalState()
    hs.settings.set(SECOND_EXTERNAL_STATE_KEY, second_external_state)
end

local function loadSecondExternalState()
    local saved = hs.settings.get(SECOND_EXTERNAL_STATE_KEY)
    if type(saved) == "table" then
        second_external_state = normalizeSecondExternalState(saved)
    else
        second_external_state = normalizeSecondExternalState(second_external_state)
    end
end

local function updateSecondExternalState(spec, on_mac_input)
    second_external_state = normalizeSecondExternalState({
        on_mac_input = on_mac_input,
        profile_key = spec.profile_key,
        uuid = spec.uuid,
        command = spec.command,
        mac_input = spec.mac_input,
        alt_input = spec.alt_input,
        mac_label = spec.mac_label,
        alt_label = spec.alt_label,
        reconnect_delay_seconds = spec.reconnect_delay_seconds,
    })
    saveSecondExternalState()
end

local function markSecondExternalOnMacInput(on_mac_input)
    second_external_state.on_mac_input = on_mac_input == true
    saveSecondExternalState()
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

local function findMatchingProfile(profileFilter)
    local profiles = getConfig("profiles", {})
    if type(profiles) ~= "table" then
        log.w("No profiles configured in display_layout.profiles")
        return nil, "no profiles configured"
    end

    local displayplacerPath = resolveDisplayplacerPath()
    if not displayplacerPath then
        return nil, "displayplacer not found"
    end

    log.d("Running displayplacer list to detect connected screens")
    local listOutput, okList, _, rcList = hs.execute(displayplacerPath .. " list")
    if not okList then
        log.w(string.format("displayplacer list failed (rc=%s): %s", tostring(rcList), tostring(listOutput)))
        return nil, "displayplacer list failed"
    end

    local ids = parsePersistentIds(listOutput)
    log.d(string.format("Detected %d screen(s): %s", #ids, table.concat(ids, ", ")))

    for _, profileKey in ipairs(getProfileOrder(profiles)) do
        local profile = profiles[profileKey]
        local filterMatches = profileFilter == nil or profileFilter[profileKey] == true
        if filterMatches and type(profile) == "table" and profile.enabled ~= false then
            log.d(string.format("Checking profile '%s'...", profileKey))
            if profileMatches(profile, ids) then
                log.d(string.format("Profile '%s' matched", profileKey))
                return {
                    key = profileKey,
                    profile = profile,
                    displayplacer_path = displayplacerPath,
                }
            end
        end
    end

    log.d(string.format("No profile matches current %d display(s)", #ids))
    return nil, "no profile matches current displays"
end

-- Classify profile screens into externals and others (internals), sorted by x-origin.
local function classifyScreens(profile)
    local screens = {}
    for _, screen in ipairs(profile.screens or {}) do
        screens[#screens + 1] = screen
    end

    table.sort(screens, function(a, b)
        local ax = type(a.origin) == "table" and (a.origin.x or a.origin[1] or 0) or 0
        local bx = type(b.origin) == "table" and (b.origin.x or b.origin[1] or 0) or 0
        return ax < bx
    end)

    local externals = {}
    local others = {}
    for _, screen in ipairs(screens) do
        if screen.scaling ~= "on" then
            externals[#externals + 1] = screen
        else
            others[#others + 1] = screen
        end
    end

    return externals, others
end

local function getToggleConfig(profileKey)
    local configPath = OFFICE_PROFILE_KEYS[profileKey]
        and "m1ddc.office_second_external_input_toggle"
        or "m1ddc.home_second_external_input_toggle"

    local toggleConfig = getConfig(configPath, {})
    if type(toggleConfig) ~= "table" then
        toggleConfig = {}
    end
    return toggleConfig
end

local function buildToggleSpec()
    local matched, err = findMatchingProfile(TOGGLE_PROFILE_KEYS)
    if not matched then
        return nil, err
    end

    local externals = classifyScreens(matched.profile)
    if #externals < 2 then
        return nil, "second external display not found"
    end

    local toggleConfig = getToggleConfig(matched.key)
    return {
        profile_key = matched.key,
        profile = matched.profile,
        displayplacer_path = matched.displayplacer_path,
        uuid = externals[2].id,
        command = toggleConfig.command == "input-alt" and "input-alt" or "input",
        mac_input = type(toggleConfig.mac_input) == "number" and toggleConfig.mac_input or 15,
        alt_input = type(toggleConfig.alt_input) == "number" and toggleConfig.alt_input or 17,
        mac_label = type(toggleConfig.mac_label) == "string" and toggleConfig.mac_label or "DisplayPort 1",
        alt_label = type(toggleConfig.alt_label) == "string" and toggleConfig.alt_label or "HDMI 1",
        reconnect_delay_seconds = type(toggleConfig.reconnect_delay_seconds) == "number" and toggleConfig.reconnect_delay_seconds or 2.0,
    }
end

local function runM1ddcSetInput(m1ddcPath, spec, inputValue)
    local cmd = string.format("%q display %q set %s %d", m1ddcPath, spec.uuid, spec.command, inputValue)
    local output, ok, _, rc = hs.execute(cmd)
    if not ok then
        log.w(string.format("m1ddc set input failed (rc=%s): %s", tostring(rc), tostring(output)))
        return false, tostring(output) ~= "" and tostring(output) or "m1ddc set input failed"
    end

    return true, tostring(output)
end

-- Mirror second external onto first external via displayplacer "id:<first>+<second>" syntax.
-- This collapses the desktop boundary so the phantom screen area is eliminated.
local function applyMirrorMode(displayplacerPath, profile)
    local externals, others = classifyScreens(profile)
    if #externals < 2 then
        log.w("applyMirrorMode: fewer than 2 external screens")
        return false
    end

    local first = externals[1]
    local second = externals[2]

    -- Build mirror pair: id:<first>+<second> uses first's display properties
    local mirrorScreen = {}
    for k, v in pairs(first) do
        mirrorScreen[k] = v
    end
    mirrorScreen.id = first.id .. "+" .. second.id

    local mirrorScreens = {}
    for _, s in ipairs(others) do
        mirrorScreens[#mirrorScreens + 1] = s
    end
    mirrorScreens[#mirrorScreens + 1] = mirrorScreen

    local cmd, buildErr = buildDisplayplacerCommand(displayplacerPath, mirrorScreens)
    if not cmd then
        log.w("applyMirrorMode: failed to build command: " .. tostring(buildErr))
        return false
    end

    log.d(string.format("Applying mirror mode: %s mirrors %s", second.id, first.id))
    local output, ok, _, rc = hs.execute(cmd)
    if not ok then
        log.w(string.format("applyMirrorMode: displayplacer failed (rc=%s): %s", tostring(rc), tostring(output)))
        return false
    end

    log.i(string.format("Mirror mode applied: %s -> %s", second.id, first.id))
    return true
end

local function applyMatchingProfile(reason)
    if getConfig("enabled", true) ~= true then
        log.d("display_layout module is disabled")
        return false, "display_layout disabled"
    end

    local matched, err = findMatchingProfile(nil)
    if not matched then
        return false, err
    end

    local cmd, buildErr = buildDisplayplacerCommand(matched.displayplacer_path, matched.profile.screens)
    if not cmd then
        log.e("Failed to build displayplacer command: " .. tostring(buildErr))
        return false, "invalid profile config"
    end

    log.d(string.format("Executing displayplacer command for profile '%s'", matched.key))
    local output, okApply, _, rcApply = hs.execute(cmd)
    if not okApply then
        log.w(string.format("displayplacer apply failed (rc=%s): %s", tostring(rcApply), tostring(output)))
        return false, "apply failed"
    end

    log.i(string.format("Applied display profile '%s' (reason=%s)", tostring(matched.key), tostring(reason)))
    return true, matched.key
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

local function cleanup()
    cancelTimers()
    if screen_watcher then
        screen_watcher:stop()
        screen_watcher = nil
    end
    if caffeinate_watcher then
        caffeinate_watcher:stop()
        caffeinate_watcher = nil
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
            notify("repair_failed", message)
        end
        return false
    end

    markSecondExternalOnMacInput(true)
    if shouldNotify(reason) then
        notify("repair_ok", string.format("Display layout repaired (%s)", tostring(result)), 0.8)
    end

    return true
end

local function scheduleRepair(reason)
    cancelTimers()
    attempt_count = 0

    if not second_external_state.on_mac_input and reason ~= "hotkey" then
        log.d(string.format("scheduleRepair: skipping (second external switched away from Mac input, reason=%s)", reason))
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

-- Restore second external to Mac input with single-flash strategy:
-- 1. Apply extended layout FIRST (un-mirror while display still shows alt input — invisible)
-- 2. Switch m1ddc input to Mac (single visible flash)
local function restoreSecondExternalToMacInput()
    if second_external_state.on_mac_input then
        return true
    end

    local m1ddcPath = resolveM1ddcPath()
    if not m1ddcPath then
        notify("toggle_no_tool", "m1ddc not found", 1.5)
        return false
    end

    if not second_external_state.uuid or type(second_external_state.mac_input) ~= "number" then
        notify("toggle_restore_missing", "Second external restore target unknown", 1.5)
        return false
    end

    -- Restore extended layout before switching input to avoid double flash.
    -- The Mac still controls the display via DP even when DDC input shows HDMI.
    local layoutRestored = false
    local displayplacerPath = resolveDisplayplacerPath()
    if displayplacerPath and second_external_state.profile_key then
        local profiles = getConfig("profiles", {})
        local profile = profiles[second_external_state.profile_key]
        if profile and profile.screens then
            local cmd = buildDisplayplacerCommand(displayplacerPath, profile.screens)
            if cmd then
                log.d("Restoring extended layout before input switch")
                local output, ok = hs.execute(cmd)
                if ok then
                    layoutRestored = true
                    log.i("Extended layout restored (pre-switch)")
                else
                    log.w("Pre-switch layout restore failed: " .. tostring(output))
                end
            end
        end
    end

    log.i("restoreSecondExternalToMacInput: switching second external back to Mac input")
    local ok = runM1ddcSetInput(m1ddcPath, second_external_state, second_external_state.mac_input)
    if not ok then
        notify("toggle_restore_failed", "Failed to restore second external input", 1.5)
        return false
    end

    markSecondExternalOnMacInput(true)

    if not layoutRestored then
        -- Fallback: layout wasn't restored pre-switch; schedule delayed repair
        log.d("Layout not restored pre-switch; scheduling delayed repair")
        hs.timer.doAfter(second_external_state.reconnect_delay_seconds, function()
            scheduleRepair("hotkey")
        end)
    end

    notify("toggle_restored", string.format("Second external: %s", second_external_state.mac_label))
    return true
end

local function toggleSecondExternal()
    local m1ddcPath = resolveM1ddcPath()
    if not m1ddcPath then
        notify("toggle_no_tool", "m1ddc not found", 1.5)
        return
    end

    if not second_external_state.on_mac_input then
        restoreSecondExternalToMacInput()
        return
    end

    local spec, err = buildToggleSpec()
    if not spec then
        local message = err == "no profile matches current displays"
            and "Second external toggle currently supports configured home/office profiles only"
            or tostring(err)
        notify("toggle_not_available", message, 1.5)
        return
    end

    log.i(string.format("toggleSecondExternal: switching second external to %s + mirror", spec.alt_label))
    local ok = runM1ddcSetInput(m1ddcPath, spec, spec.alt_input)
    if not ok then
        notify("toggle_failed", "Failed to switch second external input", 1.5)
        return
    end

    applyMirrorMode(spec.displayplacer_path, spec.profile)

    updateSecondExternalState(spec, false)
    notify("toggle_alt_input", string.format("Second external: %s (mirrored)", spec.alt_label))
end

local function handleRepairHotkey()
    if not second_external_state.on_mac_input then
        restoreSecondExternalToMacInput()
        return
    end

    scheduleRepair("hotkey")
end

function M.init()
    log.i("Initializing display layout module")
    cleanup()
    loadSecondExternalState()

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
                handleRepairHotkey()
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
            description = "Toggle second external display input",
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

    log.i("Event: startup")
    scheduleRepair("startup")

    log.i("Display layout module initialized")
end

local init_system = require("core.init_system")
init_system.registerModule("modules.display_layout", {
    init = M.init,
    dependencies = {
        "utils.notification_utils",
    }
})

return M
