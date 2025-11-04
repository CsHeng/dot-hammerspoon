# Hotkey Utils

## Overview

`utils.hotkey_utils` centralizes all hotkey registration so modules can bind shortcuts without worrying about duplicate overlays or modifier parsing. The wrapper keeps our toast strategy consistent—descriptions are stamped into the hotkey logger for readable startup output while bindings are still created without the built-in alert.

## Core Responsibilities

- **Modifier Parsing**: Accepts both array-style (`{"ctrl","alt","k"}`) and table-style (`{modifiers = {...}, key = "k"}`) definitions.
- **Alert Control**: Writes descriptions into each binding's log string without activating the default `hs.hotkey` overlay; modules can opt-in via `use_hs_alert = true` when they want the overlay.
- **Lifecycle Hook**: Returns the binding object and supports `on_bind` callbacks for advanced scenarios.
- **Safety Checks**: Logs configuration mistakes (missing key, malformed modifiers, absent handler) so errors surface quickly.

## Usage Patterns

```lua
local hotkeys = require("utils.hotkey_utils")

-- Array-style specification with inline handler
hotkeys.bind({"ctrl", "alt"}, "k", {
    description = "Toggle Keystroke Visualizer", -- appears in logs; hs.alert remains silent
    pressed = function()
        keystroke_visualizer.toggleKeystrokes()
    end
})

-- Table-style specification loaded from config
local toggle_spec = config.get("hotkeys.keycastr.toggle") -- {"ctrl","cmd","alt","k"}
hotkeys.bind(toggle_spec, M.toggleKeystrokes)

-- Optional access to hs.hotkey's native alert
hotkeys.bind({"ctrl", "cmd", "alt"}, "n", {
    description = "Notch Hider",
    use_hs_alert = true,  -- now hs.hotkey shows its overlay
    pressed = notch_hider.toggle
})
```

## Parameters

| Option | Type | Default | Description |
| --- | --- | --- | --- |
| `description` | string | `nil` | Added to the binding's log string; retained as the alert message only when `use_hs_alert = true`. |
| `pressed` / `handler` | function | required | Primary callback when the key is pressed. |
| `released` | function | optional | Callback when the key is released. |
| `repeatFn` / `repeat_handler` / `repeated` | function | optional | Callback for key repeat events. |
| `use_hs_alert` | boolean | `false` | When `true`, forwards `description` so Hammerspoon shows its default overlay. |
| `on_bind` | function(binding) | optional | Invoked after the hotkey is bound; useful for storing or modifying the binding object. |

The function returns the `hs.hotkey` binding (or `nil` when the spec is invalid).

## Implementation Notes

- All modules now `require("utils.hotkey_utils")` instead of calling `hs.hotkey.bind` directly.
- When a hotkey is misconfigured (missing key or handler), bindings succeed with no-op callbacks but emit warnings to the per-module logger.
- Parsing is tolerant: `{modifiers = {"ctrl","alt"}, key = "k"}` and `{"ctrl","alt","k"}` both work, which keeps configuration files ergonomic.
- Shared helpers (`parseHotkey`) are exposed so modules can split modifiers/keys when they need to perform additional validation.

## Related Documentation

- [NotificationUtils.md](NotificationUtils.md) — details how toast notifications are displayed after hotkey handlers fire.
- Module docs referencing hotkeys:
  - [MediaControls.md](MediaControls.md)
  - [AppLauncher.md](AppLauncher.md)
  - [KeystrokeVisualizer.md](KeystrokeVisualizer.md)
  - [MouseManagement.md](MouseManagement.md)
