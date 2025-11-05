# Wi-Fi Automation

## Role
- Automates audio behaviour and notifications based on network changes and location heuristics.

## Capabilities
- Monitor Wi-Fi/ethernet/vpn status and detect transitions between trusted and untrusted networks.
- Mute/unmute the built-in audio device, switch devices, or restore volume based on configured profiles.
- Optionally log and notify when network state changes, when work mode activates, or when location services fail.
- Maintain historical records of networks (when enabled) for diagnostics.

## Configuration
- `config/wifi.lua` defines monitored SSIDs, behaviour flags (`mute_on_work_networks`, `notify_on_change`, etc.), audio preferences, and notification toggles.
- `config/wifi.lua` also sets location handling, security options, and debugging verbosity.

## Entry Points
- Implementation: `modules/wifi_automation.lua`.
- Utilities: `utils/notification_utils.lua` (user feedback), `core/config_loader.lua` (profiles), `utils/app_utils.lua` (optional app integrations).

## Observability
- Logs transitions, audio operations, and location lookups under the `wifi_automation` logger.
- Warnings highlight missing devices or permission issues; alerts inform the user when significant automation occurs.
- Debug mode (configurable) increases verbosity for troubleshooting network edge cases.

## Maintenance Notes
- Treat SSID lists and behaviour toggles as configuration; avoid hardcoding environment-specific logic in the module.
- Keep location workarounds up to date with macOS changes; failures currently fall back to logging without breaking automation.
