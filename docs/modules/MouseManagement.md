# Mouse Management

## Role
- Customises external mouse behaviour while leaving the trackpad untouched.
- Ships two variants: a default keystroke-driven version and a Mission Control-aware spaces version.

## Capabilities
- Reverse the vertical scroll axis for discrete mice without affecting trackpads.
- Map side buttons to shortcuts (Mission Control, application windows, navigation) with configurable modifier fallbacks.
- Provide utility hotkeys for placeholder features (speed/acceleration) and expose a paste-defeat binding for stubborn inputs.
- Offer programmatic helpers for centring the cursor, querying current position, and simulating mouse actions.

## Configuration
- `config/hotkeys.mouse.modifier` controls the modifier chord sent for side-button actions.
- `config/hotkeys.protection.paste_defeat` defines the paste-defeat shortcut.
- `config/mouse.management_module` selects between `modules.mouse_management` and `modules.mouse_management_spaces`.
- Toast visibility follows the shared `hotkeys.announcements` settings via `hotkey_utils`.

## Entry Points
- Default implementation: `modules/mouse_management.lua`.
- Spaces-aware implementation: `modules/mouse_management_spaces.lua`.
- Shared utilities: `utils/app_utils.lua` (browser detection), `utils/hotkey_utils.lua` (binding).

## Observability
- Logs describe button mappings during initialisation and record every tap-consumed event when running in debug mode.
- Deprecated API usage has been removed (`hs.mouse.absolutePosition` replaces `setAbsolutePosition`).
- Centering helpers remain callable (`mouse_management.centerMouseOnWindow()`) without a default hotkey and log their outcomes.

## Maintenance Notes
- Extend button assignments inside the setup functions; keep behaviour symmetric between default and spaces variants when possible.
- When implementing real mouse speed or acceleration changes, replace the placeholder handlers but preserve logging and alert structure.
