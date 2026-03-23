# Display Toggle Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Rename repair hotkey D→L, add Ctrl+Cmd+Alt+D to toggle second external display, update office profile IDs.

**Architecture:** All changes confined to `config/display_layout.lua` (config) and `modules/display_layout.lua` (logic). Toggle uses profile-driven ID detection and a module-level state variable; re-enable delegates to existing `scheduleRepair`.

**Tech Stack:** Lua 5.4, Hammerspoon, displayplacer

---

### Task 1: Rename repair_home → repair_display_layout in config, change hotkey D → L

**Files:**
- Modify: `config/display_layout.lua`

**Step 1: Edit config**

In `config/display_layout.lua`, replace the `hotkeys` block:

```lua
-- Before
hotkeys = {
    repair_home = {"ctrl", "cmd", "alt", "D"},
},

-- After
hotkeys = {
    repair_display_layout = {"ctrl", "cmd", "alt", "L"},
},
```

**Step 2: Verify**

Open Hammerspoon console, reload config (`⌃⌘⌥R`), run:
```
hs.inspect(require("core.config_loader").get("display_layout.hotkeys"))
```
Expected: `{ repair_display_layout = { "ctrl", "cmd", "alt", "L" } }`

---

### Task 2: Rename repair_home references in module

**Files:**
- Modify: `modules/display_layout.lua`

**Step 1: Rename function and update all references**

Change:
- Function name `repairHome` → `repairDisplayLayout`
- All call sites `repairHome(...)` → `repairDisplayLayout(...)`
- Config path `"hotkeys.repair_home"` → `"hotkeys.repair_display_layout"`
- Hotkey id `"repair_home_layout"` → `"repair_display_layout"`
- Log strings mentioning `repair_home` → `repair_display_layout`

Specific diffs:

```lua
-- Line ~292: function rename
local function repairDisplayLayout(reason)   -- was repairHome
    ...
end

-- Line ~349 in attempt(): call site
if repairDisplayLayout(reason) then          -- was repairHome

-- Line ~367: config path + id
local hotkey = getConfig("hotkeys.repair_display_layout", {"ctrl", "cmd", "alt", "L"})
...
hotkey_utils.bind(mods, key, {
    module = MODULE_NAME,
    id = "repair_display_layout",            -- was "repair_home_layout"
    description = "Repair display layout",
    toast = false,
    pressed = function()
        log.i("Event: hotkey triggered (repair_display_layout)")
        scheduleRepair("hotkey")
    end
})

-- Line ~383 warning
log.w("display_layout.hotkeys.repair_display_layout is invalid; skipping hotkey bind")
```

**Step 2: Verify**

Reload config, press `⌃⌘⌥L`. Expected: display layout repair runs (toast or log message).
Check console for no errors about `repair_home`.

**Step 3: Commit**

```bash
cd /Users/csheng/.hammerspoon
git add config/display_layout.lua modules/display_layout.lua
git commit -m "refactor: rename repair_home to repair_display_layout, move hotkey D→L"
```

---

### Task 3: Add toggle_second_external config key

**Files:**
- Modify: `config/display_layout.lua`

**Step 1: Add hotkey entry**

```lua
hotkeys = {
    repair_display_layout = {"ctrl", "cmd", "alt", "L"},
    toggle_second_external = {"ctrl", "cmd", "alt", "D"},   -- new
},
```

**Step 2: Verify**

Reload, run in console:
```
hs.inspect(require("core.config_loader").get("display_layout.hotkeys"))
```
Expected: both keys present.

---

### Task 4: Implement toggle second external logic in module

**Files:**
- Modify: `modules/display_layout.lua`

**Step 1: Add state variable** (near top module-level vars, after existing `attempt_count = 0`):

```lua
local second_external_enabled = true
```

**Step 2: Add `getSecondExternalId()` function** (after `shouldNotify`, before `repairDisplayLayout`):

```lua
-- Returns the persistent ID of the second external display from the currently
-- matching profile, or nil if not found.
-- Internal display is identified by scaling == "on" (Retina/built-in).
-- Externals are sorted by x-origin; second external = externals[2].
local function getSecondExternalId()
    local displayplacerPath = resolveDisplayplacerPath()
    if not displayplacerPath then
        log.w("getSecondExternalId: displayplacer not found")
        return nil
    end

    local listOutput, ok = hs.execute(displayplacerPath .. " list")
    if not ok then
        log.w("getSecondExternalId: displayplacer list failed")
        return nil
    end

    local ids = parsePersistentIds(listOutput)
    local profiles = getConfig("profiles", {})

    local matchedProfile = nil
    for _, profileKey in ipairs(getProfileOrder(profiles)) do
        local profile = profiles[profileKey]
        if type(profile) == "table" and profile.enabled ~= false then
            if profileMatches(profile, ids) then
                matchedProfile = profile
                log.d(string.format("getSecondExternalId: matched profile '%s'", profileKey))
                break
            end
        end
    end

    if not matchedProfile then
        log.d("getSecondExternalId: no profile matched current display topology")
        return nil
    end

    local screens = {}
    for _, s in ipairs(matchedProfile.screens or {}) do
        screens[#screens + 1] = s
    end

    table.sort(screens, function(a, b)
        local ax = type(a.origin) == "table" and (a.origin.x or a.origin[1] or 0) or 0
        local bx = type(b.origin) == "table" and (b.origin.x or b.origin[1] or 0) or 0
        return ax < bx
    end)

    local externalCount = 0
    for _, s in ipairs(screens) do
        if s.scaling ~= "on" then
            externalCount = externalCount + 1
            if externalCount == 2 then
                log.d(string.format("getSecondExternalId: second external id=%s", tostring(s.id)))
                return s.id
            end
        end
    end

    log.d("getSecondExternalId: fewer than 2 external screens in matched profile")
    return nil
end
```

