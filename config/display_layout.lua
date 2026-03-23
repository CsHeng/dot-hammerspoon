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
        repair_display_layout  = {"ctrl", "cmd", "alt", "L"},
        toggle_second_external = {"ctrl", "cmd", "alt", "D"},
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
    -- office / office_typec are the same physical screen via different input ports
    -- (DP→DP vs USB-C→internal DP); both produce identical layouts.
    -- *_open variants: MacBook lid open (internal display active).
    profile_order = {"home", "home_open", "office", "office_typec", "office_typec_open"},

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

        -- First external via DP→DP connection
        office = {
            enabled = true,
            require_total_screens = 2,

            screens = {
                {
                    id = "075DB5BC-C716-43A9-9B8F-74B020DAE11A",
                    res = "2560x1440",
                    scaling = "off",
                    origin = {0, 0}, -- main display (left)
                    degree = 0,
                    enabled = true,
                },
                {
                    id = "E5AD9F0D-0529-4234-ABF2-4053381A7C58",
                    res = "1920x1080",
                    scaling = "off",
                    origin = {2560, 0}, -- right
                    degree = 0,
                    enabled = true,
                },
            }
        },

        -- First external via USB-C→internal DP connection, lid closed
        office_typec = {
            enabled = true,
            require_total_screens = 2,

            screens = {
                {
                    id = "3C67BC99-4806-4DFE-878D-A6E51B4BE48D",
                    res = "2560x1440",
                    scaling = "off",
                    origin = {0, 0}, -- main display (left)
                    degree = 0,
                    enabled = true,
                },
                {
                    id = "E5AD9F0D-0529-4234-ABF2-4053381A7C58",
                    res = "1920x1080",
                    scaling = "off",
                    origin = {2560, 0}, -- right
                    degree = 0,
                    enabled = true,
                },
            }
        },

        -- First external via USB-C→internal DP connection, lid open (internal + 2 externals)
        office_typec_open = {
            enabled = true,
            require_total_screens = 3,

            screens = {
                {
                    id = "37D8832A-2D66-02CA-B9F7-8F30A301B230",
                    res = "1800x1169",
                    scaling = "on",
                    origin = {0, 0}, -- left (internal)
                    degree = 0,
                    enabled = true,
                },
                {
                    id = "3C67BC99-4806-4DFE-878D-A6E51B4BE48D",
                    res = "2560x1440",
                    scaling = "off",
                    origin = {1800, 0}, -- middle
                    degree = 0,
                    enabled = true,
                },
                {
                    id = "E5AD9F0D-0529-4234-ABF2-4053381A7C58",
                    res = "1920x1080",
                    scaling = "off",
                    origin = {4360, 0}, -- right
                    degree = 0,
                    enabled = true,
                },
            }
        }
    }
}

return config
