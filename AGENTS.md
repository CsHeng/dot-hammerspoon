# AI Agent Instructions

For project overview, hotkey reference, and setup instructions, see [README.md](./README.md).

## Project Overview

Modular Hammerspoon configuration for macOS automation: window management, application launching, media controls, and system automation through keyboard shortcuts. Clean architectural pattern with dependency injection, lazy loading, and centralized configuration management.

## Repository Layout

- `init.lua` - Main entry point; sets up lazy loading and module system
- `core/` - Configuration, logging, and module management
  - `config_loader.lua` - Centralized configuration with validation and hot reloading; defaults overridden by `config/` files
  - `init_system.lua` - Module registration, dependency resolution, initialization order, status tracking
  - `logger.lua` - Centralized logging used by all modules
- `modules/` - User-facing feature modules
- `utils/` - Reusable helper functions (no inter-dependencies)
- `config/` - Override files for customization (hotkeys, applications, display_layout, keycastr, wifi, visual)
- `docs/` - Architecture docs and PlantUML diagrams (`docs/diagrams/`, `docs/modules/diagrams/`)

## Display Tools

- `displayplacer` is the layout tool. Use it for profile detection, screen arrangement, origin placement, resolution, and primary-display repair.
- `m1ddc` is the monitor-control tool. Use it for DDC features such as input source, brightness, contrast, and volume.
- Do not treat `m1ddc` as a replacement for `displayplacer`; it does not manage macOS display topology.
- Do not rely on `displayplacer enabled:false/enabled:true` as a reversible second-monitor toggle. On this setup it is not a stable restore path.

## Display Toggle Scope

- `⌃⌘⌥D` is implemented with `m1ddc` for these profiles:
  - `home`
  - `home_open`
  - `office`
  - `office_open`
  - `office_typec`
  - `office_typec_open`
- The target monitor is the second external display in the matched supported profile.
- Current input mapping for the home second external (`DQ27F165L`, UUID `D0627D9C-EEDB-417D-88ED-C5FE3663710D`):
  - Mac input: `DisplayPort 1` -> `15`
  - Alternate input: `HDMI 1` -> `17`
- Current input mapping for the office second external (`DELL P2422H`, UUID `E5AD9F0D-0529-4234-ABF2-4053381A7C58`):
  - Mac input: `DisplayPort 1` -> `15`
  - Alternate input: `HDMI 1` -> `17`
- Switching to HDMI also applies mirror mode via `displayplacer` (`id:<first>+<second>` syntax) to collapse the desktop boundary.
- Switching back restores extended layout (from stored `profile_key`) BEFORE the m1ddc input switch, avoiding double flash. Falls back to delayed repair if pre-switch restore fails.
- `⌃⌘⌥L` remains a layout-repair hotkey. If the supported second external was switched away, it restores extended layout and switches back to Mac input.

## Module Loading Pattern

1. Registration: Modules register with the init system when first required
2. Dependency Resolution: Init system resolves dependencies and loads in correct order
3. Initialization: Each module's `init()` is called with configuration via `config_loader.get()`
4. Lazy Loading: Heavy modules (like window_expose) are loaded on-demand

## Configuration System

- Centralized defaults in `core/config_loader.lua`
- User overrides in `config/` directory (hotkeys.lua, applications.lua, etc.)
- Path-based access: `config.get("hotkeys.system.reload", {"ctrl", "cmd", "alt", "R"})`
- Automatic validation on startup with detailed error reporting
- Hot reloading without restarting Hammerspoon

## Hotkey Management

- All hotkeys use `utils/hotkey_utils.lua` for standardized binding
- Configurable toast notifications for hotkey triggers
- Module-specific announcement preferences via `hotkeys.announcements.modules`

## Mouse Button Boundary

- Browser middle-click fallback to Mission Control is an accepted no-fix boundary.
- Preserve native Chrome, Edge, and Safari middle-click behavior for tab close and background-link-open workflows.
- Do not reopen this as a bug or implement page-background fallback unless explicitly requested; `hs.eventtap` cannot reliably detect that a browser did not consume a propagated middle-click.

## Module Structure Patterns

### Feature Module Template
```lua
local logger = require("core.logger")
local config = require("core.config_loader")
local hotkey_utils = require("utils.hotkey_utils")

local log = logger.getLogger("module_name")
local M = {}

function M.init()
    log:i("Initializing module_name")

    local hotkey_config = config.get("hotkeys.module.section", {})

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
Utility modules in `utils/` provide reusable functionality with no inter-dependencies. Expose functions through a module table. Include comprehensive logging.

## Design Principles

- Feature modules depend on utils, never on each other
- Configuration is injected via `config_loader`, not hard-coded
- Performance-critical modules load only when needed (lazy loading)
- Modules validate configuration and fail early with clear error messages
- Single source of truth: all configurable behavior lives in the config system
- Hierarchical overrides: Defaults -> config files -> runtime changes

## Working with This Codebase

### Adding New Modules
1. Create the module file in `modules/` or `utils/`
2. Follow the module template patterns above
3. Add the module to the loading list in `init.lua`
4. Add default configuration in `core/config_loader.lua`
5. Add user-facing configuration in appropriate `config/` file
6. Test by reloading and checking console output

### Modifying Configuration
- Hotkeys: Edit `config/hotkeys.lua`
- Applications: Edit `config/applications.lua`
- Defaults: Modify `core/config_loader.lua`
- Validation is automatic on reload

### Debugging
- Module not loading: Check `init_system.getModuleStatus()` for dependency issues
- Hotkey conflicts: Look for binding failures in console output
- Configuration errors: Check validation output on startup
- Dependencies: Ensure utils are loaded before feature modules that need them
- Debug console: `hs.debugHammerspoon.status()` for module loading status
- Module dependencies: `require("core.init_system").getModuleStatus()`

## Validation and Diagnostics

- Validate PlantUML diagrams: `plantuml --check-syntax <diagram-path>`
- Test modules: Use `hs.reload()` after changes, check console for loading messages
- No automated tests; relies on configuration validation, module loading verification, hotkey binding logging, and manual testing

## Documentation Maintenance

- Update module docs in `docs/modules/`
- Add/update PlantUML diagrams in `docs/diagrams/`
- Keep `docs/SystemArchitecture.md` in sync with architectural changes
- Validate PlantUML syntax before committing
