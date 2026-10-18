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
- Implementation: [modules/display_layout.lua](../../modules/display_layout.lua).
- State machine: [display_layout_state_machine.puml](diagrams/display_layout_state_machine.puml).
- Hardware cabling: [HardwareCabling.md](../HardwareCabling.md).

## Home Profiles And Refresh Rates
- Profiles are matched by detected screen count + required screen ids; first match wins (see `display_layout.profile_order`). `home` requires exactly two screens; `home_open` requires three.
- Both home profiles place external `F612A96D-269C-436C-92B1-E8C47E6272E6` at `(0,0)` as primary and external `D0627D9C-EEDB-417D-88ED-C5FE3663710D` at `(2560,0)`, both at `2560x1440`.
- In [config/display_layout.lua](../../config/display_layout.lua), `home` explicitly requests `60Hz` for the second external as a stability constraint. The first external has no explicit refresh rate. `home_open` does not currently specify either external's refresh rate; the closed-lid constraint does not carry over to it.
- `hz` and `color_depth` are optional in `displayplacer`; omitting them allows automatic selection of the highest available mode rather than preserving a fixed stability constraint. A configured `60Hz` mode alone does not establish that the dock/KVM video path is stable.

## Automatic Repair Behavior
- Automatic repair runs at startup and after supported wake/unlock or screen-change events. The configured delay and retry interval are both two seconds, with up to three attempts per scheduling cycle.
- Each new event cancels pending repair timers and resets the attempt count. A successful apply stops that cycle; the attempt limit does not bound subsequent events.
- Repair applies the matching profile through `displayplacer` without first checking whether the current layout already matches. If an apply generates another screen-change event, it can schedule another repair; this is a possible feedback path, not proof that repeated repair is occurring.
- Auto-repair re-checks the saved input state when delayed repair attempts fire; non-hotkey repair is skipped while the second external is away from the Mac input.

## Intermittent Black-Screen Diagnosis
- Distinguish physical signal loss from macOS topology or mode changes. Repeated read-only `displayplacer list` snapshots show screen IDs, refresh rates, and origins, but stable snapshots cannot exclude brief link loss or physical blanking behind a dock/KVM that preserves display identification.
- In the Hammerspoon console, correlate `Event: screen topology changed` with `Applied display profile 'home' (reason=screen_changed)`. Both are info-level messages. [config/logging.lua](../../config/logging.lua) defaults to `warning`, so missing messages do not rule out automatic repair. For a bounded diagnostic session, set the `display_layout` module log level to `info` or `debug`, reload Hammerspoon, and restore the prior logging setting afterward.
- To isolate automatic repair, temporarily set `display_layout.auto_repair.enabled = false` in the display config and reload Hammerspoon. This disables the module's automatic watchers and startup repair, not its manual hotkeys. Observe without invoking layout hotkeys, then restore the previous setting after the comparison.
- If blanking continues with automatic repair disabled, isolate the physical path next: bypass the KVM with a direct dock-to-second-monitor connection, then compare cables and dock outputs one variable at a time. Do not treat a successful DDC command as proof of signal stability or a physical input switch.
- A symptom that stops without a controlled comparison remains unresolved; do not record spontaneous recovery as a confirmed software or hardware fix.

## Input Switching Boundaries
- On the home path, the first external monitor remains on Mac DP and the second external monitor is the HDMI 2 alternate-input target (`18`). The monitor path is behind a Dell Thunderbolt dock and hardware KVM; DDC input commands can return success without physically switching the monitor input, so the stable workflow is mirror first, use the hardware KVM to leave the Mac path, then switch the KVM back before restoring extended layout.
- The desk cabling records KVM OUT HDMI1 feeding Monitor 2 HDMI2, while `pc-z490m` bypasses the KVM and uses a direct Monitor 2 input pending verification (`HDMI1` or `DP1`).
- Tool boundary: `displayplacer` repairs layout, origin, and main-display assignment; `m1ddc` only controls DDC features such as monitor input source.
