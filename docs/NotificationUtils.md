# Notification Utils (NotificationUtils)

## Overview

NotificationUtils provides a multi-method notification system with fallback capabilities, audio device control, and persistent notification support. This module handles all user-facing notifications across the Hammerspoon configuration.

## Core Functionality

### Multi-Method Notifications

```lua
-- Basic notification methods
notification_utils.sendNotification(title, message, method)
notification_utils.sendMacOSNotification(title, message)
notification_utils.sendPersistentNotification(title, message)
notification_utils.sendVisualNotification(title, message)
```

### Notification Styling and Configuration

```lua
-- Styled notifications
notification_utils.sendStyledNotification(title, message, style)
notification_utils.sendColoredNotification(title, message, color)
notification_utils.sendTimedNotification(title, message, duration)

-- Notification with actions
notification_utils.sendActionNotification(title, message, actions, callback)
```

### Audio Device Management

```lua
-- Audio device control
notification_utils.getBuiltinOutputDevice()
notification_utils.setAudioVolume(device, volume, mute)
notification_utils.toggleBuiltinAudioMute()
notification_utils.adjustAudioVolume(device, delta)
```

### Notification History and Management

```lua
-- Notification tracking
notification_utils.getNotificationHistory()
notification_utils.clearNotificationHistory()
notification_utils.removeNotification(id)

-- Notification settings
notification_utils.setNotificationMethod(method)
notification_utils.getNotificationMethod()
```

## API Reference

### `notification_utils.sendNotification(title, message, method)`

Sends a notification using the specified method with fallback.

**Parameters:**
- `title` (string): Notification title
- `message` (string, optional): Notification message
- `method` (string, optional): Notification method ("persistent", "macos", "auto", default: "auto")

**Returns:**
- `success` (boolean): Whether notification was sent successfully
- `notification_id` (string): Notification identifier if successful

**Example:**
```lua
-- Send auto notification with fallback
local success, id = notification_utils.sendNotification(
    "Configuration Loaded",
    "Hammerspoon configuration has been reloaded",
    "auto"
)
if success then
    print("Notification sent with ID:", id)
end
```

### `notification_utils.sendMacOSNotification(title, message)`

Sends a notification using macOS system notifications.

**Parameters:**
- `title` (string): Notification title
- `message` (string, optional): Notification message

**Returns:**
- `success` (boolean): Whether notification was sent successfully
- `notification_id` (string): Notification identifier

**Example:**
```lua
-- Send macOS notification
local success, id = notification_utils.sendMacOSNotification(
    "System Event",
    "WiFi connection changed"
)
```

### `notification_utils.sendPersistentNotification(title, message)`

Sends a persistent notification using Hammerspoon's notify API.

**Parameters:**
- `title` (string): Notification title
- `message` (string, optional): Notification message

**Returns:**
- `success` (boolean): Whether notification was sent successfully
- `notification_id` (string): Notification identifier

**Example:**
```lua
-- Send persistent notification
local success, id = notification_utils.sendPersistentNotification(
    "Application Started",
    "Ghostty terminal has been launched"
)
```

### `notification_utils.sendStyledNotification(title, message, style)`

Sends a styled notification with custom appearance.

**Parameters:**
- `title` (string): Notification title
- `message` (string, optional): Notification message
- `style` (table): Style configuration table

**Returns:**
- `success` (boolean): Whether notification was sent successfully
- `notification_id` (string): Notification identifier

**Example:**
```lua
-- Send styled notification
local style = {
    backgroundColor = {red = 0.2, green = 0.6, blue = 0.2, alpha = 0.9},
    textColor = {red = 1, green = 1, blue = 1, alpha = 1},
    font = {name = "SF Mono", size = 12},
    duration = 5
}

local success, id = notification_utils.sendStyledNotification(
    "Success",
    "Operation completed successfully",
    style
)
```

### `notification_utils.sendColoredNotification(title, message, color)`

Sends a notification with a specific color theme.

**Parameters:**
- `title` (string): Notification title
- `message` (string, optional): Notification message
- `color` (string): Color theme ("success", "warning", "error", "info")

**Returns:**
- `success` (boolean): Whether notification was sent successfully
- `notification_id` (string): Notification identifier

**Example:**
```lua
-- Send colored notification for error
local success, id = notification_utils.sendColoredNotification(
    "Error",
    "Failed to connect to WiFi network",
    "error"
)
```

