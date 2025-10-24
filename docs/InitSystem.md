# Init System Module

## Overview

The `core.init_system` module provides a sophisticated module initialization system for the Hammerspoon modular architecture. It handles dependency resolution, loading order, and lifecycle management of all modules in the system.

## Features

- **Dependency Management**: Automatic resolution of module dependencies
- **Ordered Loading**: Modules load in the correct order based on dependencies
- **Lifecycle Management**: Proper initialization and cleanup of modules
- **Error Handling**: Graceful handling of module loading failures
- **Status Tracking**: Real-time status of module loading and health
- **Hot Reloading**: Individual module reloading without system restart
- **Circular Dependency Detection**: Prevention of circular dependency issues

## System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    init_system                                  │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │            Module Registry                                   │ │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐    │ │
│  │  │   utils.    │  │  modules.   │  │  modules.   │    │ │
│  │  │  app_utils  │  │ window_man  │  │ app_launch  │    │ │
│  │  └─────────────┘  └─────────────┘  └─────────────┘    │ │
│  └─────────────────────────────────────────────────────────────┘ │
├─────────────────────────────────────────────────────────────────┤
│                  Dependency Resolver                             │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │        Dependency Graph & Loading Order                     │ │
│  │  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐   │ │
│  │  │   utils     │ ──▶│   modules   │ ──▶│   modules   │   │ │
│  │  │   (level 1) │    │  (level 2)  │    │  (level 3)  │   │ │
│  │  └─────────────┘    └─────────────┘    └─────────────┘   │ │
│  └─────────────────────────────────────────────────────────────┘ │
├─────────────────────────────────────────────────────────────────┤
│                  Module Loader                                   │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │            Loading Process                                  │ │
│  │  • Check dependencies • Initialize • Register • Report     │ │
│  └─────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

## Module Dependencies

The system defines module dependencies to ensure proper loading order:

### Level 1: Core Utilities (No Dependencies)
- `utils.app_utils` - Application management utilities
- `utils.display_utils` - Display and screen utilities
- `utils.notification_utils` - Notification system utilities
- `utils.window_utils` - Window manipulation utilities

### Level 2: Feature Modules (Depend on Utilities)
- `modules.keystroke_visualizer` - Keystroke visualization
- `modules.window_management` - Window positioning system
- `modules.app_launcher` - Application launching system
- `modules.media_controls` - Media and system controls
- `modules.mouse_management` - Mouse and input management
- `modules.wifi_automation` - Network automation system

### Level 3: Lazy Loaded Modules
- `modules.window_expose` - Window expose (loaded on demand)

## API Reference

### `init_system.registerModule(name, module_def)`
Register a module with the initialization system.

**Parameters:**
- `name` (string): Unique module identifier
- `module_def` (table): Module definition containing:
  - `init` (function): Module initialization function
  - `dependencies` (table): List of required dependencies
  - `config` (function/table): Optional configuration function or table

**Example:**
```lua
local init_system = require("core.init_system")

init_system.registerModule("my_module", {
    init = function()
        -- Module initialization code
        print("Module initialized")
    end,
    dependencies = {"utils.app_utils", "utils.display_utils"},
    config = function()
        -- Optional configuration setup
        return {setting = "value"}
    end
})
```

### `init_system.loadAllModules()`
Load all registered modules in dependency order.

**Returns:**
- `boolean`: `true` if all modules loaded successfully, `false` otherwise

**Example:**
```lua
local init_system = require("core.init_system")

local success = init_system.loadAllModules()
if success then
    print("All modules loaded successfully")
else
    print("Some modules failed to load")
end
```

### `init_system.reloadModule(module_name)`
Reload a specific module.

**Parameters:**
- `module_name` (string): Name of module to reload

**Returns:**
- `boolean`: `true` if reload succeeded, `false` otherwise

**Example:**
```lua
local init_system = require("core.init_system")

-- Reload window management module
local success = init_system.reloadModule("modules.window_management")
if success then
    print("Window management module reloaded")
end
```

