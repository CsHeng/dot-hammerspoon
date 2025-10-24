# Module System

## Overview

The Module System provides a robust framework for loading, managing, and coordinating Hammerspoon modules with automatic dependency resolution, lifecycle management, and error handling.

## Core Architecture

### Module Definition

Each module follows a consistent structure:

```lua
local module = {
    name = "module_name",
    version = "1.0.0",
    description = "Module description",
    dependencies = {"other_module", "another_module"},
    config_dependencies = {"config.section"},
    initialize = function(config)
        -- Module initialization code
    end,
    cleanup = function()
        -- Module cleanup code
    end
}

return module
```

### Module Lifecycle

1. **Registration**: Module registers with init system
2. **Dependency Analysis**: System analyzes dependencies
3. **Loading Order**: Determines optimal loading order
4. **Initialization**: Modules are initialized in order
5. **Runtime**: Modules execute their functionality
6. **Cleanup**: Cleanup called on reload or shutdown

## API Reference

### `init_system.registerModule(name, definition)`

Registers a module with the initialization system.

**Parameters:**
- `name` (string): Unique module name
- `definition` (table): Module definition table

**Returns:**
- `success` (boolean): Whether registration succeeded
- `error` (string): Error message if registration failed

**Example:**
```lua
local success, error = init_system.registerModule("my_module", {
    version = "1.0.0",
    dependencies = {"utils"},
    initialize = function(config)
        -- Initialize module
    end
})

if not success then
    print("Module registration failed:", error)
end
```

### `init_system.loadAllModules()`

Loads all registered modules in dependency order.

**Returns:**
- `success` (boolean): Whether all modules loaded successfully
- `failed_modules` (array): Array of module names that failed to load

**Example:**
```lua
local success, failed = init_system.loadAllModules()
if not success then
    print("Failed to load modules:", table.concat(failed, ", "))
end
```

### `init_system.reloadModule(name)`

Reloads a specific module and its dependents.

**Parameters:**
- `name` (string): Module name to reload

**Returns:**
- `success` (boolean): Whether reload succeeded
- `affected_modules` (array): Array of modules that were reloaded

**Example:**
```lua
local success, affected = init_system.reloadModule("window_management")
print("Reloaded modules:", table.concat(affected, ", "))
```

### `init_system.getModuleStatus()`

Returns the current status of all modules.

**Returns:**
- Table mapping module names to status objects

**Example:**
```lua
local status = init_system.getModuleStatus()
for name, info in pairs(status) do
    print(name, info.state, info.last_loaded)
end
```

### `init_system.getLoadingOrder()`

Returns the computed loading order for modules.

**Returns:**
- Array of module names in loading order

**Example:**
```lua
local order = init_system.getLoadingOrder()
print("Loading order:", table.concat(order, " -> "))
```

### `init_system.isModuleLoaded(name)`

Checks if a module is currently loaded.

**Parameters:**
- `name` (string): Module name

**Returns:**
- `loaded` (boolean): Whether module is loaded

**Example:**
```lua
if init_system.isModuleLoaded("window_expose") then
    -- Module is available
end
```

### `init_system.getModuleDependencies(name)`

Returns the dependency tree for a module.

**Parameters:**
- `name` (string): Module name

**Returns:**
- `dependencies` (array): Array of dependency names

**Example:**
```lua
local deps = init_system.getModuleDependencies("media_controls")
print("Media controls depends on:", table.concat(deps, ", "))
```

## Module Definition Reference

### Required Fields

#### `name` (string)
Unique identifier for the module. Must match the filename and module registration name.

#### `version` (string)
Semantic version string for the module.

#### `initialize` (function)
Function called to initialize the module.

**Parameters:**
- `config` (table): Module's configuration section

**Returns:**
- `success` (boolean): Whether initialization succeeded
- `error` (string): Error message if initialization failed

### Optional Fields

#### `description` (string)
Human-readable description of the module's purpose.

#### `dependencies` (array)
Array of module names this module depends on.

#### `config_dependencies` (array)
Array of configuration sections this module requires.

#### `cleanup` (function)
Function called when module is being reloaded or system is shutting down.

#### `hot_reload` (boolean)
Whether module supports hot reloading (default: true).

#### `lazy_load` (boolean)
Whether module should be lazy-loaded (default: false).

#### `priority` (number)
Loading priority (higher numbers load first, default: 0).

## Dependency Management

### Dependency Resolution

The system uses topological sorting to resolve dependencies:

```lua
-- Module A depends on B and C
-- Module B depends on D
-- Module C depends on D

-- Loading order: D -> B -> C -> A
```

### Circular Dependency Detection

```lua
-- If A depends on B, and B depends on A
local success, error = init_system.loadAllModules()
-- success: false
-- error: "Circular dependency detected between A and B"
```

### Dependency Types

#### 1. Hard Dependencies
Module cannot function without these dependencies.

```lua
dependencies = {"utils.logger", "utils.window"}
```

#### 2. Soft Dependencies
Module can function but with reduced functionality.

```lua
optional_dependencies = {"modules.mouse_management"}
```

#### 3. Configuration Dependencies
Module requires specific configuration sections.

```lua
config_dependencies = {"config.hotkeys", "config.visual"}
```

## Module States

### Loading States

1. **UNREGISTERED**: Module not registered with system
2. **REGISTERED**: Module registered but not loaded
3. **LOADING**: Module is currently being loaded
4. **LOADED**: Module loaded and initialized
5. **FAILED**: Module failed to load or initialize
6. **RELOADING**: Module is being reloaded

### State Transitions

