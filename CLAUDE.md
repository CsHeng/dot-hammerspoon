# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Hammerspoon Configuration

This is a modular Hammerspoon configuration repository for macOS automation. Hammerspoon is a desktop automation tool for macOS that allows extensive customization through Lua scripting.

## Development Commands

### Configuration Management
```bash
# Reload Hammerspoon configuration
# Use hotkey: ⌃⌘⌥R

# Open Hammerspoon console for debugging
# Use hotkey: ⌃⌘⌥H

# Enable debug logging
# In Hammerspoon console: require("core.logger").setLogLevel("debug")

# Set log level to warning (default)
# In Hammerspoon console: require("core.logger").setLogLevel("warning")
```

### Testing Changes
- Test hotkey changes by reloading configuration (⌃⌘⌥R)
- Use Hammerspoon console (⌃⌘⌥H) for live debugging
- Check Console.app for Hammerspoon-specific messages
- Verify module loading status in console

## Architecture

### Modular Loading System

The configuration uses a sophisticated module dependency system defined in `core/init_system.lua`:

```
Module Loading Order:
1. Core modules (no dependencies)
   - utils.app_utils
   - utils.display_utils
   - utils.notification_utils
   - utils.window_utils

2. Feature modules (depend on utils)
   - modules.window_management
   - modules.app_launcher
   - modules.media_controls
   - modules.mouse_management
   - modules.wifi_automation
   - modules.keystroke_visualizer

3. Lazy-loaded modules
   - modules.window_expose (loaded on first use)
```

### Key Architectural Patterns

**Configuration System**: All settings centralized in `config/` directory with hot reloading. The `core/config_loader.lua` provides dot-notation access to nested configuration values.

**Module Registration**: Modules declare dependencies and are loaded in correct order by `core/init_system.lua`. Each module follows the pattern `local M = {}` and returns `M`.

**Logging System**: Centralized logging through `core/logger.lua` with levels: debug, info, warning, error. Default level is "warning" for quiet operation.

**Event-Driven Architecture**: Heavy use of Hammerspoon's `hs.hotkey.bind()` for keyboard shortcuts and event taps for mouse/scroll events.

### Critical Integration Points

**Window Management**: Cross-display movement logic spans `modules/window_management.lua`, `utils/window_utils.lua`, and `utils/display_utils.lua`. Edge detection prevents display cycling while enabling smart cross-monitor positioning.

**Application Management**: `modules/app_launcher.lua` uses `utils/app_utils.lua` for reliable app detection and launching via bundle IDs rather than app names.

**Configuration Loading**: `init.lua` loads core modules first, then feature modules in dependency order. Hotkey bindings are centralized in `config/hotkeys.lua`.

**WiFi Automation**: `modules/wifi_automation.lua` integrates with macOS location services for reliable network detection and automatic audio muting on work networks.

### Key Modifier Patterns

- **Window Management**: `ctrl+alt` (hyper modifier) for positioning
- **App Launcher**: `cmd+alt` modifier for app switching
- **Media Control**: `ctrl+cmd+alt` modifier for media controls
- **System Control**: `ctrl+cmd+alt` modifier for system functions

## Module Development Guidelines

### Adding New Modules

1. Create module file in `modules/` or `utils/` following existing patterns
2. Add configuration options in appropriate `config/` file
3. Declare dependencies in `core/init_system.lua` module_dependencies table
4. Use logger: `local log = require("core.logger").getLogger("module_name")`
5. Follow module pattern: `local M = {}; function M.init(); return M`

### Configuration Access

```lua
-- Access configuration values with fallback
local config = require("core.config_loader")
local enabled = config.get("section.setting", default_value)

-- Set configuration values
config.set("section.setting", new_value)
```

### Hotkey Management

All hotkeys are defined in configuration files and bound through the module system. Use consistent modifier patterns and avoid conflicts with system hotkeys.

### Error Handling

- Use pcall() for operations that might fail
- Log errors with context: `log:e("Operation failed: " .. tostring(error))`
- Graceful degradation when optional dependencies fail

## Performance Considerations

- **Lazy Loading**: Heavy modules (window_expose) load only when first used
- **Event Filtering**: Filter unnecessary events to minimize processing
- **Memory Management**: Periodic cleanup of cached data (window frames, etc.)
- **Resource Cleanup**: Proper cleanup of event taps and timers in module cleanup functions