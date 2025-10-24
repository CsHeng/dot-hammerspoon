-- WiFi and network configuration for Hammerspoon
-- All network-related settings are centralized here

local config = {}

-- WiFi automation settings
config.wifi = {
    -- Networks where built-in audio should be muted (work networks)
    muted_ssids = {
        ["Jiatu"] = true,
        ["Jiatu-Legacy"] = true,
        ["Shanqu"] = true,
    },

    -- Network change behavior
    behavior = {
        -- Enable location services workaround
        use_location_workaround = true,

        -- Send notifications on network changes
        notify_on_change = true,

        -- Mute audio on work networks
        mute_on_work_networks = true,

        -- Auto-unmute when leaving work networks
        unmute_on_leave = true,

        -- Delay before muting/unmuting (seconds)
        mute_delay = 0,
        unmute_delay = 1
    }
}

-- Location service settings for network detection workaround
config.location = {
    -- Enable location services (required for network detection on some systems)
    enabled = true,

    -- Location update interval (seconds)
    update_interval = 300,

    -- Timeout for location requests (seconds)
    timeout = 10,

    -- Log location information
    log_location = false
}

-- Network monitoring settings
config.monitoring = {
    -- Enable WiFi watcher
    enabled = true,

    -- Check interval for network status (seconds)
    check_interval = 5,

    -- Network types to monitor
    monitor_wifi = true,
    monitor_ethernet = false,
    monitor_vpn = false,

    -- Threshold for considering a network as "stable"
    stable_threshold = 10 -- seconds
}

-- Audio device settings for work networks
config.audio = {
    -- Target audio device for muting
    target_device = "builtin", -- "builtin" or specific device name

    -- Volume level to restore when unmuting
    restore_volume = 0.5, -- 0.0 to 1.0

    -- Fade audio when muting/unmuting
    fade_duration = 0.5, -- seconds

    -- Show volume change notifications
    show_notifications = true
}

-- Application settings for different networks
config.network_profiles = {
    -- Define application configurations for different networks
    ["Jiatu"] = {
        -- Work network profile
        apps = {
            -- {bundleid = "com.slack", launch = true},
            -- {bundleid = "com.microsoft.teams", launch = true}
        },
        audio = {
            mute_builtin = true,
            set_output_device = "Headphones"
        },
        status = "work"
    },

    ["Shanqu"] = {
        -- Home network profile
        apps = {
            -- {bundleid = "com.spotify", launch = true}
        },
        audio = {
            mute_builtin = false,
            set_output_device = "Built-in"
        },
        status = "home"
    },

    default = {
        -- Default profile for unknown networks
        apps = {},
        audio = {
            mute_builtin = false,
            set_output_device = "Built-in"
        },
        status = "unknown"
    }
}

-- Notification settings
config.notifications = {
    -- Notification types
    network_change = true,
    work_mode = true,
    audio_mute = true,

    -- Notification methods
    use_persistent = true,
    use_macos = true,

    -- Custom messages
    messages = {
        connected = "%s Connected",
        disconnected = "%s Disconnected",
        work_mode = "Work Mode: %s, Built-in Audio Muted (%s)",
        device_not_found = "Work Mode: %s, Built-in Audio Device Not Found"
    }
}

-- Security and privacy settings
config.security = {
    -- Log SSIDs (be careful with sensitive network names)
    log_ssids = true,

    -- Store network history
    store_history = true,

    -- Maximum history entries
    max_history_entries = 100,

    -- Exclude these SSIDs from logs
    excluded_ssids = {
        -- Add sensitive network names here
    }
}

-- Debug settings
config.debug = {
    -- Enable debug logging
    enabled = false,

    -- Log network details
    log_network_details = false,

    -- Log audio device operations
    log_audio_operations = false,

    -- Log location service operations
    log_location_operations = false,

    -- Test mode (don't actually change audio)
    test_mode = false
}

return config