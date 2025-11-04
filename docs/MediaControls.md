# Media Controls

## Overview

`modules.media_controls` exposes hotkeys for media playback, volume, display brightness, and audio device cycling. Handlers use `notification_utils.sendAlert` to provide quick feedback (e.g., “Volume: 55%”) while the `hotkey_utils` wrapper prevents Hammerspoon from showing duplicate overlays and keeps the console annotated with each shortcut’s description.

## Hotkeys

Hotkeys are a blend of configuration-driven entries and fixed system controls:

| Shortcut | Source | Action |
| --- | --- | --- |
| `ctrl+cmd+alt+left` | `config.applications.media_controls` | Send `PREVIOUS` system media key. |
| `ctrl+cmd+alt+right` | same | Send `NEXT` system media key. |
| `ctrl+cmd+alt+space` | same | Toggle play/pause. |
| `ctrl+cmd+alt+up` | same | Send `SOUND_UP` system media key. |
| `ctrl+cmd+alt+down` | same | Send `SOUND_DOWN` system media key. |
| `ctrl+cmd+alt+m` | module-defined | Toggle mute on the default output device. |
| `ctrl+cmd+alt+[` | module-defined | Decrease display brightness using `hs.brightness`. |
| `ctrl+cmd+alt+]` | module-defined | Increase display brightness. |
| `ctrl+cmd+alt+;` | module-defined | Attempt to dim keyboard backlight (currently logs + toast about unsupported operation). |
| `ctrl+cmd+alt+'` | module-defined | Attempt to brighten keyboard backlight (same caveat). |

You can add or remove entries in `config/applications.media_controls`; every entry must include `modifier`, `key`, and `action` fields that correspond to Hammerspoon’s system key event constants.

## Feedback Strategy

- **Media key senders (`sendMediaKeyEvent`)**: Show `Media: <ACTION>` toast after a successful system key event.
- **Volume adjustments (`adjustVolume`)**: Report the new percentage (`Volume: 55%`).
- **Mute toggle**: Indicates `Audio: Muted` / `Audio: Unmuted`.
- **Brightness**: Emits `Brightness: <value>%`.
- **Keyboard backlight**: Placeholder toast `Keyboard backlight not available`.
- **Output device cycling (`cycleOutputDevices`)**: Shows the name of the newly-selected device.

All notifications are routed through `notification_utils.sendAlert`, so durations stay short (0.5–1.0 s) and centered.

## Configuration Tips

`core.config_loader` merges configuration files with sensible defaults, so `config/applications.lua` can override or extend the base set:

```lua
media_controls = {
    {modifier = {"ctrl", "cmd", "alt"}, key = 'space', action = 'PLAY'},
    {modifier = {"ctrl", "cmd", "alt"}, key = 'f8', action = 'PLAY'},  -- extra binding
}
```

Bindings are applied verbatim, so ensure modifiers and keys are valid Hammerspoon hotkey arguments.

## API Reference

| Function | Description |
| --- | --- |
| `M.init()` | Registers hotkeys for media controls, mute toggle, brightness, and keyboard backlight stubs. |
| `M.setupMediaHotkeys()` | Iterates over `config.applications.media_controls` and binds each entry through `hotkey_utils`. |
| `M.setupAudioControls()` | Adds the mute toggle hotkey. |
| `M.setupSystemControls()` | Adds brightness and keyboard backlight hotkeys. |
| `M.sendMediaKeyEvent(action)` | Posts the system key down/up sequence with a small delay. |
| `M.adjustVolume(delta)` | Adjusts the default output device volume (0–1 range). |
| `M.toggleMute()` | Toggles mute and sends a toast. |
| `M.cycleOutputDevices()` | Switches to the next available output device; returns `true` on success. |
| `M.adjustBrightness(delta)` | Reads, updates, and reports display brightness. |
| `M.adjustKeyboardBacklight(delta)` | Placeholder that only logs and displays a toast. |
| `M.getStatus()` | Returns a table summarizing current device/brightness info. |
| `M.debug()` | Logs a diagnostics block for troubleshooting. |

## Implementation Notes

- The module relies on `hs.eventtap.event.newSystemKeyEvent` for media actions so third-party players respond promptly.
- `hs.brightness` is available only on supported hardware; `adjustBrightness` guards against missing APIs gracefully.
- Keyboard backlight adjustments require privileged tools; the current implementation simply informs the user that the feature is unavailable.
- `hotkey_utils.bind` keeps hotkey registration consistent, logs descriptive shortcut names, and avoids duplicate alerts.