### `notification_utils.getBuiltinOutputDevice()`

Finds the built-in audio output device.

**Returns:**
- `device` (string): Name of built-in output device or nil if not found

**Example:**
```lua
-- Find built-in audio device
local builtin = notification_utils.getBuiltinOutputDevice()
if builtin then
    print("Built-in audio device:", builtin)
else
    print("No built-in audio device found")
end
```

### `notification_utils.setAudioVolume(device, volume, mute)`

Sets the volume for a specific audio device.

**Parameters:**
- `device` (string): Audio device name
- `volume` (number): Volume level (0-100)
- `mute` (boolean, optional): Whether to mute the device

**Returns:**
- `success` (boolean): Whether operation succeeded

**Example:**
```lua
-- Set volume to 50%
local success = notification_utils.setAudioVolume("Built-in Speakers", 50)
if success then
    print("Volume set to 50%")
end
```

### `notification_utils.toggleBuiltinAudioMute()`

Toggles mute state for built-in audio device.

**Returns:**
- `success` (boolean): Whether operation succeeded
- `is_muted` (boolean): New mute state if successful

**Example:**
```lua
-- Toggle built-in speaker mute
local success, muted = notification_utils.toggleBuiltinAudioMute()
if success then
    print("Built-in audio muted:", muted)
end
```

### `notification_utils.adjustAudioVolume(device, delta)`

Adjusts volume for a specific audio device.

**Parameters:**
- `device` (string): Audio device name
- `delta` (number): Volume adjustment amount (-100 to 100)

**Returns:**
- `success` (boolean): Whether operation succeeded
- `new_volume` (number): New volume level if successful

**Example:**
```lua
-- Increase volume by 10%
local success, volume = notification_utils.adjustAudioVolume("Built-in Speakers", 10)
if success then
    print("New volume:", volume)
end
```

### `notification_utils.getNotificationHistory()`

Returns the history of sent notifications.

**Returns:**
- `history` (array): Array of notification objects

**Example:**
```lua
-- Get notification history
local history = notification_utils.getNotificationHistory()
for _, notification in ipairs(history) do
    print(notification.title, notification.timestamp, notification.method)
end
```

### `notification_utils.clearNotificationHistory()`

Clears the notification history.

**Returns:**
- `count` (number): Number of notifications cleared

**Example:**
```lua
-- Clear notification history
local count = notification_utils.clearNotificationHistory()
print("Cleared", count, "notifications")
```

### `notification_utils.setNotificationMethod(method)`

Sets the default notification method.

**Parameters:**
- `method` (string): Default method ("persistent", "macos", "auto")

**Example:**
```lua
-- Set default method to macOS notifications
notification_utils.setNotificationMethod("macos")
```

### `notification_utils.getNotificationMethod()`

Gets the current default notification method.

**Returns:**
- `method` (string): Current default method

**Example:**
```lua
-- Get current notification method
local method = notification_utils.getNotificationMethod()
print("Current notification method:", method)
```

## Notification Methods

### 1. Persistent Notifications

Uses Hammerspoon's built-in notification system:

```lua
local function sendPersistentNotification(title, message)
    local notification = hs.notify.new({
        title = title,
        informativeText = message,
        soundName = "default",
        autoWithdraw = false
    })

    return notification:send()
end
```

### 2. macOS System Notifications

Uses AppleScript to send system notifications:

```lua
local function sendMacOSNotification(title, message)
    local script = string.format([[
        display notification "%s" with title "%s"
    ]], message or "", title)

    local success, output = hs.osascript.applescript(script)
    return success, output
end
```

### 3. Visual Notifications

Creates visual notifications using Hammerspoon's drawing module:

