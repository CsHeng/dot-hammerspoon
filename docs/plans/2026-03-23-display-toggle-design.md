# Display Toggle Design

Date: 2026-03-23

## Changes

### 1. Rename repair_home → repair_display_layout, hotkey D → L

- `config/display_layout.lua`: rename `hotkeys.repair_home` key to `hotkeys.repair_display_layout`, value `{"ctrl","cmd","alt","D"}` → `{"ctrl","cmd","alt","L"}`
- `modules/display_layout.lua`: rename function `repairHome` → `repairDisplayLayout`, config path, hotkey id `repair_home_layout` → `repair_display_layout`

Rationale: the name `repair_home` implied home-only scope; the layout is auto-repaired on wake/unlock/screen-change, the hotkey is a manual trigger fallback.

### 2. New hotkey Ctrl+Cmd+Alt+D: toggle second external display

Target: the rightmost non-internal screen in the currently matched profile.

Identification logic (dynamic, no hardcoded IDs):
- Find matching profile via existing `profileMatches` logic
- From `profile.screens`, sort by x-origin ascending
- Filter out internal: `scaling == "on"` identifies Retina/built-in
- `externals[2]` = second external; get `.id`

Toggle state machine (module-level variable `second_external_enabled`):
- Disable: `displayplacer "id:<id> enabled:false"` → state=false, toast
- Enable: `scheduleRepair("hotkey")` (re-applies full profile) → state=true, toast
- No second external in profile, or no profile matches: toast, no-op

Edge cases:
- Disabled screen not in `displayplacer list` → re-enable via profile (doesn't need ID at enable time)
- Profile not matched → toast "No matching profile"

### 3. Office profile update

First external ID changed (input port changed):
- Old: `075DB5BC-C716-43A9-9B8F-74B020DAE11A`
- New: `3C67BC99-4806-4DFE-878D-A6E51B4BE48D` (2560x1440, origin 0,0)

Second external unchanged: `E5AD9F0D-0529-4234-ABF2-4053381A7C58` (1920x1080, origin 2560,0)

## Files Changed

- `config/display_layout.lua` — hotkeys rename, D→L, add toggle_second_external, update office profile IDs
- `modules/display_layout.lua` — function rename, add toggle logic + hotkey binding
