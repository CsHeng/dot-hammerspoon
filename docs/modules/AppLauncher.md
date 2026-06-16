# App Launcher

## Role
- Provides high-speed keyboard access to frequently used applications.
- Consolidates restart workflows for brittle apps and implements Cmd+Q protection.

## Capabilities
- Launch/toggle configured apps with per-entry modifiers while respecting bundle identifiers.
- Restart “problematic” apps through a dedicated hotkey set.
- Guard against accidental quits by requiring a double press on Cmd+Q and surfacing guidance via notifications.

## WezTerm (F10) Flow
- Binding: `config/applications.lua` registers `F10` as a launcher entry for WezTerm. The previous kitty entry remains commented out for rollback.
- Trigger: the hotkey handler in `modules/app_launcher.lua` calls `M.launchOrToggleApp()`.
- Toggle implementation: `utils/app_utils.toggleApp()` checks the running app via `hs.application` APIs (no local caching).
  - If WezTerm is frontmost and has a visible, non-minimised window: hide it.
  - Otherwise: unhide/unminimise (if needed), activate, and focus/raise the main window.

## Configuration
- `config/applications.lua` → `launcher_apps` and `problematic_apps` define application metadata with stable `id` values.
- `config/hotkeys.lua` → `hotkeys.launcher.apps.<id>` and `hotkeys.launcher.restarts.<id>` define key bindings.
- `config/hotkeys.lua` → `hotkeys.protection.cmd_q` defines Cmd+Q protection.
- Cmd+Q delay is fixed at 0.5 s in `modules/app_launcher.lua`; adjust here if behaviour needs to change globally.

## Entry Points
- Implementation: `modules/app_launcher.lua`.
- Utilities: `utils.app_utils.lua` (process control) and `utils.notification_utils.lua` (user feedback).
- Hotkey binding: `utils/hotkey_utils.lua` with `module = "app_launcher"` enabling selective overlays.

## Observability
- Logs every launch/toggle attempt, restart, and Cmd+Q protection event through the `app_launcher` logger.
- Launch hotkeys raise an `notification_utils.announce` toast only when a new process starts, keeping regular toggles silent.
- Cmd+Q protection reminder uses `notification_utils.announce` with a dedicated binding id so the prompt can be configured independently of other module toasts.

## Maintenance Notes
- Add new launcher targets to `config/applications.lua` and add matching key bindings to `config/hotkeys.lua`.
- Bundle IDs are optional but recommended to avoid conflicts between similarly named apps.
- When introducing new launcher families, prefer extending configuration and reuse existing helper functions.
