# Hammerspoon System Architecture

## Overview

The Hammerspoon modular system implements a sophisticated automation framework for macOS with a clean, extensible architecture. This document describes the high-level system design, module relationships, and data flow patterns.

## System Design Principles

### 1. **Modular Architecture**
- **Separation of Concerns**: Each module has a specific, well-defined responsibility
- **Dependency Management**: Modules declare dependencies and load in proper order
- **Encapsulation**: Internal module details are hidden behind clean APIs
- **Extensibility**: New modules can be added without modifying existing code

### 2. **Configuration-Driven**
- **Centralized Configuration**: All settings in `config/` directory
- **Schema Validation**: Configuration validation with error reporting
- **Hot Reloading**: Configuration changes apply without restart
- **Environment-Specific**: Support for different configurations per environment

### 3. **Performance Optimized**
- **Lazy Loading**: Heavy modules load on-demand
- **Event-Driven**: Responsive to system events and user actions
- **Resource Management**: Cleanup of unused resources and frames
- **Minimal Overhead**: Efficient initialization and execution

## Core System Components

```
┌─────────────────────────────────────────────────────────────────┐
│                     Main Entry Point                           │
│                      init.lua                                 │
└─────────────────────────┬───────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────────┐
│                   Core Infrastructure                          │
│  ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐ │
│  │   core.logger   │ │ core.config_    │ │ core.init_      │ │
│  │                 │ │ loader         │ │ system         │ │
│  │ • Logging       │ │ • Config       │ │ • Module       │ │
│  │   System        │ │   Management   │ │   Lifecycle    │ │
│  │ • Structured    │ │ • Validation   │ │ • Dependency   │ │
│  │   Output        │ │ • File Loading │ │   Resolution   │ │
│  └─────────────────┘ └─────────────────┘ └─────────────────┘ │
└─────────────────────────┬───────────────────────────────────────┘
                          │
          ┌───────────────┴───────────────┐
          │                               │
          ▼                               ▼
┌─────────────────────────┐ ┌─────────────────────────┐
│     Utility Modules     │ │    Feature Modules      │
│ ┌─────────────────────┐ │ │ ┌─────────────────────┐ │
│ │ utils.app_utils     │ │ │ │ modules.window_     │ │
│ │                     │ │ │ │   management        │ │
│ │ • App Management    │ │ │ │ • Window            │ │
│ │ • Browser Detect    │ │ │ │   Positioning        │ │
│ │ • Toggle/Restart    │ │ │ │ • Multi-Monitor     │ │
│ └─────────────────────┘ │ │ │   Support          │ │
│ ┌─────────────────────┐ │ │ └─────────────────────┘ │
│ │ utils.display_     │ │ │ ┌─────────────────────┐ │
│ │ utils              │ │ │ │ modules.app_         │ │
│ │                     │ │ │ │ launcher            │ │
│ │ • Display Detect    │ │ │ │ • Fast App          │ │
│ │ • Frame Calcula-    │ │ │ │   Launching         │ │
│ │   tions            │ │ │ │ • Customizable       │ │
│ │ • Multi-Monitor    │ │ │ │   Hotkeys           │ │
│ │   Management       │ │ │ └─────────────────────┘ │
│ └─────────────────────┘ │ │ ┌─────────────────────┐ │
│ ┌─────────────────────┐ │ │ │ modules.media_       │ │
│ │ utils.notifica-    │ │ │ │ controls            │ │
│ │ tion_utils         │ │ │ │ • Media Control      │ │
│ │                     │ │ │ │ • System Audio       │ │
│ │ • macOS Notify      │ │ │ │ • Brightness/        │ │
│ │   System           │ │ │ │   Backlight          │ │
│ │ • Alert Manager     │ │ │ └─────────────────────┘ │
│ └─────────────────────┘ │ │ ┌─────────────────────┐ │
│ ┌─────────────────────┐ │ │ │ modules.mouse_       │ │
│ │ utils.window_      │ │ │ │ management          │ │
│ │ utils              │ │ │ │ • Scroll Reversal    │ │
│ │                     │ │ │ • Button Custom-      │ │
│ │ • Window Frame      │ │ │ │   ization          │ │
│ │   Management       │ │ │ • Speed Control       │ │
│ │ • Cross-Display    │ │ │ • Acceleration       │ │
│ │   Movement         │ │ │   Management         │ │
│ │ • Position Logic   │ │ └─────────────────────┘ │
│ └─────────────────────┘ │ ┌─────────────────────┐ │
└─────────────────────────┘ │ │ modules.wifi_        │
                          │ │ automation          │
                          │ │ │ • Network-Based     │
                          │ │ │   Automation       │
                          │ │ • Location Services  │
                          │ │ • Audio Muting       │
                          │ └─────────────────────┘
                          │ ┌─────────────────────┐
                          │ │ modules.key-        │
                          │ │ stroke_visualizer   │
                          │ │ │ • Keystroke        │
                          │ │ │   Visualization    │
                          │ │ • Visual Effects    │
                          │ │ • Click Circle      │
                          │ └─────────────────────┘
                          │ ┌─────────────────────┐
                          │ │ modules.window_      │
                          │ │ expose (lazy)       │
                          │ │ │ • Window Expose    │
                          │ │ │ • Thumbnails       │
                          │ │ │ • Cross-Space      │
                          │ │ └─────────────────────┘
                          └─────────────────────────┘
```

## Module Categories

### Core Infrastructure
**Purpose**: Provide foundational services for the entire system

