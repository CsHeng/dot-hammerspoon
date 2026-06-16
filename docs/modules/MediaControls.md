# Media Controls

## Role
- Provides keyboard-driven control over media playback, system volume, brightness, and keyboard backlight.
- Keeps feedback lightweight by using alerts only when actions complete successfully.

## Capabilities
- Map configurable hotkeys to system media keys (play/pause, next, previous, volume up/down).
- Toggle mute on the default output device and display status notification.
- Adjust screen brightness and keyboard backlight in small increments.
- Integrate with application-specific media control entries defined in configuration.

## Configuration
- `config/applications.lua` → `media_controls` supplies action metadata with stable `id` values.
- `config/hotkeys.lua` → `hotkeys.media.controls.<id>` defines playback and volume key bindings.
- `config/hotkeys.lua` → `hotkeys.media.system.*` defines mute, brightness, and keyboard-backlight key bindings.

## Entry Points
- Implementation: `modules/media_controls.lua`.
- Utilities: `utils/notification_utils.lua` (alerts), `utils/hotkey_utils.lua` (binding), `utils/app_utils.lua` (where applicable).

## Observability
- Logs every media action and audio state change through `media_controls`.
- Toasts are dispatched via `notification_utils.announce`, summarising volume, mute, and playback changes with per-binding identifiers.
- Errors (missing audio device, unsupported brightness) are logged as warnings.

## Maintenance Notes
- Extend `config/applications.lua` and `config/hotkeys.lua` together when adding new media actions.
- Keep placeholder functions (e.g., mouse speed adjustments) stubbed until a safe implementation is available.
