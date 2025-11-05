# Notification Utils

## Role
- Provides a unified layer over macOS notifications, alerts, and audio device feedback.

## Capabilities
- Send banner notifications via JavaScript for Automation, falling back to persistent notifications when necessary.
- Show lightweight alerts for quick confirmations (e.g., volume changes, toggle reminders).
- Discover and manipulate audio devices (mute/unmute, volume adjustments) with descriptive logging.
- Offer helper functions for locating built-in output devices to support automation modules.

## Configuration
- Audio automation modules (e.g., Wi-Fi automation) rely on these helpers but maintain their own configuration.
- Notification behaviour is controlled by callers; there is no dedicated configuration file for this utility.

## Entry Points
- Implementation: `utils/notification_utils.lua`.
- Consumers: `modules/media_controls.lua`, `modules/app_launcher.lua`, `modules/wifi_automation.lua`, and any module needing user-facing feedback.

## Observability
- Logs every notification attempt, including success/failure and fallback transitions.
- Audio helper methods log device names, volume levels, and mute state changes for traceability.

## Maintenance Notes
- Keep string escaping robust when updating the JXA helpers to avoid breaking notifications with special characters.
- Prefer these helpers over inline `hs.alert`/`hs.notify` calls so behaviour stays consistent and debuggable.
