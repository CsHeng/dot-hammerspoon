# App Launcher

## Overview

The App Launcher provides intelligent application launching and toggling with smart user feedback. Launch applications quickly using customizable hotkeys, toggle between running applications with context-aware behavior, and manage application lifecycle with intelligent process detection and minimal notifications.

### Key Features

- **🎯 Smart Toggle Logic**: Different behavior based on application state (new launch vs. toggle)
- **📢 Process-Aware Alerts**: Only show notifications when actually launching new processes
- **⚡️ Instant Access**: Single hotkey application launching and switching
- **🔒 Application Protection**: Prevent accidental quits with double-press protection
- **⚙️ Flexible Configuration**: Centralized application definitions and hotkey customization

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

- **Smart Toggle Logic**: Different behavior based on application state
  - **Not Running**: Launch application process, show "Launched" alert
  - **Running in Background**: Bring to front, no alert
  - **Running in Foreground**: Hide to background, no alert
- **Process-Aware Alerts**: Only notify when actually launching new processes
- **Multi-Window Support**: Handle applications with multiple windows
- **Bundle ID Support**: Reliable application identification
- **Process Monitoring**: Accurate detection of running applications

### Application Protection

- **Double-Press Protection**: Prevents accidental Cmd+Q quits
- **Problematic App Handling**: Quick restart for unresponsive applications
- **Safe Termination**: Proper process cleanup and resource management
- **Window State Preservation**: Maintains window positions during restarts

### Smart User Feedback

- **Context-Aware Alerts**: Only show notifications for meaningful actions
- **Launch Confirmation**: Brief "Launched: [App]" alert when starting new processes
- **Silent Operations**: No alerts for app hiding/showing toggles
- **Minimal Distraction**: Clean workflow without unnecessary notifications

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

### Smart Toggle Behavior

The application launcher intelligently handles different scenarios:

#### Scenario 1: First Launch
```lua
-- Ghostty is not running
-- Press F10
-- → Ghostty process starts
-- → Shows "Launched: Ghostty" alert (1 second)
-- → Ghostty comes to front
```

#### Scenario 2: Switch to Running App
```lua
-- Ghostty is running in background
-- Press F10
-- → Ghostty comes to front
-- → No alert shown
```

#### Scenario 3: Hide Running App
```lua
-- Ghostty is running in front
-- Press F10
-- → Ghostty hides to background
-- → No alert shown
```

### Custom Applications

```lua
-- Add your favorite applications in config/applications.lua
config.applications.launcher_apps = {
    {key = "v", name = "Visual Studio Code", bundleid = "com.microsoft.vscode"},
    {key = "d", name = "Discord", bundleid = "com.hiscord.Discord"},
    {key = "n", name = "Notes", bundleid = "com.apple.Notes"}
}
```

## API Reference

### `app_launcher.launchOrToggleApp(app_name, bundle_id)`

Intelligently launches or toggles application visibility with smart user feedback.

**Parameters:**
- `app_name` (string): Human-readable application name
- `bundle_id` (string): macOS bundle identifier for application detection

**Behavior:**
- **Process not running**: Launch application, show "Launched: [App]" alert
- **Process running in background**: Bring to front, no alert
- **Process running in foreground**: Hide to background, no alert

**Returns:** None (operates via side effects)

**Example:**
```lua
-- Smart toggle Ghostty terminal
app_launcher.launchOrToggleApp("Ghostty", "com.mitchellh.ghostty")

-- Smart toggle Chrome browser
app_launcher.launchOrToggleApp("Google Chrome", "com.google.Chrome")
```

### `app_launcher.launchApp(identifier)`

Launches application by name or bundle ID.

**Parameters:**
- `identifier` (string): Application name or bundle ID

**Behavior:**
- Always attempts to launch/focus the application
- No success/failure alerts shown
- Logs warnings for failed operations

**Example:**
```lua
-- Launch by bundle ID
app_launcher.launchApp("com.microsoft.vscode")

-- Launch by name
app_launcher.launchApp("Visual Studio Code")
```

### `app_launcher.restartApp(app_name, bundle_id)`

Restarts an application by terminating and relaunching.

**Parameters:**
- `app_name` (string): Human-readable application name
- `bundle_id` (string): macOS bundle identifier

**Behavior:**
- Terminates existing process
- Waits 5 seconds
- Relaunches application
- No notifications shown

**Example:**
```lua
-- Restart problematic application
app_launcher.restartApp("DisplayLink Manager", "com.displaylink.DisplayLinkUserAgent")
```

### `app_launcher.killApp(identifier, force)`

Force quits an application.

**Parameters:**
- `identifier` (string): Application name or bundle ID
- `force` (boolean, optional): Force termination (default: true)

**Behavior:**
- Immediately terminates application process
- No graceful shutdown
- No notifications shown

**Example:**
```lua
-- Force quit unresponsive application
app_launcher.killApp("com.apple.Terminal", true)

-- Regular quit attempt
app_launcher.killApp("TextEdit", false)
```

## Configuration

### Application Setup

Configure applications in `config/applications.lua`:

- **launcher_apps**: Regular application hotkeys
- **problematic_apps**: Apps that may need restarting
- **startup**: Automatic launch configuration
- **browsers**: Special browser recognition settings

#### Hotkey Configuration Options

```lua
-- Basic application hotkey
{modifier = {"cmd", "alt"}, key = 'C', appname = 'Cursor', bundleid = 'com.todesktop.230313mzl4w4u92'},

-- Special hotkey (no modifier)
{modifier = {}, key = 'F10', appname = 'Ghostty', bundleid = 'com.mitchellh.ghostty'},

-- Hotkey with custom description (shows when pressed)
{modifier = {"cmd", "alt"}, key = 'V', appname = 'VS Code', bundleid = 'com.microsoft.vscode', hotkey_desc = 'Launch VS Code'},

-- Hotkey without description (no popup when pressed)
{modifier = {"cmd", "alt"}, key = 'S', appname = 'Safari', bundleid = 'com.apple.Safari', hotkey_desc = ''}
```

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