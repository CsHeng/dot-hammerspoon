-- KeyCastr configuration for Hammerspoon
-- All keystroke visualization settings are centralized here

local config = {}

-- Main KeyCastr settings
config.keycastr = {
    -- General settings
    enabled = false,                   -- Initially disabled
    duration = 1.5,                   -- How long each keystroke stays visible (seconds)
    font_size = 24,                  -- Font size for keystrokes
    max_displayed = 6,               -- Maximum number of keystrokes to display
    fade_out_duration = 0.3,          -- Fade out animation duration (seconds)
    padding = 4,                     -- Padding inside keystroke box
    margin = 6,                      -- Margin between keystrokes
    screen_edge_margin = 20,         -- Margin from screen edge

    -- Position settings
    position = {
        x = 30,                      -- Default X position
        y = nil                      -- nil = bottom of screen (calculated)
    },

    -- Visual appearance
    colors = {
        text = {hex = "#FFFFFF"},
        background = {hex = "#333333", alpha = 0.8}
    },

    -- Interaction settings
    draggable = true,               -- Allow dragging the visualization
    display_mode = "all_modifiers", -- Options: "command_only", "all_modifiers", "all_keys"
    show_mouse_clicks = false,      -- Show mouse click events in keystroke display
    show_click_circle = false,      -- Show circle animation at mouse click location

    -- Click circle settings
    click_circle = {
        size = 40,                  -- Size of click circle
        color = {hex = "#FF7700", alpha = 0.7},
        duration = 0.3,             -- How long the circle animation lasts
        fade_out = 0.2              -- Fade out duration
    },

    -- Continuous input settings
    continuous_input = {
        enabled = true,             -- Enable continuous input on the same line
        max_chars = 20,            -- Maximum characters per line
        timeout = 1.0               -- Timeout after this time to start a new line (seconds)
    }
}

-- Special key mappings for display
config.special_keys = {
    tab = "⇥",
    capslock = "⇪",
    up = "↑",
    down = "↓",
    left = "←",
    right = "→",
    escape = "⎋",
    forwarddelete = "⌦",
    delete = "⌫",
    home = "↖",
    ["end"] = "↘",
    pageup = "⇞",
    pagedown = "⇟",
    space = "␣",
    ["return"] = "↩",
    fn = "fn",
    eject = "⏏"
}

-- Modifier key symbols
config.modifier_symbols = {
    cmd = "⌘",
    alt = "⌥",
    shift = "⇧",
    ctrl = "⌃",
    rightcmd = "⌘",
    rightalt = "⌥",
    rightshift = "⇧",
    rightctrl = "⌃"
}

-- Mouse button symbols
config.mouse_button_symbols = {
    left = "🖱️LB",
    right = "🖱️RB",
    middle = "🖱️MB",
    button4 = "🖱️B4",
    button5 = "🖱️B5"
}

-- Behavior presets
config.presets = {
    minimal = {
        display_mode = "command_only",
        max_displayed = 3,
        duration = 1.0,
        show_mouse_clicks = false,
        show_click_circle = false
    },

    developer = {
        display_mode = "all_modifiers",
        max_displayed = 8,
        duration = 2.0,
        show_mouse_clicks = true,
        show_click_circle = true
    },

    presentation = {
        display_mode = "all_keys",
        max_displayed = 10,
        duration = 3.0,
        font_size = 32,
        show_mouse_clicks = true,
        show_click_circle = true
    }
}

-- Filter settings
config.filters = {
    -- Applications where KeyCastr should be disabled
    disabled_apps = {
        "com.apple.systempreferences",
        "com.apple.finder"
    },

    -- Key types to filter out
    filtered_keys = {
        -- Examples:
        -- "capslock",
        -- "shift",
        -- "fn"
    },

    -- Window titles where KeyCastr should be disabled
    filtered_window_titles = {
        -- Examples:
        -- "Password",
        -- "Login"
    }
}

-- Performance settings
config.performance = {
    cleanup_interval = 0.5,        -- How often to clean up expired keystrokes (seconds)
    drawing_cache_size = 20,        -- Maximum number of cached drawing objects
    memory_cleanup_interval = 60    -- How often to clean up memory (seconds)
}

return config