- **`core.logger`**: Structured logging with levels, outputs, and formatting
- **`core.config_loader`**: Configuration management, validation, and merging
- **`core.init_system`**: Module initialization with dependency resolution

### Utility Modules
**Purpose**: Provide reusable functionality across feature modules

- **`utils.app_utils`**: Application management, browser detection, lifecycle control
- **`utils.display_utils`**: Display detection, frame calculations, multi-monitor support
- **`utils.notification_utils`**: macOS notification system and alert management
- **`utils.window_utils`**: Window manipulation, frame management, cross-display operations

### Feature Modules
**Purpose**: Deliver specific automation features to users

- **`modules.window_management`**: Magnet-style window positioning with contextual behavior
- **`modules.app_launcher`**: Fast application launching with customizable hotkeys
- **`modules.media_controls`**: Media playback control and system audio management
- **`modules.mouse_management`**: Mouse scroll reversal and button customization
- **`modules.wifi_automation`**: Network-based audio automation and location services
- **`modules.keystroke_visualizer`**: Keystroke visualization with display modes
- **`modules.window_expose`**: Window expose functionality (lazy-loaded)

## Data Flow Patterns

### 1. **Initialization Flow**
```
init.lua
  │
  ├─▶ Load core infrastructure (logger, config_loader, init_system)
  │
  ├─▶ Register modules with init_system
  │
  ├─▶ Load utility modules in dependency order
  │
  ├─▶ Load feature modules in dependency order
  │
  └─▶ Setup lazy-loading for window_expose
```

### 2. **Configuration Flow**
```
config/*.lua files
  │
  ├─▶ config_loader: Load and merge configurations
  │
  ├─▶ config_loader: Validate configuration schema
  │
  ├─▶ Modules: Access configuration through config_loader API
  │
  └─▶ Runtime: Hot-reload configuration changes
```

### 3. **Event Processing Flow**
```
System Events (WiFi, Display, etc.)
  │
  ├─▶ Event Handlers: Process events
  │
  ├─▶ Business Logic: Apply rules and automation
  │
  ├─▶ Utility Functions: Execute operations
  │
  └─▶ User Feedback: Notifications and visual indicators
```

## Key Design Patterns

### 1. **Module Pattern**
Each module follows a consistent structure:
```lua
local M = {}

-- Module dependencies
local some_dependency = require("module.dependency")

-- Private functions and state
local private_state = {}

-- Public API functions
function M.publicFunction()
    -- Implementation
end

-- Module initialization
function M.init()
    -- Setup module
end

return M
```

### 2. **Configuration Pattern**
Configuration is centralized with validation:
```lua
-- config/module_name.lua
local config = {
    setting1 = "value1",
    setting2 = {
        nested_setting = "value2"
    }
}

return config
```

### 3. **Logging Pattern**
Structured logging with module-specific loggers:
```lua
local logger = require("core.logger")
local log = logger.getLogger("module_name")

log:i("Informational message")
log:w("Warning message")
log:e("Error message")
log:d("Debug message")
```

### 4. **Error Handling Pattern**
Graceful degradation with fallbacks:
```lua
local success, result = pcall(function()
    -- Potentially failing operation
end)

if not success then
    log:e(string.format("Operation failed: %s", result))
    -- Fallback implementation
end
```

## Performance Characteristics

### 1. **Startup Performance**
- **Fast Loading**: Only essential modules load during startup
- **Lazy Loading**: Heavy modules (window_expose) load on-demand
- **Dependency Optimization**: Modules load in parallel where possible
- **Minimal Overhead**: Efficient initialization sequences

### 2. **Runtime Performance**
- **Event-Driven**: Responsive to system events without polling
- **Resource Management**: Automatic cleanup of unused resources
- **Memory Efficient**: Frame storage with periodic cleanup
- **CPU Optimized**: Efficient algorithms for window management

### 3. **Memory Usage**
- **Frame Storage**: Per-window frame memory with cleanup
- **Module Isolation**: Each module manages its own state
- **Resource Cleanup**: Automatic cleanup of timers and watchers
- **Leak Prevention**: Proper disposal of system resources

## Extensibility

### 1. **Adding New Modules**
1. Create module file in appropriate directory (`utils/` or `modules/`)
2. Follow established module patterns
3. Declare dependencies in `core.init_system`
4. Add configuration in `config/` directory
5. Update documentation

### 2. **Configuration Extension**
1. Add configuration file in `config/` directory
2. Define schema in `core.config_loader`
3. Add validation rules
4. Update configuration documentation

### 3. **Feature Enhancement**
1. Modify existing module following established patterns
2. Maintain backward compatibility where possible
3. Update configuration schema if needed
4. Update module documentation

## Monitoring and Debugging

### 1. **Logging System**
- **Structured Output**: Consistent log format with timestamps
- **Log Levels**: Debug, Info, Warning, Error with configurable levels
- **Module-Specific**: Each module has its own logger instance
- **Performance**: Efficient logging with minimal overhead

### 2. **Status Reporting**
- **Module Status**: Real-time status of all modules
- **Configuration Validation**: Detailed validation reports
- **Error Tracking**: Comprehensive error reporting and handling
- **Performance Metrics**: Timing and resource usage statistics

### 3. **Debug Tools**
- **Console Access**: Built-in console for live debugging
- **Hot Reload**: Configuration changes without restart
- **Module Reloading**: Individual module reload capability
- **State Inspection**: Ability to inspect internal module state