```
UNREGISTERED -> REGISTERED -> LOADING -> LOADED
                                            -> FAILED
LOADED -> RELOADING -> LOADED
              -> FAILED
```

## Error Handling

### Initialization Errors

```lua
local module = {
    initialize = function(config)
        -- Module initialization fails
        return false, "Failed to initialize: reason"
    end
}

-- System continues loading other modules
local success, failed = init_system.loadAllModules()
-- failed = {"module_name"}
```

### Dependency Errors

```lua
-- If a dependency fails to load
-- Modules that depend on it are marked as BLOCKED
local status = init_system.getModuleStatus()
-- status = {
--     dependency_module = {state = "FAILED"},
--     dependent_module = {state = "BLOCKED", blocked_by = "dependency_module"}
-- }
```

### Graceful Degradation

```lua
local module = {
    dependencies = {"optional_feature"},
    initialize = function(config)
        if not init_system.isModuleLoaded("optional_feature") then
            -- Fallback to basic functionality
            return initializeBasicMode(config)
        end
        return initializeFullMode(config)
    end
}
```

## Performance Optimization

### Lazy Loading

```lua
local module = {
    lazy_load = true,
    initialize = function(config)
        -- Only load when first accessed
        -- Useful for heavy modules like window_expose
    end
}
```

### Memory Management

```lua
local module = {
    cleanup = function()
        -- Clean up resources
        collectgarbage()
    end
}
```

### Hot Reload Optimization

```lua
local module = {
    hot_reload = false,  -- Disable if module doesn't support reload
    -- or
    hot_reload = true,
    reload_strategy = "full"  -- "full", "config_only", "smart"
}
```

## Debugging and Monitoring

### Module Status Monitoring

```lua
-- Monitor module loading progress
local function monitorModuleLoading()
    local status = init_system.getModuleStatus()
    for name, info in pairs(status) do
        if info.state == "LOADING" then
            print("Loading:", name)
        elseif info.state == "FAILED" then
            print("Failed:", name, info.error)
        end
    end
end
```

### Dependency Graph Visualization

```lua
-- Generate dependency graph
local function generateDependencyGraph()
    local graph = {}
    local modules = init_system.getModuleStatus()

    for name, info in pairs(modules) do
        graph[name] = init_system.getModuleDependencies(name)
    end

    return graph
end
```

### Performance Metrics

```lua
-- Track module loading performance
local function getModuleLoadTimes()
    local metrics = {}
    local status = init_system.getModuleStatus()

    for name, info in pairs(status) do
        if info.load_time then
            metrics[name] = info.load_time
        end
    end

    return metrics
end
```

## Best Practices

### 1. Module Structure

```lua
-- Good module structure
local logger = require("core.logger").getLogger("my_module")
local config_loader = require("core.config_loader")

local module = {
    name = "my_module",
    version = "1.0.0",
    description = "My awesome module",
    dependencies = {"utils.window_utils"},
    config_dependencies = {"config.my_module"},

    initialize = function(config)
        logger.info("Initializing module")
        -- Module initialization
        return true
    end,

    cleanup = function()
        logger.info("Cleaning up module")
        -- Module cleanup
    end
}

return module
```

### 2. Error Handling

```lua
local function initializeModule(config)
    local success, result = pcall(function()
        -- Potentially failing initialization
        return doInitialization(config)
    end)

    if not success then
        logger.error("Initialization failed:", result)
        return false, result
    end

    return true
end
```

### 3. Configuration Validation

```lua
local function validateConfig(config)
    if type(config.enabled) ~= "boolean" then
        return false, "enabled must be boolean"
    end

    if config.timeout and config.timeout <= 0 then
        return false, "timeout must be positive"
    end

    return true
end
```

### 4. Testing

```lua
-- Unit test structure
local function testModule()
    -- Reset system state
    init_system.reset()

    -- Register test module
    init_system.registerModule("test_module", {
        initialize = function(config)
            return true
        end
    })

    -- Load and verify
    local success, failed = init_system.loadAllModules()
    assert(success, "Module should load successfully")
    assert(init_system.isModuleLoaded("test_module"))
end
```

## Integration with Other Systems

### Configuration System

```lua
-- Automatic configuration injection
local module = {
    config_dependencies = {"config.my_module"},
    initialize = function(config)
        -- config contains only my_module section
        local timeout = config.timeout or 5000
        return true
    end
}
```

### Logging System

```lua
-- Module-specific logger
local module = {
    initialize = function(config)
        local logger = require("core.logger").getLogger("my_module")
        logger.info("Module initialized")
        return true
    end
}
```

### Event System

```lua
-- Event-driven module activation
local module = {
    initialize = function(config)
        -- Register for events
        hs.hotkey.bind(config.hotkey, function()
            module.handleHotkey()
        end)
        return true
    end
}
```

## Troubleshooting

### Common Issues

1. **Circular Dependencies**: Review module dependencies for cycles
2. **Missing Dependencies**: Ensure all required modules are available
3. **Configuration Errors**: Validate configuration syntax and values
4. **Loading Order**: Check priority settings if order is important

### Debug Commands

```lua
-- Check module status
print(hs.inspect(init_system.getModuleStatus()))

-- Test dependency resolution
print("Loading order:", table.concat(init_system.getLoadingOrder(), " -> "))

-- Force reload specific module
init_system.reloadModule("problematic_module")
```

### Performance Profiling

```lua
-- Profile module loading time
local start = hs.timer.secondsSinceEpoch()
init_system.loadAllModules()
local elapsed = hs.timer.secondsSinceEpoch() - start
print("All modules loaded in", elapsed, "seconds")
```