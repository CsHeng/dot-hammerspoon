# Notch Hider Module

The notch hider module applies a configurable black overlay across the macOS menu bar area of the built-in display. It mimics tools like TopNotch by hiding the camera notch, matching rounded-corner wallpaper edges, and staying above desktop elements without capturing pointer events.

## Overview

- Module file: `modules/notch_hider.lua`
- Default hotkey: `ctrl+alt+cmd+N`
- Depends on: `config.hotkeys`, `core.logger`, `core.config_loader`, `hs.canvas`, `hs.screen`

## Features

- Detects the built-in notch display automatically and optionally by UUID.
- Draws a canvas overlay with adjustable corner radius, overscan, opacity, and height.
- Stays click-through so menu bar interaction remains unaffected.
- Tracks display changes with `hs.screen.watcher` to rebuild the overlay when monitors are rearranged.
- Supports auto-enable via configuration and exposes `show`, `hide`, and `toggle` helpers.

## Hotkeys

Configure in `config/hotkeys.lua` under `notch_hider.toggle`. The default binding is:

```lua
{"ctrl", "alt", "cmd", "n"}
```

## Configuration

Add overrides in `config/notch_hider.lua` (create if missing) using the following keys:

| Key | Type | Default | Description |
| --- | --- | --- | --- |
| `enabled` | boolean | `false` | Auto-enable on load. |
| `auto_hide` | boolean | `true` | Rebuild overlay when display setup changes. |
| `cover_height` | number | `40` | Vertical size of the covered menu bar region. |
| `opacity` | number | `1.0` | Alpha of the overlay fill. |
| `corner_radius` | number | `18` | Rounded corner radius for the top edge. |
| `overscan` | number | `8` | Extra horizontal padding to hide wallpaper bleed. |
| `screen_uuid` | string/`false` | `false` | Force a specific display UUID when auto-detection is unreliable. |

Example configuration:

```lua
return {
  notch_hider = {
    enabled = true,
    corner_radius = 22,
    overscan = 10,
    opacity = 0.98
  }
}
```

## API

The module exports a simple interface:

```lua
local notch_hider = require("modules.notch_hider")

notch_hider.show()
notch_hider.hide()
notch_hider.toggle()
local status = notch_hider.getStatus()
```

`status` returns:

```lua
{
  active = boolean,
  hasNotchScreen = boolean,
  windowExists = boolean
}
```

## Troubleshooting

- **Overlay not appearing**: Ensure the built-in display is active or set `screen_uuid` to the display's UUID (find via Hammerspoon console `hs.screen.allScreens()` output).
- **Wallpaper bleed visible**: Increase `overscan` or `corner_radius` until the menu bar aligns with the overlay.
- **Hotkey conflict**: Update `config/hotkeys.lua` to a preferred modifier/key combination.

Reload the configuration with `ctrl+cmd+alt+R` after changing settings.
