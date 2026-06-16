# Display Layout

## Role
- Repairs external display ordering and primary display selection using `displayplacer`.
- Toggles the supported home/office second external display's input source using `m1ddc`.
- Intended for setups where macOS occasionally flips left/right screens after wake.

## Capabilities
- Hotkey to re-apply the configured layout profile.
- Hotkey to switch the supported home/office second external display between the Mac DP input and HDMI. Switching to HDMI also sets mirror mode (via `displayplacer`) to collapse the desktop boundary; switching back restores extended layout before the input switch to avoid double flash.
- Auto-repair on wake/unlock and screen topology changes (with retry).

## Configuration
- `config/display_layout.lua` controls:
  - `profiles.home`: home (lid closed) dual-external layout.
  - `profiles.home_open`: home (lid open) internal + 2 externals layout (middle external is primary).
  - `auto_repair`: delay/retry policy.
  - `m1ddc.home_second_external_input_toggle`: home second external input command, values, and reconnect delay.
  - `m1ddc.office_second_external_input_toggle`: office second external input command, values, and reconnect delay.
- `config/hotkeys.lua` controls:
  - `hotkeys.display_layout.repair_display_layout`: layout repair hotkey.
  - `hotkeys.display_layout.toggle_second_external`: second external input toggle hotkey for supported home/office profiles.

## Entry Points
- Implementation: `modules/display_layout.lua`.

## Notes
- Profiles are matched by detected screen count + required screen ids; first match wins (see `display_layout.profile_order`).
- `hz` and `color_depth` are optional in `displayplacer`; omitting them lets the highest available mode win (useful when HDMI renegotiates).
- Tool boundary: `displayplacer` repairs layout, origin, and main-display assignment; `m1ddc` only controls DDC features such as monitor input source.
