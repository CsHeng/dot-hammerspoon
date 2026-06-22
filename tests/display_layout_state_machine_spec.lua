local F612 = "F612A96D-269C-436C-92B1-E8C47E6272E6"
local INTERNAL = "37D8832A-2D66-02CA-B9F7-8F30A301B230"
local D062 = "D0627D9C-EEDB-417D-88ED-C5FE3663710D"

local tests = {}

local function test(name, fn)
    tests[#tests + 1] = { name = name, fn = fn }
end

local function assertTrue(value, message)
    if not value then
        error(message, 2)
    end
end

local function assertEquals(actual, expected, message)
    if actual ~= expected then
        error(
            string.format("%s: expected %s, got %s", message, tostring(expected), tostring(actual)),
            2
        )
    end
end

local function contains(value, needle)
    return string.find(value, needle, 1, true) ~= nil
end

local function snapshotState(state)
    local snapshot = {}
    for key, value in pairs(state or {}) do
        snapshot[key] = value
    end
    return snapshot
end

local function nestedGet(root, path)
    local current = root
    for key in string.gmatch(path, "[^%.]+") do
        if type(current) ~= "table" then
            return nil
        end
        current = current[key]
    end
    return current
end

local function resetLoadedModules()
    package.loaded["modules.display_layout"] = nil
    package.loaded["core.logger"] = nil
    package.loaded["core.config_loader"] = nil
    package.loaded["utils.hotkey_utils"] = nil
    package.loaded["utils.notification_utils"] = nil
    package.loaded["core.init_system"] = nil
end

local function createHarness(options)
    resetLoadedModules()

    local harness = {
        events = {},
        bindings = {},
        timers = {},
        settings = {},
        options = options or {},
    }

    local function event(kind, detail)
        harness.events[#harness.events + 1] = {
            kind = kind,
            detail = detail,
        }
    end

    function harness:firstIndex(kind)
        for index, item in ipairs(self.events) do
            if item.kind == kind then
                return index
            end
        end
        return nil
    end

    local displayplacerListOutput = table.concat({
        "Persistent screen id: " .. F612,
        "Persistent screen id: " .. INTERNAL,
        "Persistent screen id: " .. D062,
    }, "\n")

    local displayLayoutConfig = {
        enabled = true,
        displayplacer = {
            paths = { "/opt/homebrew/bin/displayplacer" },
        },
        m1ddc = {
            paths = { "/opt/homebrew/bin/m1ddc" },
            home_second_external_input_toggle = {
                command = "input",
                mac_input = 15,
                alt_input = 18,
                mac_label = "DisplayPort 1",
                alt_label = "HDMI 2",
                reconnect_delay_seconds = 2.0,
            },
        },
        auto_repair = {
            enabled = options.auto_repair_enabled == true,
        },
        profile_order = { "home_open" },
        profiles = {
            home_open = {
                enabled = true,
                require_total_screens = 3,
                screens = {
                    {
                        id = F612,
                        res = "2560x1440",
                        scaling = "off",
                        origin = { 0, 0 },
                        degree = 0,
                        enabled = true,
                    },
                    {
                        id = INTERNAL,
                        res = "1512x982",
                        scaling = "on",
                        origin = { -1512, 0 },
                        degree = 0,
                        enabled = true,
                    },
                    {
                        id = D062,
                        res = "2560x1440",
                        scaling = "off",
                        origin = { 2560, 0 },
                        degree = 0,
                        enabled = true,
                    },
                },
            },
        },
    }

    package.preload["core.logger"] = function()
        return {
            getLogger = function()
                return {
                    d = function() end,
                    i = function() end,
                    w = function() end,
                    e = function() end,
                }
            end,
        }
    end

    package.preload["core.config_loader"] = function()
        return {
            get = function(path, default)
                local value = nestedGet({ display_layout = displayLayoutConfig }, path)
                if value == nil then
                    return default
                end
                return value
            end,
        }
    end

    package.preload["utils.hotkey_utils"] = function()
        return {
            getSpec = function(_, default)
                return default
            end,
            parseHotkey = function(spec)
                local modifiers = {}
                for index = 1, #spec - 1 do
                    modifiers[#modifiers + 1] = spec[index]
                end
                return modifiers, spec[#spec]
            end,
            bind = function(_, _, opts)
                harness.bindings[opts.id] = opts.pressed
                event("bind", opts.id)
            end,
        }
    end

    package.preload["utils.notification_utils"] = function()
        return {
            announce = function(_, key, payload)
                event("notify", { key = key, message = payload.message })
            end,
        }
    end

    package.preload["core.init_system"] = function()
        return {
            registerModule = function()
                event("register_module")
            end,
        }
    end

    _G.hs = {
        fs = {
            attributes = function()
                return {}
            end,
        },
        settings = {
            get = function(key)
                return harness.settings[key]
            end,
            set = function(key, value)
                harness.settings[key] = snapshotState(value)
                if key == "display_layout.second_external_toggle_state" then
                    if value.on_mac_input == false then
                        event("state_off", snapshotState(value))
                    else
                        event("state_on", snapshotState(value))
                    end
                end
            end,
        },
        execute = function(cmd)
            if contains(cmd, "displayplacer") and contains(cmd, " list") then
                event("displayplacer_list", cmd)
                return displayplacerListOutput, true, nil, 0
            end

            if contains(cmd, "displayplacer") and contains(cmd, F612 .. "+" .. D062) then
                event("displayplacer_mirror", cmd)
                if harness.options.mirror_ok == false then
                    return "mirror failed", false, nil, 1
                end
                return "", true, nil, 0
            end

            if contains(cmd, "displayplacer") then
                event("displayplacer_extended", cmd)
                return "", true, nil, 0
            end

            if contains(cmd, "m1ddc") and contains(cmd, " set input 18") then
                event("m1ddc_alt", cmd)
                if harness.options.alt_ok == false then
                    return "alt input failed", false, nil, 1
                end
                return "18", true, nil, 0
            end

            if contains(cmd, "m1ddc") and contains(cmd, " set input 15") then
                event("m1ddc_mac", cmd)
                return "15", true, nil, 0
            end

            event("execute_unknown", cmd)
            return "", true, nil, 0
        end,
        timer = {
            doAfter = function(_, fn)
                event("timer_after")
                local timer = {
                    stop = function()
                        event("timer_stop")
                    end,
                    fire = fn,
                }
                harness.timers[#harness.timers + 1] = timer
                return timer
            end,
        },
        screen = {
            watcher = {
                new = function(fn)
                    harness.screenWatcher = fn
                    return {
                        start = function()
                            event("screen_watcher_start")
                        end,
                        stop = function()
                            event("screen_watcher_stop")
                        end,
                    }
                end,
            },
        },
        caffeinate = {
            watcher = {
                screensDidWake = 1,
                systemDidWake = 2,
                sessionDidBecomeActive = 3,
                screensDidUnlock = 4,
                new = function(fn)
                    harness.caffeinateWatcher = fn
                    return {
                        start = function()
                            event("caffeinate_watcher_start")
                        end,
                        stop = function()
                            event("caffeinate_watcher_stop")
                        end,
                    }
                end,
            },
        },
    }

    return harness
end

local function assertOrder(harness, beforeKind, afterKind)
    local beforeIndex = harness:firstIndex(beforeKind)
    local afterIndex = harness:firstIndex(afterKind)

    assertTrue(beforeIndex ~= nil, "missing event: " .. beforeKind)
    assertTrue(afterIndex ~= nil, "missing event: " .. afterKind)
    assertTrue(
        beforeIndex < afterIndex,
        string.format("expected %s before %s", beforeKind, afterKind)
    )
end

local function assertNoEventAfter(harness, blockedKind, afterKind)
    local afterIndex = harness:firstIndex(afterKind)
    assertTrue(afterIndex ~= nil, "missing event: " .. afterKind)

    for index = afterIndex + 1, #harness.events do
        assertTrue(
            harness.events[index].kind ~= blockedKind,
            string.format("expected no %s after %s", blockedKind, afterKind)
        )
    end
end

test("home second external alternate command targets HDMI 2", function()
    local actualConfig = dofile("config/display_layout.lua")
    local toggle = actualConfig.display_layout.m1ddc.home_second_external_input_toggle

    assertEquals(toggle.command, "input", "home alternate input command")
    assertEquals(toggle.alt_input, 18, "home alternate input value")
    assertEquals(toggle.alt_label, "HDMI 2", "home alternate input label")
end)

test("toggle saves off state before mirror and runs alt input command after mirror", function()
    local harness = createHarness({ alt_ok = true })
    local displayLayout = require("modules.display_layout")

    displayLayout.init()
    harness.bindings.toggle_second_external()

    assertOrder(harness, "state_off", "displayplacer_mirror")
    assertOrder(harness, "displayplacer_mirror", "m1ddc_alt")
end)

test("toggle rolls back extended layout and on state when alt input command fails", function()
    local harness = createHarness({ alt_ok = false })
    local displayLayout = require("modules.display_layout")

    displayLayout.init()
    harness.bindings.toggle_second_external()

    assertOrder(harness, "displayplacer_mirror", "m1ddc_alt")
    assertOrder(harness, "m1ddc_alt", "displayplacer_extended")
    assertOrder(harness, "displayplacer_extended", "state_on")
end)

test("pending auto repair skips after toggle leaves Mac input state", function()
    local harness = createHarness({ alt_ok = true, auto_repair_enabled = true })
    local displayLayout = require("modules.display_layout")

    displayLayout.init()
    harness.bindings.toggle_second_external()

    assertTrue(#harness.timers > 0, "expected startup repair timer")
    harness.timers[1].fire()

    assertNoEventAfter(harness, "displayplacer_extended", "state_off")
end)

local failures = 0

for _, item in ipairs(tests) do
    local ok, err = pcall(item.fn)
    if ok then
        io.write("PASS: " .. item.name .. "\n")
    else
        failures = failures + 1
        io.write("FAIL: " .. item.name .. "\n")
        io.write(tostring(err) .. "\n")
    end
end

if failures > 0 then
    os.exit(1)
end
