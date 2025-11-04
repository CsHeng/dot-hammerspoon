# WiFi Automation

## Overview

WiFi Automation provides network-aware automation features that adapt system behavior based on current WiFi connection. This module automatically manages audio settings, launches applications, and provides notifications based on network profiles.

## Core Functionality

### Network Monitoring and Detection

- **Network Change Detection**: Monitors WiFi connection changes in real-time
- **SSID Identification**: Identifies current network and matches against configured profiles
- **Location Services Integration**: Uses location services for reliable network detection
- **Network Information Retrieval**: Provides detailed network connection information

### Audio Automation

- **Automatic Muting**: Mutes built-in audio on configured work networks
- **Audio Device Switching**: Automatically switches to preferred audio devices per network
- **Volume Management**: Sets appropriate volume levels based on network profile
- **Audio State Restoration**: Restores previous audio settings when leaving work networks

### Application Automation

- **Network-Based App Launching**: Automatically launches applications based on WiFi network
- **App Profile Management**: Configures different app sets for different networks
- **Startup Sequences**: Defines timed application launch sequences for each network
- **Application State Management**: Manages application states based on network context

### Notification System

- **Network Change Notifications**: Alerts user when WiFi connection changes
- **Disconnect Handling**: Remembers the previous SSID so disconnect banners identify which network dropped (falls back to “WiFi” when none)
- **Profile Loading Notifications**: Informs user when network profile is applied
- **Audio Control Notifications**: Notifies of audio automation actions
- **Error and Status Notifications**: Provides feedback on system status

## API Reference

### Network Monitoring

- `wifi_automation.getCurrentNetwork()` - Get current WiFi network information
- `wifi_automation.onSSIDChanged()` - Handle network change events
- `wifi_automation.isWorkNetwork(ssid)` - Check if network is configured as work network
- `wifi_automation.getNetworkInfo()` - Get detailed network connection information

### Audio Control

- `wifi_automation.handleWorkNetwork(ssid, info)` - Apply work network audio settings
- `wifi_automation.toggleBuiltinAudioMute()` - Toggle built-in audio mute state
- `wifi_automation.setAudioDevice(device)` - Switch to specified audio device
- `wifi_automation.restoreAudioState()` - Restore previous audio settings

### Profile Management

- `wifi_automation.getCurrentNetworkProfile()` - Get profile for current network
- `wifi_automation.applyNetworkProfile(ssid)` - Apply network-specific profile
- `wifi_automation.launchNetworkApps(ssid)` - Launch apps for current network
- `wifi_automation.configureNetworkSettings(ssid)` - Apply network-specific settings

### Utility Functions

- `wifi_automation.enableLocationServices()` - Enable location services for network detection
- `wifi_automation.disableLocationServices()` - Disable location services
- `wifi_automation.getNetworkHistory()` - Get history of network connections
- `wifi_automation.debugNetworkState()` - Display current network debugging information

## Configuration

### Network Profiles

Configure per-network behavior in `config/wifi.lua`:

```lua
config.wifi = {
    -- Work networks that trigger audio muting
    muted_ssids = {
        "Work-Network",
        "Enterprise-WiFi"
    },

    -- Network-specific profiles
    network_profiles = {
        ["Home-WiFi"] = {
            audio_device = "Built-in Speakers",
            volume = 50,
            apps = {"Music", "Safari"},
            notifications = true
        },
        ["Work-Network"] = {
            audio_device = "Headphones",
            volume = 30,
            apps = {"Slack", "Zoom", "Mail"},
            auto_mute = true
        }
    }
}
```

### Automation Settings

- **Audio Automation**: Enable/disable automatic audio control
- **App Launching**: Configure automatic application launching
- **Notification Settings**: Control which notifications are shown
- **Location Services**: Enable location services fallback for network detection

## Integration

### System Integration

- **Audio System**: Integrates with macOS audio management
- **Application Management**: Works with app launcher module
- **Notification System**: Uses notification utilities for user feedback
- **Configuration System**: Reads settings from centralized configuration

### Event-Driven Operation

- **Network Change Events**: Responds to WiFi connection/disconnection
- **System Wake Events**: Handles network changes on system wake
- **User-Initiated Changes**: Supports manual network profile switching
- **Error Recovery**: Gracefully handles network detection failures

## Usage Scenarios

### Work Environment

Automatically mutes audio, launches communication apps, and sets appropriate audio devices when connecting to work WiFi.

### Home Environment

Launches entertainment apps, sets comfortable volume levels, and enables full audio functionality.

### Public WiFi

Applies security-conscious settings, limits automatic app launching, and provides connection notifications.

## Performance

- **Low Overhead**: Minimal system resource usage
- **Efficient Monitoring**: Optimized network change detection
- **Smart Caching**: Caches network information to reduce system calls
- **Background Operation**: Runs silently without interrupting user workflow