**Step 3: Add `toggleSecondExternal()` function** (after `getSecondExternalId`):

```lua
local function toggleSecondExternal()
    local displayplacerPath = resolveDisplayplacerPath()
    if not displayplacerPath then
        notification_utils.announce(MODULE_NAME, "toggle_no_displayplacer", {
            message = "displayplacer not found",
            duration = 1.5,
            override = true
        })
        return
    end

    if not second_external_enabled then
        -- Re-enable: re-apply the full matching profile
        log.i("toggleSecondExternal: re-enabling second external via profile repair")
        second_external_enabled = true
        scheduleRepair("hotkey")
        notification_utils.announce(MODULE_NAME, "toggle_enabled", {
            message = "Second external: enabled",
            duration = 1.0,
            override = true
        })
        return
    end

    -- Disable: find the second external ID from the current profile
    local id = getSecondExternalId()
    if not id then
        notification_utils.announce(MODULE_NAME, "toggle_not_found", {
            message = "Second external display not found",
            duration = 1.5,
            override = true
        })
        return
    end

    local arg = string.format("%q", "id:" .. id .. " enabled:false")
    local cmd = displayplacerPath .. " " .. arg
    log.i(string.format("toggleSecondExternal: disabling id=%s", id))
    local output, ok = hs.execute(cmd)
    if ok then
        second_external_enabled = false
        notification_utils.announce(MODULE_NAME, "toggle_disabled", {
            message = "Second external: disabled",
            duration = 1.0,
            override = true
        })
    else
        log.w(string.format("toggleSecondExternal: displayplacer failed: %s", tostring(output)))
        notification_utils.announce(MODULE_NAME, "toggle_failed", {
            message = "Failed to disable second external",
            duration = 1.5,
            override = true
        })
    end
end
```

**Step 4: Bind the new hotkey** (in `M.init()`, after the existing `repair_display_layout` hotkey bind block):

```lua
local toggleHotkey = getConfig("hotkeys.toggle_second_external", {"ctrl", "cmd", "alt", "D"})
local toggleMods, toggleKey = hotkey_utils.parseHotkey(toggleHotkey)
if toggleKey then
    hotkey_utils.bind(toggleMods, toggleKey, {
        module = MODULE_NAME,
        id = "toggle_second_external",
        description = "Toggle second external display",
        toast = false,
        pressed = function()
            log.i("Event: hotkey triggered (toggle_second_external)")
            toggleSecondExternal()
        end
    })
    log.d(string.format("Hotkey bound: %s+%s (toggle_second_external)", table.concat(toggleMods, "+"), toggleKey))
else
    log.w("display_layout.hotkeys.toggle_second_external is invalid; skipping hotkey bind")
end
```

**Step 5: Verify**

Reload config. Press `⌃⌘⌥D`:
- First press: second external disables, toast "Second external: disabled"
- Second press: second external re-enables, toast "Second external: enabled"

Check console for log lines `toggleSecondExternal: disabling id=...` and no errors.

**Step 6: Commit**

```bash
git add config/display_layout.lua modules/display_layout.lua
git commit -m "feat: add Ctrl+Cmd+Alt+D hotkey to toggle second external display"
```

---

### Task 5: Update office profile first external ID

**Files:**
- Modify: `config/display_layout.lua`

**Step 1: Update office profile**

```lua
office = {
    enabled = true,
    require_total_screens = 2,

    screens = {
        {
            id = "3C67BC99-4806-4DFE-878D-A6E51B4BE48D",  -- updated (port changed)
            res = "2560x1440",
            scaling = "off",
            origin = {0, 0},
            degree = 0,
            enabled = true,
        },
        {
            id = "E5AD9F0D-0529-4234-ABF2-4053381A7C58",  -- unchanged
            res = "1920x1080",
            scaling = "off",
            origin = {2560, 0},
            degree = 0,
            enabled = true,
        },
    }
},
```

**Step 2: Verify**

Reload config. Check console for "Applied display profile 'office'" on startup or press `⌃⌘⌥L`.

**Step 3: Commit**

```bash
git add config/display_layout.lua
git commit -m "fix: update office profile first external display ID (input port changed)"
```
