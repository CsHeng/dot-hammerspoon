# Keystroke Visualizer

## Overview

`modules.keystroke_visualizer` (a KeyCastr-inspired module) renders keystrokes and optional click circles on screen. It reads configuration from `config/keycastr.lua`, registers toggle hotkeys through `hotkey_utils`, and stores drawings using `hs.canvas`.

## Hotkeys

| Shortcut (default) | Config Key | Action |
| --- | --- | --- |
| `ctrl+cmd+alt+k` | `hotkeys.keycastr.toggle` | Toggle keystroke display. |
| `ctrl+cmd+alt+c` | `hotkeys.keycastr.click_circle` | Toggle click circle overlay. |
| `ctrl+cmd+alt+i` | `hotkeys.keycastr.continuous` | Toggle continuous input mode. |

The shortcuts are parsed via `hotkey_utils.parseHotkey`, so changing modifier order or keys in configuration is safe.

## Features

- **Real-time keystroke overlay** with configurable font, colors, padding, and fade behaviour.
- **Continuous input mode** that concatenates multiple characters when typing quickly.
- **Click circle indicator** for mouse clicks (optional).
- **Draggable overlay** allowing the user to reposition the display at runtime.
- **Automatic cleanup** of expired drawings via timers.

## Configuration Highlights

`config/keycastr.lua` (merged with defaults in `core.config_loader`) supports:

- `enabled` — whether the overlay starts active.
- `duration`, `fade_out_duration`, `max_displayed` — lifetime/queue tuning.
- `font_size`, `padding`, `margin`, `colors` — appearance.
- `position` — base coordinate for the overlay; `x` supports offsets, `y = nil` centers on the bottom edge.
- `show_mouse_clicks`, `show_click_circle` — enable click visualizations.
- `continuous_input.enabled`, `continuous_input.max_chars`, `continuous_input.timeout` — continuous input tuning.

Changes can be persisted at runtime via `config.set`, and the module updates its behaviour immediately.

## Public API

| Function | Description |
| --- | --- |
| `M.init()` | Registers hotkeys, sets up event taps, and initializes dragging. |
| `M.setupToggleHotkeys()` | Binds the three toggle hotkeys via `hotkey_utils`. |
| `M.toggleKeystrokes()` | Enables/disables keystroke drawing, clearing existing canvases when disabled. |
| `M.toggleClickCircle()` | Toggles the click circle flag and informs the user via toast. |
| `M.toggleContinuousInput()` | Toggles continuous input, resetting the cached text. |
| `M.clearAllDrawings()` | Deletes all active canvas elements (used during toggles and cleanup). |
| `M.drawEvent(text, event_type, is_modifier)` | Renders a single keystroke with styling derived from configuration. |
| `M.getPositionForScreen(screen)` | Computes the overlay origin for the given screen. |
| `M.cleanupExpiredDrawings()` | Removes drawings that have exceeded their lifetime. |
| `M.setupEventTracking()` | Installs event taps for keyboard/mouse events and the cleanup timer. |
| `M.setupDragging()` | Allows the overlay to be dragged while active. |

Only a subset of helpers are exported for external use; the rest are orchestrated internally by `init()`.

## Toast Feedback

Toggle operations call `hs.alert.show` (via `notification_utils` conventions) with short messages such as “KeyCastr: Enabled”. Because the hotkeys are bound through `hotkey_utils`, the console lists descriptive shortcut names while Hammerspoon’s default overlay stays disabled, leaving those toasts as the only on-screen feedback.

## Integration Notes

- The module emits logs through `core.logger` under the `keystroke_visualizer` namespace.
- `continuous_text` and timers are stored locally so state resets cleanly when toggled off.
- When disabled, all event taps stop to avoid unnecessary processing.