```lua
local function sendVisualNotification(title, message, style)
    -- Create text drawing
    local text = hs.drawing.text(hs.geometry.rect(0, 0, 400, 100), title)
    text:setTextStyle({
        font = style.font or "SF Mono",
        size = style.fontSize or 12,
        color = style.textColor or {red = 1, green = 1, blue = 1, alpha = 1}
    })

    -- Create background rectangle
    local bg = hs.drawing.rectangle(hs.geometry.rect(0, 0, 400, 100))
    bg:setFillColor(style.backgroundColor or {red = 0.2, green = 0.2, blue = 0.2, alpha = 0.9})

    -- Position and show
    local frame = hs.screen.mainScreen():frame()
    local x = frame.x + frame.w - 420
    local y = frame.y + 20

    text:setTopLeft(hs.geometry.point(x + 10, y + 10))
    bg:setTopLeft(hs.geometry.point(x, y))

    text:show()
    bg:show()

    -- Auto-hide after duration
    if style.duration and style.duration > 0 then
        hs.timer.doAfter(style.duration, function()
            text:delete()
            bg:delete()
        end)
    end
end
```

## Color Themes and Styles

### Predefined Color Themes

```lua
local COLOR_THEMES = {
    success = {
        backgroundColor = {red = 0.2, green = 0.8, blue = 0.2, alpha = 0.9},
        textColor = {red = 1, green = 1, blue = 1, alpha = 1},
        sound = "default"
    },
    warning = {
        backgroundColor = {red = 1, green = 0.8, blue = 0.2, alpha = 0.9},
        textColor = {red = 0, green = 0, blue = 0, alpha = 1},
        sound = "default"
    },
    error = {
        backgroundColor = {red = 0.8, green = 0.2, blue = 0.2, alpha = 0.9},
        textColor = {red = 1, green = 1, blue = 1, alpha = 1},
        sound = "Basso"
    },
    info = {
        backgroundColor = {red = 0.2, green = 0.6, blue = 1, alpha = 0.9},
        textColor = {red = 1, green = 1, blue = 1, alpha = 1},
        sound = "default"
    }
}
```

### Style Configuration

```lua
local DEFAULT_STYLE = {
    font = "SF Mono",
    fontSize = 12,
    backgroundColor = {red = 0.2, green = 0.2, blue = 0.2, alpha = 0.9},
    textColor = {red = 1, green = 1, blue = 1, alpha = 1},
    duration = 5,
    position = "top_right",  -- top_left, top_right, bottom_left, bottom_right
    margin = 20,
    maxWidth = 400,
    maxHeight = 100
}
```

## Audio Device Management

### Audio Device Discovery

```lua
-- Find audio devices by pattern
local function findAudioDevice(pattern, output)
    local devices = hs.audiodevice.allOutputDevices()

    for _, device in ipairs(devices) do
        if device:name():match(pattern) then
            return device
        end
    end

    return nil
end

-- Get all output devices
local function getAllOutputDevices()
    local devices = {}
    local audioDevices = hs.audiodevice.allOutputDevices()

    for _, device in ipairs(audioDevices) do
        table.insert(devices, {
            name = device:name(),
            uid = device:uid(),
            volume = device:volume(),
            muted = device:muted()
        })
    end

    return devices
end
```

### Volume Control

```lua
-- Safe volume adjustment
local function adjustVolumeSafely(device, delta)
    local currentVolume = device:volume()
    local newVolume = math.max(0, math.min(100, currentVolume + delta))

    device:setVolume(newVolume)
    return newVolume
end

-- Mute/unmute with notification
local function toggleMuteWithNotification(device)
    local wasMuted = device:muted()
    device:setMuted(not wasMuted)

    notification_utils.sendColoredNotification(
        "Audio Device",
        string.format("%s %s", device:name(), not wasMuted and "muted" or "unmuted"),
        "info"
    )

    return not wasMuted
end
```

## Notification History and Management

### Notification Tracking

```lua
-- Notification history management
local notification_history = {}
local notification_counter = 0

local function addToHistory(title, message, method, success)
    notification_counter = notification_counter + 1

    local entry = {
        id = "notification_" .. notification_counter,
        title = title,
        message = message,
        method = method,
        success = success,
        timestamp = os.time(),
        date = os.date("%Y-%m-%d %H:%M:%S")
    }

    table.insert(notification_history, entry)

    -- Limit history size
    if #notification_history > 100 then
        table.remove(notification_history, 1)
    end

    return entry.id
end

-- History query functions
local function getNotificationsByMethod(method)
    local filtered = {}
    for _, notification in ipairs(notification_history) do
        if notification.method == method then
            table.insert(filtered, notification)
        end
    end
    return filtered
end

local function getRecentNotifications(count)
    count = count or 10
    local recent = {}
    for i = #notification_history, math.max(1, #notification_history - count + 1), -1 do
        table.insert(recent, notification_history[i])
    end
    return recent
end
```

