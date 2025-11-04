# Config Loader Module

## Overview

The `core.config_loader` module provides comprehensive configuration management for the Hammerspoon modular system. It handles configuration file loading, validation, merging, and provides a clean API for modules to access their settings.

## Features

- **Multi-File Configuration**: Load configuration from multiple files in `config/` directory
- **Schema Validation**: Validate configuration structure and data types
- **Merging Strategy**: Intelligent merging of configuration files
- **Hot Reloading**: Configuration changes apply without system restart
- **Type Safety**: Automatic type conversion and validation
- **Error Reporting**: Detailed validation error reporting
- **Default Values**: Fallback to sensible defaults
- **Module Isolation**: Each module accesses only its configuration

## Configuration File Structure

Configuration files are loaded from the `config/` directory:

```
config/
├── hotkeys.lua          # Hotkey definitions and modifiers
├── applications.lua     # Application launcher configurations
├── wifi.lua            # Network automation settings
├── keycastr.lua        # Keystroke visualization settings
└── visual.lua          # Visual appearance settings
```

## API Reference

### `config_loader.get(path, default_value)`
Retrieve a configuration value by path.

**Parameters:**
- `path` (string): Dot-separated path to configuration value
- `default_value` (optional): Default value if path not found

**Returns:**
- Configuration value or default

**Example:**
```lua
local config = require("core.config_loader")

-- Get hotkey configuration
local reload_hotkey = config.get("hotkeys.system.reload", {"ctrl", "cmd", "alt", "R"})

-- Get WiFi configuration
local muted_networks = config.get("wifi.muted_ssids", {})

-- Get nested configuration
local mouse_speed = config.get("mouse.speed", 1.0)
```

### `config_loader.set(path, value)`
Set a configuration value by path.

**Parameters:**
- `path` (string): Dot-separated path to configuration value
- `value`: Value to set

**Example:**
```lua
local config = require("core.config_loader")

-- Set configuration value
config.set("hotkeys.system.reload", {"ctrl", "cmd", "alt", "R"})

-- Update nested configuration
config.set("mouse.speed", 1.5)
```

### `config_loader.validate()`
Validate current configuration and report issues.

**Returns:**
- `boolean`: `true` if configuration is valid, `false` otherwise
- `table`: List of validation issues (if any)

**Example:**
```lua
local config = require("core.config_loader")

local is_valid, issues = config.validate()
if not is_valid then
    for _, issue in ipairs(issues) do
        print("Configuration issue: " .. issue)
    end
end
```

### `config_loader.reload()`
Reload all configuration files.

**Returns:**
- `boolean`: `true` if reload succeeded, `false` otherwise

**Example:**
```lua
local config = require("core.config_loader")

-- Hot reload configuration
local success = config.reload()
if success then
    print("Configuration reloaded successfully")
end
```

## Configuration Schema

### Hotkey Configuration
```lua
config.hotkeys = {
    system = {
        reload = {"ctrl", "cmd", "alt", "R"},
        console = {"ctrl", "cmd", "alt", "H"},
        expose = {"ctrl", "cmd", "tab"}
    },
    window = {
        hyper = {"ctrl", "alt"},
        hyper_shift = {"ctrl", "alt", "shift"},
        maximize = {"ctrl", "alt", "return"}
    }
}
```

### Application Configuration
```lua
config.applications = {
    launcher_apps = {
        {
            modifier = {"cmd", "alt"},
            key = 'C',
            appname = 'Cursor',
            bundleid = 'com.todesktop.230313mzl4w4u92'
        }
    },
    media_controls = {
        {
            modifier = {"ctrl", "cmd", "alt"},
            key = 'left',
            action = 'PREVIOUS'
        }
    }
}
```

### WiFi Configuration
```lua
config.wifi = {
    muted_ssids = {
        ["Jiatu"] = true,
        ["Shanqu"] = true
    },
    monitoring = {
        enabled = true,
        check_interval = 5
    }
}
```

## Usage Examples

### Basic Configuration Access
```lua
local config = require("core.config_loader")

-- Get configuration with defaults
local hotkey_modifiers = config.get("hotkeys.window.hyper", {"ctrl", "alt"})
local reload_key = config.get("hotkeys.system.reload", {"ctrl", "cmd", "alt", "R"})

local hotkeys = require("utils.hotkey_utils")
hotkeys.bind(hotkey_modifiers, "left", {
    description = "Move Left",
    pressed = function()
        -- Window movement logic
    end
})
```

### Configuration Validation
```lua
local config = require("core.config_loader")

-- Validate configuration on startup
local is_valid, issues = config.validate()
if not is_valid then
    local logger = require("core.logger")
    local log = logger.getLogger("config_loader")

    log:w("Configuration validation found issues:")
    for _, issue in ipairs(issues) do
        log:w("  - %s", issue)
    end
end
```

