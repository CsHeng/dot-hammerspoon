# Media Controls

## Overview

Media Controls provides comprehensive media playback and system audio control through keyboard shortcuts. Control volume, playback, screen brightness, and audio devices with consistent hotkey patterns across all applications.

## Hotkey System

### Media Playback Control

**Modifier:** `ctrl+cmd+alt` + arrow keys and space

| Shortcut | Action | Result |
|----------|--------|---------|
| `ctrl+cmd+alt+←` | Previous Track | Skip to previous track |
| `ctrl+cmd+alt+→` | Next Track | Skip to next track |
| `ctrl+cmd+alt+Space` | Play/Pause | Toggle media playback |
| `ctrl+cmd+alt+Up` | Volume Up | Increase system volume |
| `ctrl+cmd+alt+Down` | Volume Down | Decrease system volume |
| `ctrl+cmd+alt+M` | Mute | Toggle system mute |

### Alternative Volume Control

**Modifier:** `ctrl+cmd` + arrow keys

| Shortcut | Action | Result |
|----------|--------|---------|
| `ctrl+cmd+↑` | Volume Up | Alternative volume up control |
| `ctrl+cmd+↓` | Volume Down | Alternative volume down control |

### System Controls

**Modifier:** `ctrl+cmd+alt` + symbol keys

| Shortcut | Action | Result |
|----------|--------|---------|
| `ctrl+cmd+alt+[` | Brightness Down | Decrease display brightness |
| `ctrl+cmd+alt+]` | Brightness Up | Increase display brightness |
| `ctrl+cmd+alt+;` | Keyboard Backlight Down | Decrease keyboard brightness |
| `ctrl+cmd+alt+'` | Keyboard Backlight Up | Increase keyboard brightness |

## Key Features

### Universal Media Control

- **Application-Agnostic**: Works with Spotify, Apple Music, VLC, YouTube, and more
- **System Integration**: Direct control over macOS audio subsystem
- **Playback State**: Accurate play/pause state detection
- **Track Information**: Displays current track information when available

### Volume Management

- **Fine Control**: Small increments for precise volume adjustment
- **Mute Toggle**: Quick mute/unmute with volume preservation
- **Visual Feedback**: On-screen volume indicators
- **Multiple Methods**: Alternative hotkey patterns for volume control

### System Display Controls

- **Brightness Adjustment**: Hardware-level brightness control
- **Keyboard Backlight**: Backlit keyboard illumination control
- **Fine Gradients**: Small steps for precise adjustment
- **Multi-Monitor Support**: Per-display brightness control where supported

### Device Management

- **Audio Device Detection**: Automatic discovery of connected audio devices
- **Quick Switching**: Seamless switching between audio outputs
- **Bluetooth Integration**: Bluetooth audio device management
- **Profile Memory**: Remembers device preferences per application

## Integration

### Application Support

- **Music Apps**: Spotify, Apple Music, Vox, YouTube Music
- **Video Players**: VLC, QuickTime, YouTube, Netflix
- **Communication**: Zoom, Teams, Discord volume control
- **Web Browsers**: Media control in web-based players

### System Integration

- **Core Audio**: Direct macOS audio system integration
- **Display Control**: Hardware brightness and backlight control
- **Notification System**: Feedback for volume and brightness changes
- **Configuration System**: Centralized settings management

## Usage Examples

### Daily Media Control

1. **Music Listening**: Control Spotify/Apple Music without switching apps
2. **Video Watching**: Play/pause YouTube and Netflix from any application
3. **Meeting Management**: Quick volume adjustment during calls
4. **Environment Control**: Adjust screen brightness for different lighting conditions

### Productivity Enhancement

- **Focus Mode**: Quick audio control without interrupting workflow
- **Presentation Control**: Media control during presentations
- **Meeting Prep**: Rapid audio device switching for different contexts
- **Accessibility**: Enhanced control for users with accessibility needs

## Configuration

### Customization Options

Configure in `config/applications.lua`:

- **media_controls**: Define media control hotkeys
- **volume_steps**: Set volume increment/decrement amounts
- **brightness_steps**: Set brightness adjustment increments
- **device_preferences**: Specify preferred audio devices

### Behavior Settings

- **show_notifications**: Enable/disable control feedback
- **volume_limits**: Set maximum volume for safety
- **device_memory**: Remember device selections per application
- **auto_switch**: Automatically switch devices based on context

## Performance

- **Low Latency**: Immediate response to hotkey presses
- **Minimal Overhead**: Efficient system resource usage
- **Background Operation**: Non-blocking media detection
- **Smart Caching**: Remembers device states for quick access