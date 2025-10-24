# Hammerspoon Modular System Documentation

This directory contains comprehensive documentation for the modular Hammerspoon automation system. Each module and system component is thoroughly documented with usage examples, configuration options, and API references.

## Documentation Structure

### 🏗️ System Architecture
- **[SystemArchitecture.md](SystemArchitecture.md)** - High-level system design, module relationships, and data flow
- **[ConfigurationSystem.md](ConfigurationSystem.md)** - Configuration management, validation, and loading strategies
- **[ModuleSystem.md](ModuleSystem.md)** - Module initialization, dependency management, and lifecycle

### 🔧 Core Infrastructure
- **[CoreLogger.md](CoreLogger.md)** - Logging system with levels, outputs, and formatting
- **[ConfigLoader.md](ConfigLoader.md)** - Configuration file loading, merging, and validation
- **[InitSystem.md](InitSystem.md)** - Module initialization system with dependency resolution

### 🛠️ Utility Modules
- **[AppUtils.md](AppUtils.md)** - Application management, toggling, and browser detection
- **[DisplayUtils.md](DisplayUtils.md)** - Display detection, frame calculations, and multi-monitor support
- **[NotificationUtils.md](NotificationUtils.md)** - macOS notification system and alert management
- **[WindowUtils.md](WindowUtils.md)** - Window manipulation, frame management, and cross-display operations

### 🚀 Feature Modules
- **[WindowManagement.md](WindowManagement.md)** - Magnet-style window positioning with contextual behavior
- **[AppLauncher.md](AppLauncher.md)** - Fast application launching with customizable hotkeys
- **[MediaControls.md](MediaControls.md)** - Media playback control and system audio management
- **[MouseManagement.md](MouseManagement.md)** - Mouse scroll reversal, button customization, and acceleration
- **[WiFiAutomation.md](WiFiAutomation.md)** - Network-based audio automation and location services
- **[KeystrokeVisualizer.md](KeystrokeVisualizer.md)** - Keystroke visualization with display modes and effects
- **[WindowExpose.md](WindowExpose.md)** - Window expose functionality with thumbnail previews (lazy-loaded)

### ⚙️ Configuration
- **[HotkeyConfiguration.md](HotkeyConfiguration.md)** - Hotkey definitions, modifiers, and customization
- **[AppConfiguration.md](AppConfiguration.md)** - Application launcher and media control configurations
- **[WiFiConfiguration.md](WiFiConfiguration.md)** - Network profiles and automation settings
- **[KeyCastrConfiguration.md](KeyCastrConfiguration.md)** - Keystroke visualization appearance and behavior

## Quick Start

1. **System Overview**: Start with [SystemArchitecture.md](SystemArchitecture.md) to understand the overall design
2. **Configuration**: See [ConfigurationSystem.md](ConfigurationSystem.md) for setup and customization
3. **Module Development**: Read [ModuleSystem.md](ModuleSystem.md) for extending the system
4. **Feature Documentation**: Explore individual feature modules for specific functionality

## Key Features

- **Modular Architecture**: Clean separation of concerns with dependency management
- **Configuration Management**: Centralized configuration with validation and hot-reloading
- **Lazy Loading**: Performance-optimized loading of heavy modules
- **Cross-Display Support**: Sophisticated multi-monitor window management
- **Extensible Design**: Easy to add new modules and features
- **Comprehensive Logging**: Debuggable with detailed logging and error handling

## Conventions

- **Module Structure**: Each module follows consistent patterns for initialization and configuration
- **Configuration**: All settings are centralized in `config/` directory
- **Logging**: Uses structured logging with module-specific loggers
- **Error Handling**: Graceful degradation with fallback implementations
- **Hotkeys**: Consistent modifier patterns across all features

## File Organization

```
docs/
├── SystemArchitecture.md          # High-level system design
├── ConfigurationSystem.md        # Configuration management
├── ModuleSystem.md              # Module lifecycle and dependencies
├── CoreLogger.md               # Core logging infrastructure
├── ConfigLoader.md             # Configuration loading system
├── InitSystem.md               # Module initialization
├── AppUtils.md                 # Application utilities
├── DisplayUtils.md             # Display management utilities
├── NotificationUtils.md        # Notification system
├── WindowUtils.md              # Window manipulation utilities
├── WindowManagement.md        # Window positioning system
├── AppLauncher.md              # Application launching
├── MediaControls.md            # Media and system controls
├── MouseManagement.md          # Mouse and input management
├── WiFiAutomation.md          # Network automation
├── KeystrokeVisualizer.md     # Keystroke visualization
├── WindowExpose.md             # Window expose functionality
├── HotkeyConfiguration.md     # Hotkey setup and customization
├── AppConfiguration.md         # Application configuration
├── WiFiConfiguration.md        # Network and WiFi configuration
└── KeyCastrConfiguration.md   # Visualization configuration
```