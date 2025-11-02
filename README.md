# Hammerspoon Configuration

## Overview

This is a modular Hammerspoon configuration for macOS automation, providing window management, application launching, media controls, and system automation through keyboard shortcuts.

## Quick Start

### Essential Hotkeys
- `⌃⌘⌥R`: Reload Hammerspoon configuration
- `⌃⌘⌥H`: Open Hammerspoon console
- `⌃⌥⌘N`: Toggle notch hider overlay

### Window Management
- `⌃⌥ARROWS`: Half-screen positioning
- `⌃⌥⇧ARROWS`: Quarter-screen positioning
- `⌃⌥Return`: Maximize window
- `⌃⌥C`: Center window
- `⌃⌥O`: Restore original position

### Application Launchers
- `⌘⌥C`: Cursor
- `⌘⌥Q`: QQ
- `⌘⌥W`: WeChat
- `⌘⌥D`: DingTalk
- `⌘⌥G`: Google Chrome
- `⌘⌥F`: Finder
- `⌘⌥H`: Hammerspoon
- `F10`: Ghostty

### Media Controls
- `⌘⌃⌥←/→`: Previous/Next track
- `⌘⌃⌥Space`: Play/Pause
- `⌘⌃⌥↑/↓`: Volume control

## Documentation

See `/docs/` directory for comprehensive documentation:

- **[System Architecture](docs/SystemArchitecture.md)** - High-level system design
- **[Configuration System](docs/ConfigurationSystem.md)** - Settings management
- **[Module System](docs/ModuleSystem.md)** - Module loading and dependencies
- **[Feature Modules](docs/README.md)** - Individual module documentation

## Architecture

### Core System (`core/`)

- **`config_loader.lua`** - Centralized configuration management
- **`init_system.lua`** - Module registration and dependency management
- **`logger.lua`** - Centralized logging system

### Feature Modules (`modules/`)

- **`window_management.lua`** - Magnet-style window positioning
- **`app_launcher.lua`** - Fast application launching
- **`media_controls.lua`** - Media and system controls
- **`mouse_management.lua`** - Mouse and input device management
- **`wifi_automation.lua`** - Network automation and monitoring
- **`keystroke_visualizer.lua`** - KeyCastr functionality
- **`window_expose.lua`** - Window expose (lazy-loaded)
- **`notch_hider.lua`** - Menu-bar notch masking with canvas overlay and rounded corners

### Utilities (`utils/`)

- **`app_utils.lua`** - Application management utilities
- **`display_utils.lua`** - Multi-monitor display utilities
- **`notification_utils.lua`** - System notification utilities
- **`window_utils.lua`** - Window manipulation utilities

### Configuration (`config/`)

- **`hotkeys.lua`** - Central hotkey definitions
- **`applications.lua`** - Application configurations
- **`keycastr.lua`** - KeyCastr settings
- **`wifi.lua`** - WiFi automation settings
- **`visual.lua`** - Visual configuration

## Key Features

- **Modular Architecture**: Clean separation of concerns with dependency management
- **Configuration Management**: Centralized settings with hot reloading
- **Lazy Loading**: Performance-optimized loading of heavy modules
- **Cross-Display Support**: Sophisticated multi-monitor window management
- **Smart Edge Detection**: Intelligent window positioning at screen boundaries

## File Structure

```
~/.hammerspoon/
├── init.lua                    # Main configuration
├── core/                       # Core system modules
├── modules/                    # Feature modules
├── utils/                      # Utility modules
├── config/                     # Configuration files
└── docs/                       # Documentation
```

## Requirements

- Hammerspoon for macOS
- macOS 10.12 or later
- Location services access (for WiFi automation)

## Development

- Use the logger system for all modules
- Register modules with the init system
- Keep configuration in separate config files
- Use lazy loading for heavy operations
- Follow established naming conventions

For detailed documentation, see the `/docs/` directory.