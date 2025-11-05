# App Launcher

## Role
- Provides high-speed keyboard access to frequently used applications.
- Consolidates restart workflows for brittle apps and implements Cmd+Q protection.

## Capabilities
- Launch/toggle configured apps with per-entry modifiers while respecting bundle identifiers.
- Restart “problematic” apps through a dedicated hotkey set.
- Guard against accidental quits by requiring a double press on Cmd+Q and surfacing guidance via notifications.

## Configuration
- `config/applications.lua` → `launcher_apps` and `problematic_apps` define key bindings and metadata.
- `config/hotkeys.lua` → `hotkeys.launcher.modifier` and `hotkeys.app_restart.modifier` provide defaults for entries that omit modifiers.
- Cmd+Q delay is fixed at 0.5 s in `modules/app_launcher.lua`; adjust here if behaviour needs to change globally.

## Entry Points
- Implementation: `modules/app_launcher.lua`.
- Utilities: `utils.app_utils.lua` (process control) and `utils.notification_utils.lua` (user feedback).
- Hotkey binding: `utils/hotkey_utils.lua` with `module = "app_launcher"` enabling selective overlays.

## Observability
- Logs every launch/toggle attempt, restart, and Cmd+Q protection event through the `app_launcher` logger.
- Launch hotkeys raise a toast only when a new process is started, keeping toggles silent during regular switching.
- Cmd+Q protection reminder uses `notification_utils.sendAlert`, ensuring visibility without cluttering the console.

## Maintenance Notes
- Add new launcher targets to `config/applications.lua` rather than modifying module logic.
- Bundle IDs are optional but recommended to avoid conflicts between similarly named apps.
- When introducing new launcher families, prefer extending configuration and reuse existing helper functions.
