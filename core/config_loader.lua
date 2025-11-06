-- Configuration loader for Hammerspoon
-- Centralized configuration management with validation

local logger = require("core.logger")
local log = logger.getLogger("config_loader")

local M = {}

-- Configuration storage
local config = {}

-- Default configurations
local defaults = {
    hotkeys = {
        system_reload = {"ctrl", "cmd", "alt", "R"},
        system_console = {"ctrl", "cmd", "alt", "H"},
        system_expose = {"ctrl", "cmd", "tab"},

        window_hyper = {"ctrl", "alt"},
        window_hyper_shift = {"ctrl", "alt", "shift"},
        window_maximize = {"ctrl", "alt", "return"},
        window_center = {"ctrl", "alt", "c"},
        window_original = {"ctrl", "alt", "o"},

        launcher_modifier = {"cmd", "alt"},
        media_modifier = {"ctrl", "cmd", "alt"},
        fuck_modifier = {"ctrl", "cmd", "alt"},

        keycastr_toggle = {"ctrl", "cmd", "alt", "k"},
        keycastr_click_circle = {"ctrl", "cmd", "alt", "c"},
        keycastr_continuous = {"ctrl", "cmd", "alt", "i"},

        mouse = {
            modifier = {"fn", "ctrl"}
        },

        cmd_q_protection = {"cmd", "q"},
        paste_defeat = {"cmd", "alt", "V"},
    },

    mouse = {
        management_module = "modules.mouse_management"
    },

    window = {
        tolerance = 5,
        quarter_tolerance = 10,
        screen_edge_margin = 20,
        original_frame_storage = {}
    },

    keycastr = {
        enabled = false,
        duration = 1.5,
        font_size = 24,
        max_displayed = 6,
        fade_out_duration = 0.3,
        padding = 4,
        margin = 6,
        position = {x = 30, y = nil},
        colors = {
            text = {hex = "#FFFFFF"},
            background = {hex = "#333333", alpha = 0.8}
        },
        draggable = true,
        display_mode = "all_modifiers",
        show_mouse_clicks = false,
        show_click_circle = false,
        click_circle = {
            size = 40,
            color = {hex = "#FF7700", alpha = 0.7},
            duration = 0.3,
            fade_out = 0.2
        },
        continuous_input = {
            enabled = true,
            max_chars = 20,
            timeout = 1.0
        }
    },

    hotkeys_announcements = {
        default = false,
        modules = {},
        bindings = {}
    },

    wifi = {
        muted_ssids = {
            ["Jiatu"] = true,
            ["Jiatu-Legacy"] = true,
            ["Shanqu"] = true,
        },
        monitoring = {
            enabled = true,
            check_interval = 5,
            monitor_wifi = true,
            monitor_ethernet = false,
            monitor_vpn = false,
            stable_threshold = 10
        },
        behavior = {
            use_location_workaround = true,
            notify_on_change = true,
            mute_on_work_networks = true,
            unmute_on_leave = true,
            mute_delay = 0,
            unmute_delay = 1
        },
        audio = {
            target_device = "builtin",
            restore_volume = 0.5,
            fade_duration = 0.5,
            show_notifications = true
        },
        notifications = {
            network_change = true,
            work_mode = true,
            audio_mute = true,
            use_persistent = true,
            use_macos = true,
            messages = {
                connected = "%s Connected",
                disconnected = "%s Disconnected",
                work_mode = "Work Mode: %s, Built-in Audio Muted (%s)",
                device_not_found = "Work Mode: %s, Built-in Audio Device Not Found"
            }
        },
        network_profiles = {
            default = {
                apps = {},
                audio = {
                    mute_builtin = false,
                    set_output_device = "Built-in"
                },
                status = "unknown"
            }
        },
        location = {
            enabled = true,
            update_interval = 300,
            timeout = 10,
            log_location = false
        },
        security = {
            log_ssids = true,
            store_history = true,
            max_history_entries = 100,
            excluded_ssids = {}
        },
        debug = {
            enabled = false,
            log_network_details = false,
            log_audio_operations = false,
            log_location_operations = false,
            test_mode = false
        }
    },

    applications = {
        launcher_apps = {
            {modifier = {"cmd", "alt"}, key = 'C', appname = 'Cursor', bundleid = 'com.todesktop.230313mzl4w4u92'},
            {modifier = {"cmd", "alt"}, key = 'Q', appname = 'QQ', bundleid = 'com.tencent.qq'},
            {modifier = {"cmd", "alt"}, key = 'W', appname = 'WeChat', bundleid = 'com.tencent.xinWeChat'},
            {modifier = {"cmd", "alt"}, key = 'D', appname = 'DingTalk', bundleid = 'com.alibaba.DingTalk'},
            {modifier = {"cmd", "alt"}, key = 'G', appname = 'Google Chrome', bundleid = 'com.google.Chrome'},
            {modifier = {"cmd", "alt"}, key = 'F', appname = 'Finder', bundleid = 'com.apple.Finder'},
            {modifier = {"cmd", "alt"}, key = 'H', appname = 'Hammerspoon', bundleid = 'org.hammerspoon.Hammerspoon'},
            {modifier = {}, key = 'F10', appname = 'Ghostty', bundleid = 'com.mitchellh.ghostty'},
        },

        media_controls = {
            {modifier = {"ctrl", "cmd", "alt"}, key = 'left', action = 'PREVIOUS'},
            {modifier = {"ctrl", "cmd", "alt"}, key = 'right', action = 'NEXT'},
            {modifier = {"ctrl", "cmd", "alt"}, key = 'space', action = 'PLAY'},
            {modifier = {"ctrl", "cmd", "alt"}, key = 'up', action = 'SOUND_UP'},
            {modifier = {"ctrl", "cmd", "alt"}, key = 'down', action = 'SOUND_DOWN'},
        },

        problematic_apps = {
            {modifier = {"ctrl", "cmd", "alt"}, key = 'D', appname = 'DisplayLink Manager', bundleid = 'com.displaylink.DisplayLinkUserAgent'},
        }
    }
}