### Dynamic Configuration Updates
```lua
local config = require("core.config_loader")

-- Update configuration at runtime
config.set("window.tolerance", 15)

-- Reload configuration files
config.reload()

-- Validate after reload
if not config.validate() then
    -- Handle validation errors
end
```

## Validation Rules

### Hotkey Configuration Validation
- **Modifier Arrays**: Must be tables with valid modifier keys
- **Key Strings**: Must be valid Hammerspoon key names
- **Non-Empty**: Hotkey configurations must not be empty
- **Type Safety**: Correct types for all configuration values

### Application Configuration Validation
- **Required Fields**: Apps must have `key` and `appname` (or `action` for media controls)
- **Bundle IDs**: Must be valid application bundle identifiers
- **Modifier Keys**: Must be valid modifier key combinations

### WiFi Configuration Validation
- **Network Names**: SSID strings must be valid
- **Boolean Values**: Configuration flags must be boolean
- **Numeric Values**: Intervals and timeouts must be positive numbers

## Best Practices

### 1. **Configuration Structure**
- Use nested tables for logical grouping
- Provide sensible defaults in `config.get()` calls
- Keep configuration files focused and modular

### 2. **Validation**
- Always validate configuration on startup
- Provide meaningful error messages
- Use appropriate data types for configuration values

### 3. **Performance**
- Cache frequently accessed configuration values
- Avoid repeated `config.get()` calls in hot paths
- Use configuration defaults wisely

### 4. **Error Handling**
- Handle missing configuration gracefully
- Log configuration validation issues
- Provide fallback behavior for invalid configuration

## Integration Patterns

### 1. **Module Initialization**
```lua
local config = require("core.config_loader")
local logger = require("core.logger")
local log = logger.getLogger("my_module")

function M.init()
    -- Get module configuration
    local module_config = config.get("my_module", {})

    -- Validate required settings
    if not module_config.enabled then
        log:i("Module disabled in configuration")
        return
    end

    -- Initialize with configuration
    M.setupWithConfig(module_config)
end
```

### 2. **Hotkey Setup**
```lua
local config = require("core.config_loader")

-- Get hotkey configuration
local hotkeys = config.get("hotkeys.my_module", {})

-- Setup hotkeys if configured
if hotkeys.toggle then
    local hk = require("utils.hotkey_utils")
    hk.bind(hotkeys.toggle, {
        description = "Toggle my module",
        pressed = function()
            M.toggle()
        end
    })
end
```

### 3. **Configuration Updates**
```lua
-- Watch for configuration changes
local function onConfigChange()
    local new_config = config.get("my_module", {})
    M.updateConfiguration(new_config)
end

-- Register for configuration reload events
config.onReload(onConfigChange)
```

## Advanced Features

### 1. **Configuration Merging**
The config loader merges multiple configuration files with intelligent strategies:

- **Arrays**: Concatenate arrays from multiple files
- **Objects**: Deep merge objects with later files overriding earlier ones
- **Primitives**: Last configuration file wins

### 2. **Environment-Specific Configuration**
Configuration can be environment-specific:

```lua
-- Environment detection
local environment = hs.host.localizedName() or "default"

-- Load environment-specific configuration
local env_config = config.get("environments." .. environment, {})

-- Merge with base configuration
local final_config = mergeConfigs(base_config, env_config)
```

### 3. **Configuration Templates**
Create configuration templates for common setups:

```lua
-- Template for development configuration
local dev_config = {
    logger = { level = "debug" },
    wifi = { monitoring = { enabled = false } },
    window = { animation = { enabled = true } }
}

-- Template for production configuration
local prod_config = {
    logger = { level = "info" },
    wifi = { monitoring = { enabled = true } },
    window = { animation = { enabled = false } }
}
```

## Troubleshooting

### 1. **Configuration Not Loading**
- Check file paths and permissions
- Verify Lua syntax in configuration files
- Ensure configuration files return valid tables

### 2. **Validation Errors**
- Review error messages for specific issues
- Check data types and required fields
- Verify modifier key names and key codes

### 3. **Hot Reloading Issues**
- Ensure configuration files are saved
- Check for syntax errors in modified files
- Verify configuration validation passes

## Security Considerations

### 1. **Sensitive Data**
- Avoid storing passwords or tokens in configuration
- Use environment variables for sensitive data
- Consider encrypting sensitive configuration sections

### 2. **File Permissions**
- Set appropriate file permissions on configuration files
- Restrict write access to authorized users
- Consider file integrity monitoring

### 3. **Configuration Validation**
- Validate all external configuration inputs
- Sanitize user-provided configuration values
- Use type checking and range validation