### `init_system.getModuleStatus()`
Get loading status of all modules.

**Returns:**
- `table`: Module status information

**Example:**
```lua
local init_system = require("core.init_system")

local status = init_system.getModuleStatus()
for module_name, info in pairs(status) do
    print(string.format("%s: %s (deps: %s)",
        module_name,
        info.loaded and "loaded" or "not loaded",
        table.concat(info.dependencies, ", ")))
end
```

### `init_system.getLoadingOrder()`
Get the module loading order.

**Returns:**
- `table`: List of module names in loading order

**Example:**
```lua
local init_system = require("core.init_system")

local order = init_system.getLoadingOrder()
print("Module loading order: " .. table.concat(order, " -> "))
```

### `init_system.allModulesLoaded()`
Check if all modules are loaded.

**Returns:**
- `boolean`: `true` if all modules loaded, `false` otherwise

**Example:**
```lua
local init_system = require("core.init_system")

if init_system.allModulesLoaded() then
    print("System ready")
else
    print("System still loading")
end
```

## Usage Examples

### Basic Module Registration
```lua
local init_system = require("core.init_system")
local logger = require("core.logger")
local log = logger.getLogger("my_module")

-- Define module
local my_module = {
    init = function()
        log:i("Initializing my module")
        -- Setup module functionality
        M.setup()
        log:i("My module initialized")
    end,

    dependencies = {"utils.app_utils", "utils.notification_utils"},

    config = function()
        return {
            enabled = true,
            timeout = 5,
            retries = 3
        }
    end
}

-- Register module
init_system.registerModule("modules.my_module", my_module)
```

### Module with Dependencies
```lua
init_system.registerModule("modules.advanced_module", {
    init = function()
        local app_utils = require("utils.app_utils")
        local window_utils = require("utils.window_utils")

        -- Use dependencies
        M.setupWithUtils(app_utils, window_utils)
    end,

    dependencies = {
        "utils.app_utils",
        "utils.window_utils",
        "utils.notification_utils"
    }
})
```

### Checking Module Status
```lua
local init_system = require("core.init_system")

-- Get comprehensive module status
local status = init_system.getModuleStatus()

for module_name, info in pairs(status) do
    local status_str = info.loaded and "✅" or "❌"
    local deps_str = #info.dependencies > 0 and
        " (deps: " .. table.concat(info.dependencies, ", ") .. ")" or ""

    print(string.format("%s %s%s", status_str, module_name, deps_str))
end
```

### Hot Module Reloading
```lua
local init_system = require("core.init_system")

-- Function to reload specific module
function reloadModule(module_name)
    print("Reloading module: " .. module_name)

    local success = init_system.reloadModule(module_name)
    if success then
        print("✅ Module reloaded successfully")
        return true
    else
        print("❌ Failed to reload module")
        return false
    end
end

-- Usage in development
reloadModule("modules.window_management")
```

## Loading Process

### 1. **Initialization Phase**
```
init_system.init()
  │
  ├─▶ Register all core modules
  ├─▶ Set up dependency graph
  └─▶ Prepare loading infrastructure
```

### 2. **Dependency Resolution Phase**
```
loadAllModules()
  │
  ├─▶ Identify modules with no dependencies
  ├─▶ Load level 1 modules (utilities)
  ├─▶ Resolve level 2 dependencies
  ├─▶ Load level 2 modules (features)
  └─▶ Verify all modules loaded
```

### 3. **Module Loading Phase**
```
loadModule(module_name)
  │
  ├─▶ Check if already loaded
  ├─▶ Verify all dependencies satisfied
  ├─▶ Initialize module configuration
  ├─▶ Call module init() function
  ├─▶ Register as loaded
  └─▶ Log success/failure
```

## Error Handling

### 1. **Dependency Missing**
```lua
-- When dependency not loaded
if not deps_ok then
    log:e(deps_error)
    return false
end
```

### 2. **Module Initialization Failed**
```lua
-- When module init() throws error
local success, err = pcall(module.init)
if not success then
    log:e(string.format("Failed to load module %s: %s", module_name, err))
    return false
end
```

