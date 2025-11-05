# Window Switcher (Expose)

## Role
- Implements an Alt-Tab style window switcher with live previews, lazy loading, and smooth canvas animations.

## Capabilities
- Discover windows across spaces using `hs.window.filter`, prioritising the focused app before falling back to global lists.
- Render previews, labels, and selection highlights with `hs.canvas`, adapting to the active screen’s geometry.
- Support forward/backward traversal, modifier-aware exit, and cleanup timers to keep memory usage predictable.
- Lazy load heavy assets only when the switcher is invoked to minimise startup cost.

## Configuration
- Trigger hotkey: `config/hotkeys.system.expose` (default `alt+tab`); the module auto-adds Shift for backward navigation once loaded.
- Display parameters (spacing, opacity, font sizes) are defined within `modules/window_expose.lua`.

## Entry Points
- Implementation: `modules/window_expose.lua`.
- Bootstrap: `init.lua` binds the forward hotkey immediately and loads the module on demand.
- Utilities: `utils/display_utils.lua` and `utils/window_utils.lua` provide geometry helpers.

## Observability
- Logs cover lazy-loading status, window discovery counts, and error conditions such as missing windows.
- Debug helpers expose internal state (active windows, selection index) for console inspection.

## Maintenance Notes
- Keep key handling resilient: modifier watchers should finalise the selection when the base modifiers are released.
- When adjusting visuals, update shared layout helpers instead of editing repeated constants.
