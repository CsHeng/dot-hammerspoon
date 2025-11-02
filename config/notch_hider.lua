-- Notch hider configuration for Hammerspoon
-- Settings for hiding the MacBook Pro notch

local config = {}

-- Notch hider settings
config.notch_hider = {
    -- Enable notch hider on startup
    enabled = false,

    -- Automatically detect and hide notch on built-in displays
    auto_hide = true,

    -- Height of the black cover in pixels (adjust for your Mac model)
    cover_height = 50,

    -- Opacity of the cover (1.0 = completely opaque, 0.0 = transparent)
    opacity = 1.0,

    -- Show notch hider status in menu bar
    show_on_menu_bar = false,

    -- Auto-disable when external display is connected
    auto_disable_external = true,

    -- Delay before re-applying cover after display change (seconds)
    reapply_delay = 0.5,

    -- Custom dimensions for different Mac models
    models = {
        -- 14-inch MacBook Pro (2021+)
        ["MBP14,1"] = { cover_height = 45 },
        ["MBP14,2"] = { cover_height = 45 },
        ["MBP14,3"] = { cover_height = 45 },

        -- 16-inch MacBook Pro (2021+)
        ["MBP16,1"] = { cover_height = 50 },
        ["MBP16,2"] = { cover_height = 50 },
        ["MBP16,3"] = { cover_height = 50 },

        -- 15-inch MacBook Pro (2023+)
        ["MBP15,1"] = { cover_height = 42 },
        ["MBP15,2"] = { cover_height = 42 },
        ["MBP15,3"] = { cover_height = 42 },
    }
}

return config