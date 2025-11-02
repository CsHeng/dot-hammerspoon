-- Hotkey configuration for Hammerspoon
-- All hotkey definitions are centralized here for easy customization

local config = {}

-- System hotkeys
config.hotkeys = {
    system = {
        reload = {"ctrl", "cmd", "alt", "R"},
        console = {"ctrl", "cmd", "alt", "H"},
        expose = {"alt", "tab"}
    },

    window = {
        hyper = {"ctrl", "alt"},
        hyper_shift = {"ctrl", "alt", "shift"},
        maximize = {"ctrl", "alt", "return"},
        center = {"ctrl", "alt", "c"},
        original = {"ctrl", "alt", "o"},

        -- Arrow keys for positioning
        left = {"ctrl", "alt", "left"},
        right = {"ctrl", "alt", "right"},
        up = {"ctrl", "alt", "up"},
        down = {"ctrl", "alt", "down"},

        -- Quarter positions with shift
        quarter_left = {"ctrl", "alt", "shift", "left"},
        quarter_right = {"ctrl", "alt", "shift", "right"},
        quarter_up = {"ctrl", "alt", "shift", "up"},
        quarter_down = {"ctrl", "alt", "shift", "down"}
    },

    launcher = {
        modifier = {"cmd", "alt"}
    },

    media = {
        modifier = {"ctrl", "cmd", "alt"},
        previous = {"ctrl", "cmd", "alt", "left"},
        next = {"ctrl", "cmd", "alt", "right"},
        play = {"ctrl", "cmd", "alt", "space"},
        volume_up = {"ctrl", "cmd", "alt", "up"},
        volume_down = {"ctrl", "cmd", "alt", "down"}
    },

    app_restart = {
        modifier = {"ctrl", "cmd", "alt"}
    },

    mouse = {
        modifier = {"fn", "ctrl"}
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