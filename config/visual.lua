-- Visual configuration for Hammerspoon
-- All visual and UI settings are centralized here

local config = {}

-- General visual settings
config.visual = {
    -- Window management visual settings
    window = {
        -- Edge detection tolerance (pixels)
        tolerance = 5,

        -- Quarter positioning tolerance (pixels)
        quarter_tolerance = 10,

        -- Animation settings
        animate_movement = true,
        animation_duration = 0.2,

        -- Screen edge margin for positioning
        screen_edge_margin = 20,

        -- Preserve original window frame storage
        original_frame_storage = true,

        -- Window frame storage cleanup interval (seconds)
        cleanup_interval = 300
    },

    -- Notification visual settings
    notifications = {
        -- Default notification method ("persistent", "macos", "auto")
        default_method = "auto",

        -- Alert duration (seconds)
        alert_duration = 2,

        -- Notification colors
        colors = {
            info = {hex = "#3498db"},
            success = {hex = "#2ecc71"},
            warning = {hex = "#f39c12"},
            error = {hex = "#e74c3c"}
        },

        -- Notification font settings
        font = {
            name = "System Font",
            size = 14
        }
    },

    -- Menu bar settings
    menu_bar = {
        -- Enable menu bar icon
        enabled = true,

        -- Icon appearance
        icon = {
            -- Use built-in icon or custom
            use_builtin = true,

            -- Custom icon path (if not using builtin)
            custom_path = nil,

            -- Icon color
            color = {hex = "#000000"}
        },

        -- Menu bar title
        title = {
            -- Show title
            enabled = false,

            -- Title text
            text = "HS",

            -- Title color
            color = {hex = "#000000"}
        }
    },

    -- Grid settings (for grid-based window management)
    grid = {
        -- Grid size (columns x rows)
        columns = 3,
        rows = 3,

        -- Grid margins
        margins = 5,

        -- Grid cell padding
        padding = 2,

        -- Show grid overlay
        show_overlay = true,

        -- Overlay appearance
        overlay = {
            color = {hex = "#000000", alpha = 0.1},
            border_width = 2,
            border_color = {hex = "#000000", alpha = 0.3}
        }
    }
}

-- Color themes
config.themes = {
    -- Default theme
    default = {
        primary = {hex = "#3498db"},
        secondary = {hex = "#2ecc71"},
        accent = {hex = "#f39c12"},
        warning = {hex = "#e74c3c"},
        background = {hex = "#000000", alpha = 0.8},
        text = {hex = "#FFFFFF"}
    },

    -- Dark theme
    dark = {
        primary = {hex = "#BB86FC"},
        secondary = {hex = "#03DAC6"},
        accent = {hex = "#CF6679"},
        warning = {hex = "#FFB74D"},
        background = {hex = "#121212", alpha = 0.9},
        text = {hex = "#FFFFFF"}
    },

    -- Light theme
    light = {
        primary = {hex = "#1976D2"},
        secondary = {hex = "#388E3C"},
        accent = {hex = "#F57C00"},
        warning = {hex = "#D32F2F"},
        background = {hex = "#FFFFFF", alpha = 0.9},
        text = {hex = "#000000"}
    }
}

-- Animation settings
config.animations = {
    -- Enable animations
    enabled = true,

    -- Default animation duration (seconds)
    default_duration = 0.2,

    -- Easing functions
    easing = {
        window_movement = "easeInOutQuad",
        fade = "linear",
        resize = "easeOutQuad"
    },

    -- Animation types
    types = {
        -- Window animations
        window = {
            movement = true,
            resize = true,
            focus = false
        },

        -- UI element animations
        ui = {
            fade = true,
            slide = true,
            scale = false
        }
    }
}

-- Font settings
config.fonts = {
    -- Default font family
    default = "System Font",

    -- Font sizes
    sizes = {
        small = 12,
        normal = 14,
        large = 18,
        xlarge = 24,
        xxlarge = 32
    },

    -- Font weights
    weights = {
        thin = "Thin",
        light = "Light",
        regular = "Regular",
        medium = "Medium",
        bold = "Bold"
    }
}

-- Display settings
config.display = {
    -- Multi-monitor behavior
    multi_monitor = {
        -- Focus follows mouse
        focus_follows_mouse = false,

        -- Window movement between displays
        cross_display_movement = true,

        -- Display arrangement detection
        auto_detect_arrangement = true,

        -- Default display for new windows
        default_display = "active"
    },

    -- Screen resolution handling
    resolution = {
        -- Scale UI elements for high DPI
        scale_for_high_dpi = true,

        -- Minimum screen width for responsive layout
        min_width = 1024,

        -- Minimum screen height for responsive layout
        min_height = 768
    }
}

-- Debug visual settings
config.debug = {
    -- Enable debug visualizations
    enabled = false,

    -- Show window frames
    show_window_frames = false,

    -- Show screen boundaries
    show_screen_boundaries = false,

    -- Show hotkey hints
    show_hotkey_hints = false,

    -- Debug colors
    colors = {
        window_frame = {hex = "#FF0000", alpha = 0.5},
        screen_boundary = {hex = "#00FF00", alpha = 0.5},
        hotkey_hint = {hex = "#0000FF", alpha = 0.5}
    }
}

return config