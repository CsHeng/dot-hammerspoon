# Window Switcher (Alt-Tab)

## Overview

The window switcher delivers a fast, Alt-Tab style experience on macOS using Hammerspoon. It presents your most recently used windows as large preview cards with live thumbnails, titles, and quick-hint badges so you can jump between tasks without leaving the keyboard. The module loads on-demand the first time you press the configured hotkey, keeping startup time minimal.

## Key Features

- **MRU Ordering** – windows are listed by most recent focus so the next task is always a single tap away.
- **Rich Previews** – each card can show a live window snapshot, high-resolution app icon, or smart initials fallback.
- **Adaptive Layout** – responsive grid with glassmorphism styling, drop shadows, and highlight animations.
- **Keyboard Centric** – press `⌥Tab` to cycle forward, `⌥⇧Tab` to cycle backward; release to focus instantly.
- **App Filtering** – optionally limit visible windows via `applications.expose_app_filter.allowed`.
- **Lazy Loading** – the module and assets are only required when the switcher is first invoked.

## Usage

1. Reload Hammerspoon (`⌃⌘⌥R`).
2. Hit `⌥Tab` (or the key combo defined at `hotkeys.system.expose`).
3. On first use the module loads, then immediately displays the live switcher overlay.
4. Continue tapping `Tab` (or `⇧Tab`) while holding the modifier to move through windows.
5. Release the modifier to switch to the highlighted window and dismiss the overlay.

## Configuration

| Setting | Location | Description |
| --- | --- | --- |
| Hotkey | `config/hotkeys.lua → hotkeys.system.expose` | Primary trigger (defaults to `⌥Tab`). |
| Allowed Apps | `config/applications.lua → expose_app_filter.allowed` | Optional whitelist of app names shown in the switcher. |

The module supports up to 12 windows at once for clarity. If more windows are open, the least-recent entries are truncated.

## Lazy Loading Flow

1. `init.lua` binds lightweight handlers that require `modules/window_expose.lua` on first use.
2. Once required, the module registers its real hotkeys and sets up internal state.
3. The temporary binding is removed and `module.trigger()` is invoked so the overlay appears immediately in the requested direction.

## Troubleshooting

- **No overlay appears**: ensure the first `⌥Tab` press happens after reloading Hammerspoon; check the console for module loading errors.
- **Missing thumbnails**: some applications disallow snapshots; the switcher falls back to icons or initials automatically.
- **Hotkey conflicts**: adjust `hotkeys.system.expose` to a different combination and reload.

Use `require("modules.window_expose").debug()` in the Hammerspoon console for internal status logs.