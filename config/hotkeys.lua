-- Hotkey configuration for Hammerspoon
-- User-editable key combinations are edited here; modules keep their own fallback defaults.

local config = {}

config.hotkeys = {
    system = {
        reload = {"ctrl", "cmd", "alt", "R"},
        console = {"ctrl", "cmd", "alt", "H"},
        expose = {"alt", "tab"}
    },

    window = {
        maximize = {"ctrl", "alt", "return"},
        center = {"ctrl", "alt", "c"},
        original = {"ctrl", "alt", "o"},
        left = {"ctrl", "alt", "left"},
        right = {"ctrl", "alt", "right"},
        up = {"ctrl", "alt", "up"},
        down = {"ctrl", "alt", "down"},
        quarter_left = {"ctrl", "alt", "shift", "left"},
        quarter_right = {"ctrl", "alt", "shift", "right"},
        quarter_up = {"ctrl", "alt", "shift", "up"},
        quarter_down = {"ctrl", "alt", "shift", "down"}
    },

    launcher = {
        apps = {
            vscode = {"cmd", "alt", "C"},
            qq = {"cmd", "alt", "Q"},
            wechat = {"cmd", "alt", "W"},
            dingtalk = {"cmd", "alt", "D"},
            chrome = {"cmd", "alt", "G"},
            finder = {"cmd", "alt", "F"},
            hammerspoon = {"cmd", "alt", "H"},
            wezterm = {"F10"},
        },
        restarts = {}
    },

    media = {
        controls = {
            previous = {"ctrl", "cmd", "alt", "left"},
            next = {"ctrl", "cmd", "alt", "right"},
            play = {"ctrl", "cmd", "alt", "space"},
            sound_up = {"ctrl", "cmd", "alt", "up"},
            sound_down = {"ctrl", "cmd", "alt", "down"},
        },
        system = {
            mute = {"ctrl", "cmd", "alt", "m"},
            brightness_down = {"ctrl", "cmd", "alt", "["},
            brightness_up = {"ctrl", "cmd", "alt", "]"},
            keyboard_backlight_down = {"ctrl", "cmd", "alt", ";"},
            keyboard_backlight_up = {"ctrl", "cmd", "alt", "'"},
        }
    },

    mouse = {
        modifier = {"fn", "ctrl"},
        speed_up = {"ctrl", "cmd", "alt", "="},
        speed_down = {"ctrl", "cmd", "alt", "-"},
        toggle_acceleration = {"ctrl", "cmd", "alt", "\\"},
    },

    display_layout = {
        repair_display_layout = {"ctrl", "cmd", "alt", "L"},
        toggle_second_external = {"ctrl", "cmd", "alt", "D"},
    },

    keycastr = {
        toggle = {"ctrl", "cmd", "alt", "k"},
        click_circle = {"ctrl", "cmd", "alt", "c"},
        continuous = {"ctrl", "cmd", "alt", "i"}
    },

    protection = {
        cmd_q = {"cmd", "q"},
        paste_defeat = {"cmd", "alt", "V"}
    },

    notch_hider = {
        toggle = {"ctrl", "alt", "cmd", "n"}
    }
}

config.hotkeys_announcements = {
    default = false,
    modules = {
        app_launcher = {channel = "alert", duration = 1.0}
    },
    bindings = {}
}

-- Hotkey descriptions for logging
config.hotkey_descriptions = {
    ["system.reload"] = "Reload Hammerspoon configuration",
    ["system.console"] = "Open Hammerspoon console",
    ["system.expose"] = "Open window switcher",

    ["window.left"] = "Move window to left half",
    ["window.right"] = "Move window to right half",
    ["window.up"] = "Move window to top half",
    ["window.down"] = "Move window to bottom half",
    ["window.maximize"] = "Maximize window",
    ["window.center"] = "Center window",
    ["window.original"] = "Restore window to original position",

    ["keycastr.toggle"] = "Toggle keystroke visualization",
    ["keycastr.click_circle"] = "Toggle click circle visualization",
    ["keycastr.continuous"] = "Toggle continuous input mode",

    ["notch_hider.toggle"] = "Toggle notch hider"
}

return config
