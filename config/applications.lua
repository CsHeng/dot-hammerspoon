-- Application configuration for Hammerspoon
-- All application definitions and launch settings are centralized here

local config = {}

-- Launcher applications with their key bindings
config.applications = {
    launcher_apps = {
        {modifier = {"cmd", "alt"}, key = 'C', appname = 'Cursor', bundleid = 'com.todesktop.230313mzl4w4u92'},
        {modifier = {"cmd", "alt"}, key = 'Q', appname = 'QQ', bundleid = 'com.tencent.qq'},
        {modifier = {"cmd", "alt"}, key = 'W', appname = 'WeChat', bundleid = 'com.tencent.xinWeChat'},
        {modifier = {"cmd", "alt"}, key = 'D', appname = 'DingTalk', bundleid = 'com.alibaba.DingTalk'},
        {modifier = {"cmd", "alt"}, key = 'G', appname = 'Google Chrome', bundleid = 'com.google.Chrome'},
        {modifier = {"cmd", "alt"}, key = 'F', appname = 'Finder', bundleid = 'com.apple.Finder'},
        {modifier = {"cmd", "alt"}, key = 'H', appname = 'Hammerspoon', bundleid = 'org.hammerspoon.Hammerspoon'},
        -- {modifier = {}, key = 'F10', appname = 'Ghostty', bundleid = 'com.mitchellh.ghostty'},
        {modifier = {}, key = 'F10', appname = 'Wezterm', bundleid = 'com.github.wez.wezterm'},
    },

    -- Media control bindings
    media_controls = {
        {modifier = {"ctrl", "cmd", "alt"}, key = 'left', action = 'PREVIOUS'},
        {modifier = {"ctrl", "cmd", "alt"}, key = 'right', action = 'NEXT'},
        {modifier = {"ctrl", "cmd", "alt"}, key = 'space', action = 'PLAY'},
        {modifier = {"ctrl", "cmd", "alt"}, key = 'up', action = 'SOUND_UP'},
        {modifier = {"ctrl", "cmd", "alt"}, key = 'down', action = 'SOUND_DOWN'},
    },

    -- Applications that may need restarting
    problematic_apps = {
        {modifier = {"ctrl", "cmd", "alt"}, key = 'D', appname = 'DisplayLink Manager', bundleid = 'com.displaylink.DisplayLinkUserAgent'},
    }
}

-- Browser applications for special handling
config.browsers = {
    bundle_ids = {
        "com.apple.Safari",
        "com.microsoft.edgemac",
        "com.google.Chrome"
    },
    names = {
        "Safari",
        "Microsoft Edge",
        "Google Chrome"
    }
}

-- Application categories for expose filtering
config.expose_app_filter = {
    -- Allow these apps in expose
    allowed = {
        'WezTerm',
        'Finder',
        'Google Chrome',
        'Cursor',
        'WeChat',
        'QQ',
        'DingTalk',
        'Ghostty'
    },

    -- Browser-specific expose
    browsers = {
        'Safari',
        'Google Chrome'
    }
}

-- Application startup behavior
config.startup = {
    -- Applications to launch on startup (disabled by default)
    auto_launch = false,
    apps = {
        -- {bundleid = 'com.todesktop.230313mzl4w4u92', delay = 2}, -- Cursor
        -- {bundleid = 'com.google.Chrome', delay = 3}, -- Chrome
    }
}

-- Application focus behavior
config.focus_behavior = {
    -- Hide other applications when focusing (like cmd+tab)
    hide_others = false,

    -- Activate application when focusing
    activate_on_focus = true,

    -- Bring all windows to front when focusing
    bring_all_to_front = false
}

-- Mouse button bindings for specific applications
config.mouse_bindings = {
    -- Global mouse button bindings
    global = {
        -- These are handled in mouse_management.lua
    },

    -- Application-specific mouse bindings
    app_specific = {
        -- Example:
        -- ["com.google.Chrome"] = {
        --     {button = 2, action = "back"},
        --     {button = 3, action = "forward"}
        -- }
    }
}

return config