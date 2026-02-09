-- Display layout configuration (displayplacer-based)
-- Home profiles are configured for dual 2560x1440 external monitors:
-- - Lid closed: 2 screens (external-only)
-- - Lid open: 3 screens (internal + 2 externals), with the middle external as primary

local config = {}

config.display_layout = {
    enabled = true,

    displayplacer = {
        paths = {
            "/opt/homebrew/bin/displayplacer",
            "/usr/local/bin/displayplacer",
        }
    },

    -- Hotkeys
    hotkeys = {
        -- Reuses the old Ctrl+Cmd+Alt+D chord
        repair_home = {"ctrl", "cmd", "alt", "D"},
    },

    -- Automatic repair (wake/unlock/screen topology change)
    auto_repair = {
        enabled = true,
        delay_seconds = 2.0,
        retry_interval_seconds = 2.0,
        max_attempts = 3,
    },

    notifications = {
        show_on_hotkey = true,
        show_on_auto_repair = false,
    },

    -- Deterministic profile priority when multiple profiles match.
    profile_order = {"home", "home_open", "office"},

    profiles = {
        home = {
            enabled = true,

            -- Safety: only auto-apply when exactly 2 screens are detected (no internal display).
            -- This matches the "lid closed" setup and avoids re-arranging when the internal
            -- display is open. Adjust later if needed.
            require_total_screens = 2,

            -- NOTE: hz/color_depth are intentionally omitted so displayplacer picks the
            -- highest available (helps when HDMI renegotiates to lower refresh rates).
            screens = {
                {
                    id = "F612A96D-269C-436C-92B1-E8C47E6272E6",
                    res = "2560x1440",
                    scaling = "off",
                    origin = {0, 0}, -- main display
                    degree = 0,
                    enabled = true,
                },
                {
                    id = "D0627D9C-EEDB-417D-88ED-C5FE3663710D",
                    res = "2560x1440",
                    scaling = "off",
                    origin = {2560, 0},
                    degree = 0,
                    enabled = true,
                },
            }
        },

        home_open = {
            enabled = true,

            -- Lid open: internal + 2 externals. Make the middle external the primary display.
            require_total_screens = 3,

            screens = {
                {
                    id = "F612A96D-269C-436C-92B1-E8C47E6272E6",
                    res = "2560x1440",
                    scaling = "off",
                    origin = {0, 0}, -- main display (middle)
                    degree = 0,
                    enabled = true,
                },
                {
                    id = "37D8832A-2D66-02CA-B9F7-8F30A301B230",
                    res = "1512x982",
                    scaling = "on",
                    origin = {-1512, 0}, -- left (internal)
                    degree = 0,
                    enabled = true,
                },
                {
                    id = "D0627D9C-EEDB-417D-88ED-C5FE3663710D",
                    res = "2560x1440",
                    scaling = "off",
                    origin = {2560, 0}, -- right
                    degree = 0,
                    enabled = true,
                },
            }
        },

        -- Placeholder for office profile (fill in tomorrow).
        office = {
            enabled = false,
            screens = {}
        }
    }
}

return config
