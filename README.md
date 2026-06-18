# Hammerspoon Configuration

## Overview

This is a modular Hammerspoon configuration for macOS automation, providing window management, application launching, media controls, and system automation through keyboard shortcuts.

## Quick Start

### Essential Hotkeys
- `⌃⌘⌥R`: Reload Hammerspoon configuration
- `⌃⌘⌥H`: Open Hammerspoon console
- `⌃⌘⌥D`: Mirror/unmirror the supported home/office second external and run the best-effort DP/HDMI input command
- `⌃⌘⌥L`: Repair display layout
- `⌃⌥⌘N`: Toggle notch hider overlay

### Window Management
- `⌃⌥ARROWS`: Half-screen positioning
- `⌃⌥⇧ARROWS`: Quarter-screen positioning
- `⌃⌥Return`: Maximize window
- `⌃⌥C`: Center window
- `⌃⌥O`: Restore original position

### Application Launchers
- `⌘⌥C`: Visual Studio Code
- `⌘⌥Q`: QQ
- `⌘⌥W`: WeChat
- `⌘⌥D`: DingTalk
- `⌘⌥G`: Google Chrome
- `⌘⌥F`: Finder
- `⌘⌥H`: Hammerspoon
- `F10`: WezTerm

### Media Controls
- `⌘⌃⌥←/→`: Previous/Next track
- `⌘⌃⌥Space`: Play/Pause
- `⌘⌃⌥↑/↓`: Volume control

### Mouse Buttons
- `Button2` (middle click): Mission Control outside browsers; native browser middle-click inside browsers
- `Button3`: Switch Space forward
- `Button4`: Switch Space backward

Mouse buttons are implemented by synthesizing keystrokes via `hs.eventtap`.
This setup defaults to using `Fn+Ctrl` as the modifier chord because on this
machine `Ctrl+Arrow` synthesized events do not reliably trigger macOS Mission
Control/Space switching shortcuts.

Browser middle-click is intentionally left to Chrome, Edge, and Safari. It
keeps native tab close and background-link-open behavior. Hammerspoon cannot
reliably allow the browser to consume link clicks while reclaiming unconsumed
middle-click events on page background for Mission Control fallback.

Some mouse drivers can emit repeated `otherMouseDown` events during a press/hold.
The mouse module suppresses duplicate injections within a short window to avoid
accidental double space-switches.

## Documentation

- System overviews: `docs/SystemArchitecture.md`, `docs/ConfigurationSystem.md`, `docs/ModuleSystem.md`
- Module and utility summaries: `docs/modules/*.md`
- Diagrams: system-level in `docs/*.puml`, module-specific in `docs/modules/diagrams/`
- Stage artifacts: `docs/plans/` is retained for historical planning context but excluded from default docs search by `docs/.ignore`; use `rg --files --no-ignore docs` when historical plans are needed.

Validate PlantUML files with `plantuml --check-syntax <diagram-path>`.

## Architecture

### Core System (`core/`)

- `config_loader.lua` - Centralized configuration management
- `init_system.lua` - Module registration and dependency management
- `logger.lua` - Centralized logging system

### Feature Modules (`modules/`)

- `window_management.lua` - Magnet-style window positioning
- `app_launcher.lua` - Fast application launching
- `media_controls.lua` - Media and system controls
- `display_layout.lua` - Repair external display layout via `displayplacer`, mirror/unmirror the supported second external, and run best-effort `m1ddc` input commands
- `mouse_management.lua` - Mouse and input device management
- `wifi_automation.lua` - Network automation and monitoring
- `keystroke_visualizer.lua` - KeyCastr functionality
- `window_expose.lua` - Window expose (lazy-loaded)
- `notch_hider.lua` - Menu-bar notch masking with canvas overlay and rounded corners

### Utilities (`utils/`)

- `app_utils.lua` - Application management utilities
- `display_utils.lua` - Multi-monitor display utilities
- `notification_utils.lua` - System notification utilities
- `window_utils.lua` - Window manipulation utilities

### Configuration (`config/`)

- `hotkeys.lua` - Complete user-editable key binding table; modules keep fallback defaults in code
- `display_layout.lua` - Displayplacer profiles for screen layout repair plus supported home/office second external mirror and best-effort `m1ddc` input commands
- `applications.lua` - Application metadata; launcher and media key combinations are edited only in `config/hotkeys.lua`
- `keycastr.lua` - KeyCastr settings
- `wifi.lua` - WiFi automation settings
- `visual.lua` - Visual configuration
- Announcement policy: `hotkeys_announcements` toggles module-level toast overlays handled by `utils/hotkey_utils`

## Key Features

- Modular Architecture: Clean separation of concerns with dependency management
- Configuration Management: Centralized settings with hot reloading
- Lazy Loading: Performance-optimized loading of heavy modules
- Cross-Display Support: Sophisticated multi-monitor window management
- Smart Edge Detection: Intelligent window positioning at screen boundaries

## File Structure

```
~/.hammerspoon/
├── init.lua                    # Main configuration
├── core/                       # Core system modules
├── modules/                    # Feature modules
├── utils/                      # Utility modules
├── config/                     # Configuration files
└── docs/                       # Documentation (plus PlantUML diagrams in docs/diagrams/)
```

## Requirements

- Hammerspoon for macOS
- macOS 10.12 or later
- Location services access (for WiFi automation)

## Development

- Use the logger system for all modules
- Register modules with the init system
- User-editable hotkey combinations are only edited in `config/hotkeys.lua`; keep module fallback defaults beside the owning module
- Bind hotkeys with expanded `hotkey_utils.bind(spec, { ... })` option-table blocks so module, id, description, toast, and handlers stay visible
- Use `.stylua.toml` for Lua formatting; keep repo-wide formatting-only changes separate from behavior changes
- Keep non-hotkey configuration in the relevant config file
- Use lazy loading for heavy operations
- Follow established naming conventions

For detailed documentation, see the `docs/` summaries and accompanying diagrams.

## For Agents

AI-specific instructions and context are in [AGENTS.md](./AGENTS.md).
