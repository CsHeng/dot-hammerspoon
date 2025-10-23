# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Hammerspoon Configuration

This is a Hammerspoon configuration repository for macOS automation. Hammerspoon is a desktop automation tool for macOS that allows extensive customization through Lua scripting.

### Core Components

#### `init.lua` - Entry Point
- Main configuration loader that sets up hotkey bindings
- Implements lazy loading for performance optimization
- Sets up system-wide keyboard shortcuts for Hammerspoon management
- Key bindings: `ctrl+cmd+alt+R` for reload, `ctrl+cmd+alt+H` for console

#### Key Modules

1. **Window Management** (`window.lua`)
   - Magnet-style window management with keyboard shortcuts
   - Supports left/right/top/bottom halves, corners, maximize, center, and original positions
   - Multi-monitor support with cross-display window movement
   - Smart window positioning that avoids cycling between displays

2. **Application Launcher** (`key_bindings.lua`)
   - Fast app launching with `cmd+alt+[KEY]` combinations
   - Media control with `ctrl+cmd+alt+[ARROW_KEYS/SPACE]`
   - Application restart functionality for problematic apps
   - Double-press protection for `cmd+Q` to prevent accidental quits
   - Mouse button customization (Logitech G603/GPW support)

3. **KeyCastr** (`keycastr.lua`)
   - Keystroke visualizer with customizable appearance
   - Supports different display modes and continuous input
   - Configurable fade effects and positioning
   - Optional mouse click visualization

4. **WiFi Automation** (`wifi.lua`)
   - Automatic audio muting on specific networks
   - Network change notifications
   - Location services integration for network monitoring

5. **Utilities** (`utils.lua`)
   - Common functions used across modules
   - Application management (toggle, restart)
   - Browser detection functions
   - Audio device management
   - macOS notification system

6. **Mouse Control** (`mouse_reverse_scroll.lua`)
   - Reverses mouse wheel scroll direction while preserving trackpad behavior
   - Event-based filtering to distinguish between mouse and trackpad input

7. **Expose** (`expose.lua`)
   - Window expose functionality with thumbnail previews
   - Cross-space window visibility
   - Lazy-loaded for performance optimization

### Key Modifier Patterns

- **Launcher Modifier**: `cmd+alt` for app switching
- **Hyper**: `ctrl+alt` for window management
- **Media Control**: `ctrl+cmd+alt` for media controls
- **System Control**: `ctrl+cmd+alt` for system functions

### Development Commands

#### Reloading Configuration
```bash
# Hammerspoon automatically reloads when init.lua is saved
# Manual reload via hotkey: ctrl+cmd+alt+R
# Open console: ctrl+cmd+alt+H
```

#### Testing Changes
- Test hotkey changes by reloading configuration
- Use Hammerspoon console (`ctrl+cmd+alt+H`) for live debugging
- Check logs in Console.app for Hammerspoon-specific messages

### Architecture Patterns

#### Lazy Loading
- The expose module is lazy-loaded to improve startup performance
- Controlled by `exposeLoaded` flag and `loadExpose()` function

#### Event-Based Architecture
- Heavy use of `hs.hotkey.bind()` for keyboard shortcuts
- Event tap filters for mouse and scroll wheel events
- WiFi watcher for network state changes

#### Utility Functions
- All utilities are exported through a module pattern (`local M = {}`)
- Common functions shared across modules to avoid code duplication
- Logging system using `hs.logger` for debugging

### Configuration Notes

#### Window Management Logic
- Smart edge detection prevents display cycling
- Original frame preservation for restore functionality
- Quarter-screen positioning with intuitive key mapping (HJKL for corners)

#### WiFi Network Handling
- Automatic muting for predefined work networks
- Location services workaround for network detection
- Persistent notifications for network state changes

#### Performance Considerations
- Lazy loading of heavy modules
- Event filtering to minimize unnecessary processing
- Careful memory management with window frame storage

### File Structure Conventions

- All `.lua` files should have appropriate shebang and encoding
- Use proper module pattern with `local M = {}` and `return M`
- Include descriptive comments for complex functionality
- Follow consistent naming conventions (camelCase for functions, snake_case for variables)