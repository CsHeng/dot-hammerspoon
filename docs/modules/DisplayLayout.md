# Display Layout

## Role
- Repairs external display ordering and primary display selection using `displayplacer`.
- Intended for setups where macOS occasionally flips left/right screens after wake.

## Capabilities
- Hotkey to re-apply the configured layout profile.
- Auto-repair on wake/unlock and screen topology changes (with retry).

## Configuration
- `config/display_layout.lua` controls:
  - `profiles.home`: home (lid closed) dual-external layout.
  - `profiles.home_open`: home (lid open) internal + 2 externals layout (middle external is primary).
  - `auto_repair`: delay/retry policy.
  - `hotkeys.repair_home`: layout repair hotkey.

## Entry Points
- Implementation: `modules/display_layout.lua`.

## Notes
- Profiles are matched by detected screen count + required screen ids; first match wins (see `display_layout.profile_order`).
- `hz` and `color_depth` are optional in `displayplacer`; omitting them lets the highest available mode win (useful when HDMI renegotiates).
