# Notch Hider

## Role
- Draws a rounded overlay across the menu bar area of built-in displays to mask the camera notch.

## Capabilities
- Toggle the overlay on demand via the configured hotkey (`hotkeys.notch_hider.toggle`).
- Detect active display geometry and scale the canvas to match device-specific notch widths.
- Maintain overlay state across reloads to keep presentation consistent.

## Configuration
- `config/hotkeys.notch_hider.toggle` sets the shortcut for enabling or disabling the overlay.
- Visual parameters (colour, opacity) live directly in `modules/notch_hider.lua`; adjust there when the theme changes.

## Entry Points
- Implementation: `modules/notch_hider.lua`.
- Hotkey binding: `utils/hotkey_utils.lua` (module name `notch_hider`).

## Observability
- Logs each toggle along with display information under the `notch_hider` logger.
- Errors (e.g., missing screens) are surfaced as warnings, enabling quick troubleshooting.

## Maintenance Notes
- When adding new visual styles, keep drawing logic encapsulated in helper functions to avoid cluttering the toggle handler.
- Ensure the overlay behaves on multi-monitor setups by verifying screen detection logic whenever macOS display APIs change.