-- Load configuration from files
local function loadConfigFiles()
    local config_files = {
        "hotkeys",
        "applications",
        "keycastr",
        "wifi",
        "visual",
        "mouse"
    }

    for _, config_name in ipairs(config_files) do
        local success, module_config = pcall(require, "config." .. config_name)
        if success and module_config then
            config = M.mergeTables(config, module_config)
            log:i(string.format("Loaded configuration from config/%s.lua", config_name))
        else
            log:w(string.format("Failed to load configuration from config/%s.lua: %s", config_name, module_config))
        end
    end
end

-- Merge two tables recursively
function M.mergeTables(t1, t2)
    local result = M.cloneTable(t1)

    for k, v in pairs(t2) do
        if type(v) == "table" and type(result[k]) == "table" then
            result[k] = M.mergeTables(result[k], v)
        else
            result[k] = v
        end
    end

    return result
end

-- Deep clone a table
function M.cloneTable(t)
    if type(t) ~= "table" then return t end

    local result = {}
    for k, v in pairs(t) do
        if type(v) == "table" then
            result[k] = M.cloneTable(v)
        else
            result[k] = v
        end
    end

    return result
end

-- Get configuration value with default fallback
function M.get(path, default)
    local keys = {}
    for key in string.gmatch(path, "[^%.]+") do
        table.insert(keys, key)
    end

    local value = config
    for i, key in ipairs(keys) do
        if type(value) == "table" and value[key] ~= nil then
            value = value[key]
        else
            if default ~= nil then
                log:d(string.format("Config path '%s' not found, using default", path))
                return default
            end
            log:w(string.format("Config path '%s' not found and no default provided", path))
            return nil
        end
    end

    return value
end

-- Set configuration value
function M.set(path, value)
    local keys = {}
    for key in string.gmatch(path, "[^%.]+") do
        table.insert(keys, key)
    end

    local current = config
    for i, key in ipairs(keys) do
        if i == #keys then
            current[key] = value
            log:d(string.format("Set config '%s' to %s", path, tostring(value)))
        else
            if type(current[key]) ~= "table" then
                current[key] = {}
            end
            current = current[key]
        end
    end
end

-- Validate configuration
function M.validate()
    local issues = {}

    -- Validate hotkey configurations
    local hotkeys = M.get("hotkeys", {})
    for name, key_combo in pairs(hotkeys) do
        if type(key_combo) ~= "table" then
            table.insert(issues, string.format("Invalid hotkey configuration: %s", name))
        elseif #key_combo == 0 then
            -- Skip configuration sections (they're valid)
            -- Only validate actual hotkey combinations (tables with modifier keys)
            local has_hotkeys = false
            for _, value in pairs(key_combo) do
                if type(value) == "table" and #value > 0 then
                    has_hotkeys = true
                    break
                end
            end

            if not has_hotkeys and not (name == "modifier" or name:match("%.modifier$")) then
                table.insert(issues, string.format("Invalid hotkey configuration: %s", name))
            end
        end
    end

    -- Validate application configurations
    local apps = M.get("applications", {})
    for category, app_list in pairs(apps) do
        if type(app_list) == "table" then
            for i, app in ipairs(app_list) do
                -- Check for required fields based on category
                if category == "media_controls" then
                    -- media_controls entries have 'action' instead of 'appname'
                    if not app.key or not app.action then
                        table.insert(issues, string.format("Invalid app configuration in %s at index %d", category, i))
                    end
                else
                    -- Regular app entries need 'key' and 'appname'
                    if not app.key or not app.appname then
                        table.insert(issues, string.format("Invalid app configuration in %s at index %d", category, i))
                    end
                end
            end
        end
    end

    if #issues > 0 then
        log:w("Configuration validation found issues:")
        for _, issue in ipairs(issues) do
            log:w("  - " .. issue)
        end
    else
        log:i("Configuration validation passed")
    end

    return #issues == 0
end

-- Initialize configuration
function M.init()
    log:i("Initializing configuration system")

    -- Start with defaults
    config = M.cloneTable(defaults)

    -- Load configuration files (will override defaults)
    loadConfigFiles()

    -- Validate the final configuration
    M.validate()

    log:i("Configuration system initialized")
end

-- Get the entire configuration (for debugging)
function M.getAll()
    return M.cloneTable(config)
end

-- Initialize on load
M.init()

return M
