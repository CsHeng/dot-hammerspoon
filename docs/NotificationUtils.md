# Notification Utils

## Overview

`utils.notification_utils` provides helpers for toast alerts, macOS banners, and audio device feedback. Feature modules (Wi-Fi automation, media controls, app launcher) depend on these utilities to keep user messaging consistent.

## Toasts vs. Notifications

| Helper | UI | Typical Use |
| --- | --- | --- |
| `sendAlert(message, duration)` | Hammerspoon toast centered on the primary display | Instant feedback after hotkeys (volume, app launch, protection prompts). |
| `sendNotification(title, message, method)` | macOS `display notification` banner (fallback to `hs.notify`) | Default path for Wi-Fi and automation updates. |
| `sendPersistentNotification(title, message)` | Sticky `hs.notify` banner | Rare events that must remain visible until dismissed. |
| `sendMacOSNotification(title, message)` | macOS `display notification` banner | Explicit request for the macOS-style banner. |

`sendNotification("auto")` sends a standard macOS banner via AppleScript so the message appears in the top-right corner before rolling into Notification Center. If AppleScript cannot run (automation permissions revoked, etc.), the helper falls back to a persistent `hs.notify` banner.

## Audio Helpers

The module also exposes a handful of audio utilities so media and Wi-Fi automation can share the same logic:

- `getBuiltinOutputDevice()` — locate the built-in speakers (returns the `hs.audiodevice` object or `nil`).
- `setAudioVolume(device, volume?, mute?)` — update volume/mute state and emit a notification confirming the change.
- `toggleBuiltinAudioMute()` — mute/unmute the built-in output device with feedback when the device is missing.
- `getAudioDeviceInfo()` — gather default/built-in input and output device metadata for dashboards or debugging.

## API Reference

### `sendAlert(message, duration?)`

Displays a centered toast. Duration defaults to two seconds.

```lua
local notification_utils = require("utils.notification_utils")
notification_utils.sendAlert("Launched: Ghostty", 1.0)
```

### `sendNotification(title, message?, method?)`

Triggers a notification according to the requested method. `"auto"` (default) uses AppleScript first and falls back to a persistent notification if it fails. Pass `"macos"` to force AppleScript or `"persistent"` to keep the message in Notification Center only.

```lua
notification_utils.sendNotification("Audio", "Volume: 50%", "auto")
```

### `sendPersistentNotification(title, message?)`

Creates a non-expiring notification using `hs.notify`.

```lua
notification_utils.sendPersistentNotification("Wi-Fi", "Work network detected")
```

### `sendMacOSNotification(title, message?)`

Uses AppleScript’s `display notification` so the banner appears in the top-right corner before rolling into Notification Center.

```lua
notification_utils.sendMacOSNotification("Module Reloaded", "Keystroke visualizer restarted")
```

### `getBuiltinOutputDevice()`

Returns the built-in output `hs.audiodevice` instance or `nil`.

```lua
local builtin = notification_utils.getBuiltinOutputDevice()
if builtin then
    print("Built-in device:", builtin:name())
end
```

### `setAudioVolume(device, volume?, mute?)`

Updates volume/mute and emits a summary notification when successful. Accepts `volume` in the 0–1 range.

```lua
local device = hs.audiodevice.defaultOutputDevice()
notification_utils.setAudioVolume(device, 0.4)        -- 40% volume
notification_utils.setAudioVolume(device, nil, true)  -- mute
```

### `toggleBuiltinAudioMute()`

Toggles mute on the built-in device; shows a notification if the device cannot be located.

```lua
notification_utils.toggleBuiltinAudioMute()
```

### `getAudioDeviceInfo()`

Collects info about all input/output devices, including flags for default/built-in devices.

```lua
local info = notification_utils.getAudioDeviceInfo()
print(hs.inspect(info.default_output))
```

## Integration Notes

- Feature modules register hotkeys via `hotkey_utils.bind` and rely on `sendAlert` for fast feedback.
- `sendNotification` keeps Wi-Fi and audio automation surfaced via the system banner without duplicate Hammerspoon overlays.
- Audio helpers avoid side effects unless a notification makes sense, keeping them safe for diagnostics and dashboards.
