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
- `config/applications.lua` → `media_controls` supplies action/key bindings for playback and volume.
- `config/hotkeys.media.modifier` defines default modifiers for media actions.
- Brightness and backlight hotkeys are fixed to the Hyper (`ctrl+cmd+alt`) modifier set in `modules/media_controls.lua`.

## Entry Points
- Implementation: `modules/media_controls.lua`.
- Utilities: `utils/notification_utils.lua` (alerts), `utils/hotkey_utils.lua` (binding), `utils/app_utils.lua` (where applicable).

## Observability
- Logs every media action and audio state change through `media_controls`.
- Alerts summarise the result of volume, mute, and playback changes for quick confirmation.
- Errors (missing audio device, unsupported brightness) are logged as warnings.

## Maintenance Notes
- Extend the `media_controls` configuration to add new system actions rather than hardcoding them.
- Keep placeholder functions (e.g., mouse speed adjustments) stubbed until a safe implementation is available.
