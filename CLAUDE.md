# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a modular Hammerspoon configuration for macOS automation that provides window management, application launching, media controls, and system automation through keyboard shortcuts. The codebase follows a clean architectural pattern with dependency injection, lazy loading, and centralized configuration management.

## Key Commands

### Configuration Management
- **Reload configuration**: `⌃⌘⌥R` (Ctrl+Cmd+Alt+R) - Reloads the entire Hammerspoon config
- **Open console**: `⌃⌘⌥H` (Ctrl+Cmd+Alt+H) - Opens the Hammerspoon console for debugging
- **Check status**: Run `hs.debugHammerspoon.status()` in the console to see module loading status

### Validation and Diagnostics
- **Validate PlantUML diagrams**: `plantuml --check-syntax <diagram-path>`
- **Test individual modules**: Use `hs.reload()` after making changes, then check console for module loading messages
- **Debug module dependencies**: Check `require("core.init_system").getModuleStatus()` for dependency issues

### File Editing and Development
- Edit configuration files in `config/` directory to modify hotkeys and behavior
- Add new modules in `modules/` directory and register them in `init.lua`
- Utility functions go in `utils/` directory
- Documentation should be updated in `docs/` with corresponding PlantUML diagrams in `docs/diagrams/`

## Architecture Overview

### Core System (`core/`)
- **`config_loader.lua`**: Centralized configuration management with validation and hot reloading. Uses a defaults system that gets overridden by files in `config/`.
- **`init_system.lua`**: Module registration and dependency management. Handles initialization order and provides module status tracking.
- **`logger.lua`**: Centralized logging system used by all modules.

### Module Loading Pattern
The system uses a sophisticated dependency-based module loading approach:

1. **Registration Phase**: Modules register themselves with the init system when first required
2. **Dependency Resolution**: The init system resolves dependencies and loads in correct order
3. **Initialization**: Each module's `init()` function is called with access to configuration via `config_loader.get()`
4. **Lazy Loading**: Heavy modules (like window_expose) are loaded on-demand

### Configuration System
- **Centralized defaults**: Located in `core/config_loader.lua` with comprehensive default settings
- **User overrides**: Files in `config/` directory override defaults (hotkeys.lua, applications.lua, etc.)
- **Path-based access**: Use `config.get("hotkeys.system.reload", {"ctrl", "cmd", "alt", "R"})` to access nested config
- **Validation**: Automatic configuration validation on startup with detailed error reporting

### Hotkey Management
- **Standardized binding**: All hotkeys use `utils/hotkey_utils.lua` for consistent behavior
- **Announcement system**: Configurable toast notifications for hotkey triggers
- **Module-specific preferences**: Each module can control whether hotkeys show announcements via `hotkeys.announcements.modules`

## Module Structure Patterns

### Feature Module Template
```lua
local logger = require("core.logger")
local config = require("core.config_loader")
local hotkey_utils = require("utils.hotkey_utils")

local log = logger.getLogger("module_name")
local M = {}

-- Module initialization function
function M.init()
    log:i("Initializing module_name")

    -- Get configuration
    local hotkey_config = config.get("hotkeys.module.section", {})

    -- Bind hotkeys using hotkey_utils
    hotkey_utils.bind(hotkey_config.some_action, {
        pressed = function()
            -- Module functionality
        end,
        description = "Action description",
        module = "module_name"
    })
end

return M
```

### Utility Module Pattern
Utility modules in `utils/` provide reusable functionality and have no dependencies. They expose functions through a module table and should include comprehensive logging.

## Key Design Principles

### Modularity and Dependencies
- **Clear separation**: Feature modules depend on utils, never on each other
- **Dependency injection**: Configuration is injected via `config_loader`, not hard-coded
- **Lazy loading**: Performance-critical modules load only when needed
- **Fail-fast**: Modules validate their configuration and fail early with clear error messages

### Configuration Philosophy
- **Single source of truth**: All configurable behavior lives in the config system
- **Hierarchical overrides**: Defaults → config files → runtime changes
- **Validation**: All configuration is validated on startup with helpful error messages
- **Hot reloading**: Configuration changes can be applied without restarting Hammerspoon

### Observability
- **Comprehensive logging**: Every important action is logged with appropriate levels
- **Module status tracking**: Use `init_system.getModuleStatus()` to see what's loaded
- **Debug helpers**: `hs.debugHammerspoon` provides useful debugging functions

## Working with This Codebase

### Adding New Modules
1. Create the module file in appropriate directory (`modules/` or `utils/`)
2. Follow the module template patterns shown above
3. Add the module to the loading list in `init.lua`
4. Add default configuration in `core/config_loader.lua`
5. Add user-facing configuration in appropriate `config/` file
6. Test by reloading and checking console output

### Modifying Configuration
- **Hotkeys**: Edit `config/hotkeys.lua` for user preferences
- **Applications**: Edit `config/applications.lua` for app-specific settings
- **Defaults**: Modify `core/config_loader.lua` for system-wide defaults
- **Validation**: Configuration is automatically validated on reload

### Debugging Common Issues
- **Module not loading**: Check `init_system.getModuleStatus()` for dependency issues
- **Hotkey conflicts**: Look for hotkey binding failures in console output
- **Configuration errors**: Check validation output on startup for malformed config
- **Dependencies**: Ensure utils are loaded before feature modules that need them

### Documentation Maintenance
- Update relevant module documentation in `docs/modules/`
- Add or update PlantUML diagrams in `docs/diagrams/`
- Keep SystemArchitecture.md in sync with any major architectural changes
- Validate PlantUML syntax before committing: `plantuml --check-syntax`

## Important File Locations

- **Main entry point**: `init.lua` - Sets up lazy loading and module system
- **Core services**: `core/` - Configuration, logging, and module management
- **Feature modules**: `modules/` - User-facing functionality
- **Shared utilities**: `utils/` - Reusable helper functions
- **User configuration**: `config/` - Override files for customization
- **Documentation**: `docs/` - Architecture docs and PlantUML diagrams

## Testing and Validation

The codebase doesn't use automated tests but relies on:
- **Configuration validation**: Automatic validation of all configuration on startup
- **Module loading verification**: Clear logging of successful/failed module initialization
- **Hotkey binding verification**: Logging of all hotkey bindings with status
- **Manual testing**: Use the debug console and hotkey triggers to verify functionality