## Integration with Other Modules

### WiFi Automation Integration

```lua
-- Used by wifi_automation for network change notifications
local wifi_automation = {}

function wifi_automation.notifyNetworkChange(old_ssid, new_ssid)
    if old_ssid ~= new_ssid then
        local title = "Network Changed"
        local message = string.format("Connected to: %s", new_ssid or "Unknown")

        notification_utils.sendColoredNotification(title, message, "info")
    end
end

function wifi_automation.notifyWorkNetwork(ssid)
    local title = "Work Network Detected"
    local message = string.format("Connected to work network: %s", ssid)

    notification_utils.sendColoredNotification(title, message, "warning")

    -- Mute built-in audio
    notification_utils.toggleBuiltinAudioMute()
end
```

### Application Launcher Integration

```lua
-- Used by app_launcher for application status notifications
local app_launcher = {}

function app_launcher.notifyAppLaunched(app_name)
    local title = "Application Launched"
    local message = string.format("%s has been launched", app_name)

    notification_utils.sendColoredNotification(title, message, "success")
end

function app_launcher.notifyAppRestarted(app_name)
    local title = "Application Restarted"
    local message = string.format("%s has been restarted", app_name)

    notification_utils.sendColoredNotification(title, message, "warning")
end
```

### Window Management Integration

```lua
-- Used by window_management for positioning feedback
local window_management = {}

function window_management.notifyWindowPosition(position)
    local title = "Window Positioned"
    local message = string.format("Window moved to %s position", position)

    notification_utils.sendColoredNotification(title, message, "info")
end
```

## Performance Optimization

### Notification Queue

```lua
-- Queue notifications to prevent spam
local notification_queue = {}
local is_processing = false
local last_notification_time = 0
local notification_cooldown = 1.0  -- 1 second cooldown

local function processNotificationQueue()
    if is_processing then return end
    is_processing = true

    hs.timer.doAfter(notification_cooldown, function()
        if #notification_queue > 0 then
            local notification = table.remove(notification_queue, 1)

            -- Send notification
            local success, id = sendNotificationInternal(notification)

            if success then
                addToHistory(notification.title, notification.message,
                           notification.method, true)
            end

            -- Process next notification
            processNotificationQueue()
        else
            is_processing = false
        end
    end)
end

local function queueNotification(title, message, method, style)
    local notification = {
        title = title,
        message = message,
        method = method,
        style = style or COLOR_THEMES.info
    }

    table.insert(notification_queue, notification)
    processNotificationQueue()
end
```

### Rate Limiting

```lua
-- Rate limiting for similar notifications
local recent_notifications = {}
local rate_limit_window = 5  -- 5 seconds
local max_similar = 3

local function isRateLimited(title)
    local current_time = os.time()
    local recent_count = 0

    -- Clean old notifications
    for i = #recent_notifications, 1, -1 do
        if current_time - recent_notifications[i].time > rate_limit_window then
            table.remove(recent_notifications, i)
        else
            if recent_notifications[i].title == title then
                recent_count = recent_count + 1
            end
        end
    end

    -- Check if we're rate limited
    if recent_count >= max_similar then
        return true
    end

    -- Add to recent notifications
    table.insert(recent_notifications, {
        title = title,
        time = current_time
    })

    return false
end
```

## Debugging and Monitoring

### Notification Debugging

```lua
-- Debug notification methods
local function debugNotificationMethods()
    local methods = {"persistent", "macos", "auto"}

    for _, method in ipairs(methods) do
        local success, id = notification_utils.sendNotification(
            "Test Notification",
            string.format("Testing %s method", method),
            method
        )

        print(string.format("%s method: %s (ID: %s)",
            method, success and "SUCCESS" or "FAILED", id or "N/A"))
    end
end

-- Debug audio devices
local function debugAudioDevices()
    local devices = getAllOutputDevices()

    print("Available audio devices:")
    for _, device in ipairs(devices) do
        print(string.format("- %s (Volume: %d, Muted: %s)",
            device.name, device.volume, device.muted and "Yes" or "No"))
    end
end
```

### Performance Monitoring

