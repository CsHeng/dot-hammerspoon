# Display Layout

## Role
- Repairs external display ordering and primary display selection using `displayplacer`.
- Mirrors/unmirrors the supported home/office second external display and runs best-effort input-source commands using `m1ddc`.
- Intended for setups where macOS occasionally flips left/right screens after wake.

## Capabilities
- Hotkey to re-apply the configured layout profile.
- Hotkey to mirror/unmirror the supported home/office second external display and send the Mac DP/HDMI input command. Switching away first saves non-Mac-input state, then sets mirror mode via `displayplacer`, then runs the `m1ddc` alternate-input command; switching back restores extended layout before the Mac-input command to avoid double flash.
- Auto-repair on wake/unlock and screen topology changes (with retry).

## Configuration
- `config/display_layout.lua` controls:
  - `profiles.home`: home (lid closed) dual-external layout.
  - `profiles.home_open`: home (lid open) internal + 2 externals layout (middle external is primary).
  - `auto_repair`: delay/retry policy.
  - `m1ddc.home_second_external_input_toggle`: home second external best-effort input command, values, and reconnect delay.
  - `m1ddc.office_second_external_input_toggle`: office second external best-effort input command, values, and reconnect delay.
- `config/hotkeys.lua` controls:
  - `hotkeys.display_layout.repair_display_layout`: layout repair hotkey.
  - `hotkeys.display_layout.toggle_second_external`: second external mirror/input-command hotkey for supported home/office profiles.

## Entry Points
- Implementation: `modules/display_layout.lua`.
- State machine: `docs/modules/diagrams/display_layout_state_machine.puml`.
- Hardware cabling: `docs/HardwareCabling.md`.

## Notes
- Profiles are matched by detected screen count + required screen ids; first match wins (see `display_layout.profile_order`).
- `hz` and `color_depth` are optional in `displayplacer`; omitting them lets the highest available mode win (useful when HDMI renegotiates).
- Auto-repair re-checks the saved input state when delayed repair attempts fire; non-hotkey repair is skipped while the second external is away from the Mac input.
- On the home path, the first external monitor remains on Mac DP and the second external monitor is the HDMI 2 alternate-input target (`18`). The monitor path is behind a Dell Thunderbolt dock and hardware KVM; DDC input commands can return success without physically switching the monitor input, so the stable workflow is mirror first, use the hardware KVM to leave the Mac path, then switch the KVM back before restoring extended layout.
- The desk cabling records KVM OUT HDMI1 feeding Monitor 2 HDMI2, while `pc-z490m` bypasses the KVM and uses a direct Monitor 2 input pending verification (`HDMI1` or `DP1`).
- Tool boundary: `displayplacer` repairs layout, origin, and main-display assignment; `m1ddc` only controls DDC features such as monitor input source.