### 3. **Circular Dependencies**
```lua
-- Detected through dependency resolution
if circular_dependency_detected then
    log:e("Circular dependency detected involving: " .. module_name)
    return false
end
```

## Best Practices

### 1. **Module Definition**
- Keep init functions simple and fast
- Handle initialization errors gracefully
- Log important initialization events
- Clean up resources on failure

### 2. **Dependency Management**
- Declare only necessary dependencies
- Keep dependency graph shallow when possible
- Avoid circular dependencies
- Use utility modules for common functionality

### 3. **Configuration Setup**
- Provide sensible defaults
- Validate configuration in init function
- Allow runtime configuration updates
- Document configuration requirements

### 4. **Error Recovery**
- Implement proper cleanup on failure
- Provide meaningful error messages
- Allow module reloading after fixes
- Log detailed diagnostic information

## Performance Considerations

### 1. **Initialization Performance**
- Parallel loading of independent modules
- Minimal overhead in dependency checking
- Efficient module registration process
- Fast dependency resolution algorithm

### 2. **Memory Usage**
- Clean module separation
- Proper resource management
- No memory leaks in loading process
- Efficient state tracking

### 3. **Runtime Performance**
- Minimal overhead after initialization
- Fast status checking operations
- Efficient module reloading
- Low memory footprint for tracking

## Troubleshooting

### 1. **Module Not Loading**
- Check module registration in init_system
- Verify dependency names are correct
- Look for initialization errors in logs
- Ensure module file exists and is valid Lua

### 2. **Dependency Issues**
- Verify all dependencies are registered
- Check dependency spelling and case
- Look for circular dependencies
- Ensure correct loading order

### 3. **Initialization Failures**
- Check module init function for errors
- Verify configuration is valid
- Look for missing required files
- Check permissions and resource access

### 4. **Reloading Problems**
- Ensure module properly supports reloading
- Check for resource cleanup issues
- Verify new code is syntactically correct
- Look for state persistence problems

## Integration Patterns

### 1. **Standard Module Pattern**
```lua
local M = {}
local logger = require("core.logger")
local log = logger.getLogger("my_module")

function M.init()
    log:i("Starting module initialization")

    -- Setup module
    M.setup()

    log:i("Module initialization complete")
end

function M.setup()
    -- Module-specific setup
    M.setupHotkeys()
    M.setupEventHandlers()
end

-- Register module
local init_system = require("core.init_system")
init_system.registerModule("modules.my_module", {
    init = M.init,
    dependencies = {"utils.app_utils"}
})

return M
```

### 2. **Configuration-Dependent Module**
```lua
function M.init()
    local config = require("core.config_loader")
    local module_config = config.get("my_module", {})

    if not module_config.enabled then
        log:i("Module disabled in configuration")
        return
    end

    M.setupWithConfig(module_config)
end
```

### 3. **Complex Module with Multiple Dependencies**
```lua
function M.init()
    -- Load dependencies
    local app_utils = require("utils.app_utils")
    local window_utils = require("utils.window_utils")
    local notify_utils = require("utils.notification_utils")

    -- Setup with dependencies
    M.app_utils = app_utils
    M.window_utils = window_utils
    M.notify_utils = notify_utils

    -- Initialize module functionality
    M.initializeFeatures()
end

-- Register with multiple dependencies
init_system.registerModule("modules.complex_module", {
    init = M.init,
    dependencies = {
        "utils.app_utils",
        "utils.window_utils",
        "utils.notification_utils"
    }
})
```

## Future Enhancements

### 1. **Advanced Features**
- Module versioning and compatibility checking
- Conditional module loading based on system capabilities
- Module health monitoring and automatic recovery
- Performance metrics for module loading

### 2. **Developer Tools**
- Module dependency visualization
- Loading time analysis and optimization
- Interactive module management console
- Module testing framework integration

### 3. **System Integration**
- Integration with system package management
- Module marketplace or repository
- Automatic module updates and notifications
- Module performance benchmarking