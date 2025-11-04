# App Launcher

## Overview

`modules.app_launcher` provides fast hotkeys for launching, focusing, or hiding applications. It relies on `utils.hotkey_utils` to bind shortcuts without duplicate overlays while stamping descriptive entries into the Hammerspoon console, and it uses `notification_utils.sendAlert` for the handful of moments where feedback matters (for example, confirming a brand-new launch or reminding the user about Cmd+Q protection).

## Hotkeys

| Shortcut | Behavior | Notes |
| --- | --- | --- |
| `cmd+alt+<key>` | Launch/toggle a configured application | Modifiers can be overridden per entry in `config/applications.lua`. |
| `ctrl+cmd+alt+<key>` | Restart a “problematic” application | Invokes `restartApp` for apps that occasionally hang. |
| `cmd+Q` | Protected quit | First press arms a timer and shows “Press Cmd+Q again to quit”; the second press within 0.5 s kills the frontmost app. |

All bindings are registered through `hotkey_utils.bind`, so Hammerspoon’s built-in alert is suppressed, the log still lists each shortcut by description, and only our explicit toast (when any) is displayed.

## Smart Toggle Behavior

`launchOrToggleApp` examines the application state via `utils.app_utils`:

- **Not running** → Launches the app and shows `Launched: <Name>` toast.
- **Running in background** → Activates the app (no toast).
- **Frontmost** → Hides it (no toast).

Every launcher entry may specify a `bundleid`, ensuring the toggle works even when multiple apps share similar names.

## Configuration

`config/applications.lua` is merged with defaults from `core.config_loader`. The relevant sections are:

```lua
config.applications = {
    launcher_apps = {
        {modifier = {"cmd", "alt"}, key = 'C', appname = 'Cursor', bundleid = 'com.todesktop.230313mzl4w4u92'},
        -- …
    },
    media_controls = { ... },    -- consumed by modules.media_controls
    problematic_apps = {
        {modifier = {"ctrl", "cmd", "alt"}, key = 'D', appname = 'DisplayLink Manager', bundleid = 'com.displaylink.DisplayLinkUserAgent'},
    }
}
```

Missing modifiers default to the configured launcher or restart modifier; missing descriptions are fine because `hotkey_utils` keeps the binding discoverable through logs instead of onscreen popups.

## API Reference

| Function | Description |
| --- | --- |
| `M.init()` | Registers hotkeys for launchers, restarts, and Cmd+Q protection. Called automatically by `core.init_system`. |
| `M.launchOrToggleApp(app_name, bundle_id?)` | Implements the smart toggle logic described above. |
| `M.launchApp(identifier)` | Launches/focuses an app by name or bundle ID. |
| `M.restartApp(app_name, bundle_id?)` | Kills and relaunches the app with a short delay. |
| `M.killApp(identifier, force?)` | Forces or requests termination of the specified app. |
| `M.hideApp(identifier)` | Hides the given app using `app_utils`. |
| `M.focusApp(identifier)` | Brings the app to the foreground. |
| `M.listRunningApps()` | Returns metadata for currently running applications. |
| `M.findApp(search_term)` | Finds applications by partial name or bundle ID. |
| `M.cycleApps(direction, app_filter?)` | Cycle through running apps that match an optional predicate. |
| `M.launchStartupApps()` | Launches apps listed under `config.applications.startup`. |
| `M.getStatus()` | Returns diagnostics summarizing launcher/modifier usage. |
| `M.debug()` | Logs a readable status block to help troubleshoot configuration. |

## Cmd+Q Protection Flow

1. First `cmd+Q` press starts a 0.5 s timer and shows the reminder toast.
2. Second press within the window calls `app:kill()` on the frontmost app.
3. If the timer expires, protection resets silently.

The handler uses `hotkey_utils.parseHotkey` to split modifiers and key from the configured combination, making customization safe.

## Related Modules

- **`utils.app_utils`** — centralizes application detection, activation, and restart helpers.
- **`utils.hotkey_utils`** — binds all launcher hotkeys and suppresses duplicate alerts.
- **`utils.notification_utils`** — provides the toast used for launch confirmations and Cmd+Q prompts.