```lua
-- Monitor notification performance
local notification_performance = {}

local function monitorNotificationPerformance()
    hs.timer.new(10, function()
        local current_time = os.time()
        local recent_count = 0

        -- Count recent notifications
        for _, notification in ipairs(notification_history) do
            if current_time - notification.timestamp <= 10 then
                recent_count = recent_count + 1
            end
        end

        notification_performance.recent_count = recent_count
        notification_performance.queue_length = #notification_queue
        notification_performance.total_count = #notification_history

        -- Log performance metrics
        if recent_count > 5 then
            print("Warning: High notification rate:", recent_count, "in last 10 seconds")
        end
    end):start()
end
```

## Best Practices

### 1. Notification Method Selection

```lua
-- Choose appropriate notification method
local function getBestNotificationMethod()
    -- Try macOS notifications first (system level)
    local success = notification_utils.sendMacOSNotification("Test", "Testing")
    if success then
        return "macos"
    end

    -- Fallback to persistent notifications
    return "persistent"
end
```

### 2. Error Handling

```lua
-- Robust notification sending
local function sendNotificationWithErrorHandling(title, message, method)
    local success, id = pcall(function()
        return notification_utils.sendNotification(title, message, method)
    end)

    if not success then
        print("Failed to send notification:", id)
        -- Try fallback method
        success, id = notification_utils.sendNotification(title, message, "persistent")
    end

    return success, id
end
```

### 3. User Experience

```lua
-- Non-intrusive notifications
local function sendNonIntrusiveNotification(title, message)
    local style = {
        backgroundColor = {red = 0.1, green = 0.1, blue = 0.1, alpha = 0.7},
        textColor = {red = 1, green = 1, blue = 1, alpha = 0.8},
        duration = 3,
        position = "top_right",
        sound = false
    }

    return notification_utils.sendStyledNotification(title, message, style)
end
```

### 4. Accessibility

```lua
-- Accessibility-friendly notifications
local function sendAccessibleNotification(title, message)
    -- Use system notifications with sound
    notification_utils.sendMacOSNotification(title, message)

    -- Also log to console for screen readers
    print("Notification:", title, message)

    return true
end
```

## Troubleshooting

### Common Issues

1. **macOS Notifications Not Working**: Check AppleScript permissions
2. **No Sound**: Check system sound settings and notification sound preferences
3. **Audio Device Not Found**: Verify audio device names and availability
4. **Rate Limiting**: Adjust rate limiting parameters for your use case

### Debug Commands

```lua
-- Test all notification methods
notification_utils.debugNotificationMethods()

-- Check available audio devices
notification_utils.debugAudioDevices()

-- View notification history
local history = notification_utils.getNotificationHistory()
for _, notification in ipairs(history) do
    print(notification.date, notification.title, notification.method)
end

-- Test audio device control
local builtin = notification_utils.getBuiltinOutputDevice()
if builtin then
    local success, volume = notification_utils.adjustAudioVolume(builtin, 10)
    print("Volume adjustment:", success and "SUCCESS" or "FAILED", volume)
end
```

## Advanced Usage

### Custom Notification Handlers

```lua
-- Create custom notification handlers
local custom_handlers = {}

function custom_handlers.logNotification(title, message)
    local log_entry = string.format("[%s] %s: %s",
        os.date("%Y-%m-%d %H:%M:%S"), title, message or "")

    local log_file = hs.configdir .. "/notification_log.txt"
    local file = io.open(log_file, "a")
    if file then
        file:write(log_entry .. "\n")
        file:close()
    end

    return true
end

function custom_handlers.discordNotification(title, message)
    -- Integrate with Discord webhook or other services
    local webhook_url = config.get("notifications.discord_webhook")
    if webhook_url then
        -- Send to Discord (implementation depends on your needs)
        -- ...
    end
end
```

### Conditional Notifications

```lua
-- Context-aware notifications
local function sendContextAwareNotification(title, message)
    local current_time = os.time()
    local current_hour = os.date("*t", current_time).hour

    -- Don't send notifications during quiet hours
    if current_hour >= 22 or current_hour < 8 then
        print("Quiet hours - notification suppressed:", title)
        return false
    end

    -- Check if user is in Do Not Disturb mode
    if hs.fnutils.contains(hs.settings.get("DoNotDisturb"), true) then
        print("Do Not Disturb mode - notification suppressed:", title)
        return false
    end

    -- Send notification
    return notification_utils.sendNotification(title, message)
end
```