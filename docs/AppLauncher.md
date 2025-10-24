# App Launcher

## Overview

The App Launcher provides fast application launching with customizable hotkeys. Launch applications quickly using keyboard shortcuts, toggle between running apps, and manage application lifecycle with intelligent detection and protection features.

## Hotkey System

### Application Launching

**Modifier:** `cmd+alt` + letter keys

| Shortcut | Application | Behavior |
|----------|-------------|----------|
| `cmd+alt+C` | Cursor | Launch or focus Cursor editor |
| `cmd+alt+Q` | QQ | Launch or focus QQ messaging |
| `cmd+alt+W` | WeChat | Launch or focus WeChat messaging |
| `cmd+alt+D` | DingTalk | Launch or focus DingTalk collaboration |
| `cmd+alt+G` | Google Chrome | Launch or focus Chrome browser |
| `cmd+alt+F` | Finder | Launch or focus Finder file manager |
| `cmd+alt+H` | Hammerspoon | Launch or focus Hammerspoon console |
| `F10` | Ghostty | Launch or focus Ghostty terminal |

### Application Restart

**Modifier:** `ctrl+cmd+alt` + letter keys

| Shortcut | Application | Behavior |
|----------|-------------|----------|
| `ctrl+cmd+alt+D` | DisplayLink Manager | Restart DisplayLink Manager service |

### Quit Protection

| Shortcut | Action | Behavior |
|----------|--------|----------|
| `cmd+Q` | Protected Quit | Requires double-press to quit applications |

## Key Features

### Intelligent Application Detection

- **Toggle Behavior**: Launch if not running, focus if already running
- **Multi-Window Support**: Handle applications with multiple windows
- **Bundle ID Support**: Reliable application identification
- **Process Monitoring**: Accurate detection of running applications

### Application Protection

- **Double-Press Protection**: Prevents accidental Cmd+Q quits
- **Problematic App Handling**: Quick restart for unresponsive applications
- **Safe Termination**: Proper process cleanup and resource management
- **Window State Preservation**: Maintains window positions during restarts

### Configuration Management

- **Centralized Setup**: All app definitions in `config/applications.lua`
- **Custom Hotkeys**: User-defined key combinations
- **App Categories**: Group applications by function or workflow
- **Workspace Support**: Different app sets for different tasks

## Integration

### System Integration

- **macOS Application API**: Direct integration with system application management
- **Window Management**: Coordinates with window positioning system
- **Notification System**: Alerts for application status and errors
- **Configuration System**: Reads from centralized settings

### Workflow Integration

- **Development Environment**: Quick access to coding tools and terminals
- **Communication Suite**: Launch email, messaging, and meeting apps
- **Media Applications**: Access entertainment and productivity apps
- **Utility Tools**: Launch system utilities and helper applications

## Usage Examples

### Daily Workflow

1. **Morning Startup**: Launch email, calendar, and communication apps
2. **Work Sessions**: Development tools accessible with single hotkeys
3. **Quick Access**: Instant application switching without mouse navigation
4. **Error Recovery**: Fast restart of problematic applications

### Custom Applications

```lua
-- Add your favorite applications in config/applications.lua
config.applications.launcher_apps = {
    {key = "v", name = "Visual Studio Code", bundleid = "com.microsoft.vscode"},
    {key = "d", name = "Discord", bundleid = "com.hiscord.Discord"},
    {key = "n", name = "Notes", bundleid = "com.apple.Notes"}
}
```

## Configuration

### Application Setup

Configure applications in `config/applications.lua`:

- **launcher_apps**: Regular application hotkeys
- **problematic_apps**: Apps that may need restarting
- **startup**: Automatic launch configuration
- **browsers**: Special browser recognition settings

### Hotkey Customization

- **Modifier Keys**: Change `cmd+alt` to preferred combination
- **Key Assignments**: Customize letter keys for each app
- **Conflict Detection**: Automatic warning for conflicting hotkeys
- **Profile Support**: Different hotkey sets for different workflows

## Performance

- **Fast Launching**: Optimized for quick application startup
- **Minimal Overhead**: Efficient background monitoring
- **Smart Caching**: Remembers application states for instant access
- **Resource Management**: Low memory and CPU usage