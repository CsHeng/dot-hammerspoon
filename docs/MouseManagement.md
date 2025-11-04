# Mouse Management

## Overview

`modules.mouse_management` customizes external mouse behaviour while leaving the trackpad untouched. It reverses scroll direction for “discrete” devices, maps side buttons to Exposé-style shortcuts, registers utility hotkeys, and provides a paste-defeat helper for stubborn input fields. A spaces-aware variant (`modules.mouse_management_spaces`) ships alongside the default module and implements the same user-facing shortcuts with Mission Control integration.

## Features

### Scroll Reversal

- `setupScrollReversal()` installs an `hs.eventtap` watcher that flips the vertical axis for scroll-wheel events reported as non-continuous (hardware mice).
- Trackpad gestures remain unaffected because they report as continuous events.

### Button Bindings

Default mappings (configurable via `hotkeys.mouse.modifier`, default `{"fn","ctrl"}`):

| Button | Behaviour |
| --- | --- |
| 2 (back) | Sends modifier + `up` (Mission Control-style). Suppressed inside browsers using `app_utils.isBrowser()`. |
| 3 (forward) | Sends modifier + `right` (Application windows). |
| 4 | Sends modifier + `left`. |

The spaces variant uses Mission Control APIs (`hs.spaces`) when available, otherwise falls back to the same keystrokes.

### Utility Hotkeys

| Shortcut | Action | Notes |
| --- | --- | --- |
| `ctrl+cmd+alt+=` | `adjustMouseSpeed(0.1)` | Placeholder that currently shows “Mouse speed adjustment not available”. |
| `ctrl+cmd+alt+-` | `adjustMouseSpeed(-0.1)` | Same placeholder. |
| `ctrl+cmd+alt+\` | `toggleMouseAcceleration()` | Placeholder toast. |
| `ctrl+cmd+alt+m` | `centerMouseOnWindow()` | Moves cursor to the focused window centre. |

All hotkeys are bound via `hotkey_utils`, so the console lists descriptive shortcut names while only our custom toasts appear.

### Paste Defeat

`setupPasteDefeat()` binds the configured shortcut (default `cmd+alt+V`) and simulates keystrokes using the pasteboard contents. This bypasses “paste prevention” logic in some applications while logging outcomes for diagnostics.

### Diagnostics

- `getMouseInfo()` reports absolute coordinates and the active screen name.
- `getStatus()` returns a table summarizing whether scroll reversal/button taps are running, along with the last known mouse position.
- `debug()` logs a human-readable block that includes display metrics.
- `stop()` and `restart()` manage the event taps manually (rarely needed outside debugging).

## Alternate Module (`mouse_management_spaces.lua`)

The spaces-aware module keeps the same hotkeys and paste defeat binding but swaps out button actions to drive Mission Control/Spaces transitions directly via `hs.spaces`. It falls back to the modifier keystrokes when the API is unavailable (e.g., on macOS versions that restrict access).

## Configuration

Relevant entries in `config/hotkeys.lua`:

```lua
mouse = {
    modifier = {"fn", "ctrl"},
}

protection = {
    paste_defeat = {"cmd", "alt", "V"},
}
```

You can swap between the default and spaces variant by changing `mouse.management_module` in configuration:

```lua
mouse = {
    management_module = "modules.mouse_management_spaces"
}
```

`core.init_system` reads this value during startup and loads the appropriate module.

## Implementation Notes

- Event taps are stopped before being replaced or during cleanup to avoid duplicate handlers.
- Mission-Control keystrokes are configurable only through the shared modifier key; remapping to different functions can be done by editing the handler inside `setupMouseButtons`.
- Placeholder alerts for speed/acceleration are deliberate; real implementations commonly require elevated privileges or `defaults write` commands we avoid triggering automatically.
