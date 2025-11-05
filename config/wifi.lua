local config = {}

config.wifi = {
    muted_ssids = {
        ["Jiatu"] = true,
        ["Jiatu-Legacy"] = true,
        ["Shanqu"] = true,
    },

    behavior = {
        use_location_workaround = true,
        notify_on_change = true,
        mute_on_work_networks = true,
        unmute_on_leave = true,
        mute_delay = 0,
        unmute_delay = 1
    },

    monitoring = {
        enabled = true,
        check_interval = 5,
        monitor_wifi = true,
        monitor_ethernet = false,
        monitor_vpn = false,
        stable_threshold = 10
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
        ["Jiatu"] = {
            apps = {},
            audio = {
                mute_builtin = true,
                set_output_device = "Headphones"
            },
            status = "work"
        },

        ["Shanqu"] = {
            apps = {},
            audio = {
                mute_builtin = false,
                set_output_device = "Built-in"
            },
            status = "work"
        },

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
}

return config