-- Application configuration for Hammerspoon
-- Application metadata lives here; key combinations are edited only in config/hotkeys.lua.

local config = {}

config.applications = {
    launcher_apps = {
        -- {id = 'cursor', appname = 'Cursor', bundleid = 'com.todesktop.230313mzl4w4u92'},
        {id = 'vscode', appname = 'Visual Studio Code', bundleid = 'com.microsoft.VSCode'},
        {id = 'qq', appname = 'QQ', bundleid = 'com.tencent.qq'},
        {id = 'wechat', appname = 'WeChat', bundleid = 'com.tencent.xinWeChat'},
        {id = 'dingtalk', appname = 'DingTalk', bundleid = 'com.alibaba.DingTalk'},
        {id = 'chrome', appname = 'Google Chrome', bundleid = 'com.google.Chrome'},
        {id = 'finder', appname = 'Finder', bundleid = 'com.apple.Finder'},
        {id = 'hammerspoon', appname = 'Hammerspoon', bundleid = 'org.hammerspoon.Hammerspoon'},
        -- {id = 'ghostty', appname = 'Ghostty', bundleid = 'com.mitchellh.ghostty'},
        -- {id = 'kitty', appname = 'kitty', bundleid = 'net.kovidgoyal.kitty'},
        {id = 'wezterm', appname = 'WezTerm', bundleid = 'com.github.wez.wezterm'},
    },

    media_controls = {
        {id = 'previous', action = 'PREVIOUS'},
        {id = 'next', action = 'NEXT'},
        {id = 'play', action = 'PLAY'},
        {id = 'sound_up', action = 'SOUND_UP'},
        {id = 'sound_down', action = 'SOUND_DOWN'},
    },

    -- Applications that may need restarting
    problematic_apps = {
        -- Example:
        -- {id = 'app_name', appname = 'App Name', bundleid = 'com.bundle.id', restart_delay = 0},
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
        'Visual Studio Code',
        'WeChat',
        'QQ',
        'DingTalk',
        'WezTerm'
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
