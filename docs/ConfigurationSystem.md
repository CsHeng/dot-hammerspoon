# Configuration System

## Overview

The Configuration System provides centralized management of all Hammerspoon settings across multiple configuration files. It supports nested configuration access, validation, and hot reloading for seamless customization.

## Configuration Structure

### Configuration Files

```
config/
├── applications.lua    # App definitions and hotkey bindings
├── hotkeys.lua        # Hotkey definitions and modifier patterns
├── keycastr.lua       # Keystroke visualization settings
├── visual.lua         # Visual and UI appearance settings
└── wifi.lua          # WiFi automation and network profiles
```

### Key Features

- **Centralized Access**: Single point of access for all configuration values
- **Nested Structure**: Support for deep configuration hierarchies
- **Hot Reloading**: Automatic reloading when configuration files change
- **Validation**: Built-in configuration validation with error reporting
- **Default Values**: Automatic fallback to default settings

## Configuration Sections

### Applications Configuration

Manages application definitions and hotkey mappings:

```lua
config.applications = {
    launcher_apps = {},      -- App launcher hotkeys
    media_controls = {},     -- Media control bindings
    problematic_apps = {},   -- Apps that may need restarting
    browsers = {},          -- Browser identification
    startup = {}            -- Automatic app launch settings
}
```

### Hotkey Configuration

Centralizes all hotkey definitions:

```lua
config.hotkeys = {
    system = {},            -- System management hotkeys
    window = {},            -- Window positioning shortcuts
    launcher = {},          -- App launcher modifier
    media = {},             -- Media control modifier
    keycastr = {}           -- Keystroke visualizer controls
}
```

### Visual Configuration

Controls appearance and visual behavior:

```lua
config.visual = {
    window = {},            -- Window management visual settings
    notifications = {},     -- Notification appearance
    themes = {},           -- Color themes
    animations = {}        -- Animation settings
}
```

### WiFi Configuration

Network automation and profiles:

```lua
config.wifi = {
    muted_ssids = {},       -- Networks that trigger audio muting
    network_profiles = {},  -- Per-network configurations
    behavior = {},         -- Automation settings
    notifications = {}     -- Network change notifications
}
```

## Usage

### Accessing Configuration

```lua
-- Get configuration values with fallback
local enabled = config.get("keycastr.enabled", false)
local tolerance = config.get("visual.window.tolerance", 20)

-- Set configuration values
config.set("keycastr.enabled", true)
config.set("visual.window.tolerance", 15)

-- Get entire configuration section
local app_config = config.get("applications")
```

### Configuration Validation

```lua
-- Validate entire configuration
local valid, issues = config.validate()
if not valid then
    for _, issue in ipairs(issues) do
        print("Configuration issue:", issue)
    end
end
```

## Integration

### Module Integration

- **All Modules**: Every module accesses configuration through this system
- **Init System**: Coordinates module initialization with configuration
- **Hot Reload**: Automatic reloading when files change
- **Error Handling**: Graceful degradation with fallback values

### Hotkey System Integration

- **Central Binding**: All hotkey definitions centralized in configuration
- **Modifier Patterns**: Consistent modifier key usage across modules
- **Conflict Detection**: Automatic detection of hotkey conflicts
- **Dynamic Loading**: Runtime hotkey changes supported

## Performance

- **Lazy Loading**: Configuration files loaded on demand
- **Caching**: Frequently accessed values cached for performance
- **Efficient Validation**: Optimized configuration validation
- **Memory Management**: Automatic cleanup of unused configuration