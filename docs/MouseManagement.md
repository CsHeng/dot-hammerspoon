# Mouse Management

## Overview

Mouse Management provides comprehensive mouse behavior customization including scroll direction reversal, button remapping, cursor positioning, and input enhancement features. This module enables fine-grained control over mouse interactions while preserving trackpad functionality.

## Core Functionality

### Scroll Direction Management

```lua
-- Scroll direction reversal (preserves trackpad)
mouse_management.toggleScrollReversal()
mouse_management.enableScrollReversal()
mouse_management.disableScrollReversal()
mouse_management.isScrollReversalEnabled()
```

### Mouse Button Customization

```lua
-- Button remapping and customization
mouse_management.setMouseButtonAction(button, action)
mouse_management.resetMouseButtons()
mouse_management.getMouseButtonBindings()
```

### Cursor Positioning and Movement

```lua
-- Cursor positioning utilities
mouse_management.centerMouseOnWindow()
mouse_management.moveMouseToPosition(x, y, relative)
mouse_management.moveMouseToScreen(screen)
mouse_management.centerMouseOnScreen(screen)
```

### Mouse Utility Functions

```lua
-- Enhanced mouse operations
mouse_management.clickMouse(button, double, modifiers)
mouse_management.scroll(amount, direction, modifiers)
mouse_management.dragMouse(x1, y1, x2, y2, duration)
mouse_management.getMouseInfo()
```

### Advanced Mouse Features

```lua
-- Specialized mouse behaviors
mouse_management.enablePasteDefeat()
mouse_management.disablePasteDefeat()
mouse_management.setMouseSpeed(speed, acceleration)
mouse_management.getMouseSpeed()
```

## API Reference

### `mouse_management.toggleScrollReversal()`

Toggles mouse scroll direction reversal while preserving trackpad behavior.

**Returns:**
- `enabled` (boolean): New scroll reversal state

**Example:**
```lua
-- Toggle scroll reversal
local enabled = mouse_management.toggleScrollReversal()
print("Scroll reversal:", enabled and "ON" or "OFF")
```

### `mouse_management.enableScrollReversal()`

Enables scroll direction reversal for mouse devices only.

**Returns:**
- `success` (boolean): Whether operation succeeded

**Example:**
```lua
-- Enable scroll reversal
local success = mouse_management.enableScrollReversal()
if success then
    print("Scroll reversal enabled")
end
```

### `mouse_management.disableScrollReversal()`

Disables scroll direction reversal.

**Returns:**
- `success` (boolean): Whether operation succeeded

**Example:**
```lua
-- Disable scroll reversal
local success = mouse_management.disableScrollReversal()
if success then
    print("Scroll reversal disabled")
end
```

### `mouse_management.isScrollReversalEnabled()`

Checks if scroll direction reversal is currently enabled.

**Returns:**
- `enabled` (boolean): Whether scroll reversal is enabled

**Example:**
```lua
-- Check scroll reversal status
if mouse_management.isScrollReversalEnabled() then
    print("Scroll reversal is active")
end
```

### `mouse_management.setMouseButtonAction(button, action)`

Sets a custom action for a mouse button.

**Parameters:**
- `button` (number): Mouse button number (1=left, 2=right, 3=middle)
- `action` (function or string): Action to perform (function or key sequence)

**Returns:**
- `success` (boolean): Whether action was set successfully

**Example:**
```lua
-- Set middle button to paste
local success = mouse_management.setMouseButtonAction(3, function()
    hs.eventtap.keyStroke({"cmd"}, "v")
end)

-- Set button 4 to Mission Control
mouse_management.setMouseButtonAction(4, {"cmd", "ctrl", "up"})
```

### `mouse_management.centerMouseOnWindow(window)`

Centers the mouse cursor on a specific window.

**Parameters:**
- `window` (table, optional): Hammerspoon window object (default: focused window)

**Returns:**
- `success` (boolean): Whether operation succeeded

**Example:**
```lua
-- Center mouse on current window
local success = mouse_management.centerMouseOnWindow()
if success then
    print("Mouse centered on window")
end
```

### `mouse_management.moveMouseToPosition(x, y, relative)`

Moves mouse cursor to specified position.

**Parameters:**
- `x` (number): X coordinate
- `y` (number): Y coordinate
- `relative` (boolean, optional): Whether coordinates are relative to current position

**Returns:**
- `success` (boolean): Whether operation succeeded

**Example:**
```lua
-- Move mouse to absolute position
mouse_management.moveMouseToPosition(100, 100)

-- Move mouse relative to current position
mouse_management.moveMouseToPosition(10, 20, true)
```

### `mouse_management.moveMouseToScreen(screen)`

Moves mouse cursor to the center of a screen.

**Parameters:**
- `screen` (table, optional): Hammerspoon screen object (default: main screen)

**Returns:**
- `success` (boolean): Whether operation succeeded

**Example:**
```lua
-- Move mouse to main screen center
mouse_management.moveMouseToScreen()

-- Move mouse to specific screen
local secondScreen = hs.screen.allScreens()[2]
if secondScreen then
    mouse_management.moveMouseToScreen(secondScreen)
end
```

### `mouse_management.clickMouse(button, double, modifiers)`

Simulates a mouse click.

**Parameters:**
- `button` (number, optional): Mouse button (default: 1)
- `double` (boolean, optional): Whether to double-click (default: false)
- `modifiers` (table, optional): Modifier keys to hold

**Returns:**
- `success` (boolean): Whether operation succeeded

**Example:**
```lua
-- Single left click
mouse_management.clickMouse()

-- Double right click with Shift
mouse_management.clickMouse(2, true, {"shift"})

-- Control-click
mouse_management.clickMouse(1, false, {"ctrl"})
```

### `mouse_management.scroll(amount, direction, modifiers)`

Simulates mouse scrolling.

**Parameters:**
- `amount` (number): Scroll amount
- `direction` (string): "up", "down", "left", or "right"
- `modifiers` (table, optional): Modifier keys to hold

**Returns:**
- `success` (boolean): Whether operation succeeded

**Example:**
```lua
-- Scroll up 3 lines
mouse_management.scroll(3, "up")

-- Scroll right with Shift
mouse_management.scroll(5, "right", {"shift"})

-- Scroll down 10 lines with Command
mouse_management.scroll(10, "down", {"cmd"})
```

### `mouse_management.dragMouse(x1, y1, x2, y2, duration)`

Performs a mouse drag operation.

**Parameters:**
- `x1` (number): Starting X coordinate
- `y1` (number): Starting Y coordinate
- `x2` (number): Ending X coordinate
- `y2` (number): Ending Y coordinate
- `duration` (number, optional): Drag duration in seconds (default: 0.1)

**Returns:**
- `success` (boolean): Whether operation succeeded

**Example:**
```lua
-- Drag from (100,100) to (200,200)
mouse_management.dragMouse(100, 100, 200, 200)

-- Slow drag over 1 second
mouse_management.dragMouse(0, 0, 500, 300, 1.0)
```

### `mouse_management.getMouseInfo()`

Gets current mouse information.

**Returns:**
- `info` (table): Mouse information object

**Example:**
```lua
-- Get mouse information
local info = mouse_management.getMouseInfo()
print("Mouse position:", info.x, info.y)
print("Screen:", info.screen_name)
print("Buttons:", table.concat(info.buttons, ", "))
```

### `mouse_management.enablePasteDefeat()`

Enables paste defeat functionality to bypass paste blocking.

**Returns:**
- `success` (boolean): Whether operation succeeded

**Example:**
```lua
-- Enable paste defeat
local success = mouse_management.enablePasteDefeat()
if success then
    print("Paste defeat enabled")
end
```

### `mouse_management.disablePasteDefeat()`

Disables paste defeat functionality.

**Returns:**
- `success` (boolean): Whether operation succeeded

**Example:**
```lua
-- Disable paste defeat
local success = mouse_management.disablePasteDefeat()
if success then
    print("Paste defeat disabled")
end
```

### `mouse_management.setMouseSpeed(speed, acceleration)`

Sets mouse speed and acceleration.

**Parameters:**
- `speed` (number): Mouse speed (0.1 to 10.0)
- `acceleration` (number, optional): Mouse acceleration (0.1 to 10.0)

**Returns:**
- `success` (boolean): Whether operation succeeded

**Example:**
```lua
-- Set mouse speed to 5.0
mouse_management.setMouseSpeed(5.0)

-- Set both speed and acceleration
mouse_management.setMouseSpeed(3.0, 2.0)
```

## Scroll Direction Reversal Implementation

### Event Tap for Scroll Detection

```lua
-- Scroll event detection and reversal
local scroll_event_tap = nil
local scroll_reversal_enabled = false

local function createScrollEventTap()
    if scroll_event_tap then
        scroll_event_tap:stop()
        scroll_event_tap = nil
    end

    scroll_event_tap = hs.eventtap.new({hs.eventtap.event.types.scrollWheel}, function(event)
        if not scroll_reversal_enabled then
            return false -- Don't intercept
        end

        -- Check if this is a mouse scroll (not trackpad)
        local scroll_data = event:getProperty(hs.eventtap.event.properties.scrollWheelEventScrollAxis)
        local scroll_delta = event:getProperty(hs.eventtap.event.properties.scrollWheelEventDeltaAxis1)

        -- Reverse vertical scroll
        if scroll_delta ~= 0 then
            local reversed_event = hs.eventtap.event.newScrollEvent(
                {-scroll_delta, 0},  -- Reversed vertical, no horizontal
                {unit = hs.eventtap.event.properties.scrollWheelEventUnitLine}
            )

            reversed_event:post(event:location())
            return true  -- Consume original event
        end

        return false
    end)

    scroll_event_tap:start()
end
```

### Mouse vs Trackpad Detection

```lua
-- Detect input device type
local function isMouseEvent(event)
    -- Check various properties to determine if this is a mouse event
    local source = event:getProperty(hs.eventtap.event.properties.eventSourceState)

    -- Mouse events typically have different source states than trackpad
    return source == hs.eventtap.event.properties.eventSourceStateMouse or
           source == hs.eventtap.event.properties.eventSourceStateScrollWheelMouse
end

-- Enhanced device detection
local device_detector = {
    mouse_devices = {},
    trackpad_devices = {},
    last_detection_time = 0
}

local function updateDeviceList()
    local current_time = hs.timer.secondsSinceEpoch()
    if current_time - device_detector.last_detection_time < 30 then
        return  -- Don't update too frequently
    end

    -- This would require additional system calls to get device info
    -- For now, we'll use heuristic detection
    device_detector.last_detection_time = current_time
end
```

## Mouse Button Customization

### Button Remapping System

```lua
-- Mouse button remapping infrastructure
local button_bindings = {}
local button_event_tap = nil

local function createButtonEventTap()
    if button_event_tap then
        button_event_tap:stop()
        button_event_tap = nil
    end

    button_event_tap = hs.eventtap.new({
        hs.eventtap.event.types.otherMouseDown,
        hs.eventtap.event.types.otherMouseUp,
        hs.eventtap.event.types.rightMouseDown,
        hs.eventtap.event.types.rightMouseUp
    }, function(event)
        local button = event:getProperty(hs.eventtap.event.properties.mouseEventButtonNumber)

        if button_bindings[button] then
            local action = button_bindings[button]

            if type(action) == "function" then
                -- Execute custom function
                action(event)
                return true  -- Consume original event
            elseif type(action) == "table" then
                -- Simulate key sequence
                hs.eventtap.keyStroke(action.modifiers, action.key, 0, event:location())
                return true  -- Consume original event
            end
        end

        return false  -- Allow original event
    end)

    button_event_tap:start()
end

-- Button action definitions
local built_in_actions = {
    -- Paste action
    paste = function(event)
        hs.eventtap.keyStroke({"cmd"}, "v")
    end,

    -- Mission Control
    mission_control = function(event)
        hs.eventtap.keyStroke({"ctrl", "cmd"}, "up")
    end,

    -- App Exposé
    app_expose = function(event)
        hs.eventtap.keyStroke({"ctrl", "cmd"}, "down")
    end,

    -- Show Desktop
    show_desktop = function(event)
        hs.eventtap.keyStroke({"cmd", "ctrl"}, "d")
    end,

    -- Launchpad
    launchpad = function(event)
        hs.eventtap.keyStroke({"cmd"}, "space")
    end
}
```

### Mouse Speed Control

```lua
-- Mouse speed and acceleration control
local function setMouseSpeedInternal(speed, acceleration)
    -- Use system command to adjust mouse speed
    local command = string.format(
        "defaults write -g com.apple.mouse.scaling -float %f",
        speed
    )

    local success = hs.execute(command)

    if acceleration then
        local acc_command = string.format(
            "defaults write -g com.apple.mouse.momentumScroll -float %f",
            acceleration
        )
        hs.execute(acc_command)
    end

    -- Notify mouse server of changes
    hs.execute("killall -HUP moused")

    return success
end

local function getMouseSpeedInternal()
    -- Read current mouse speed from system preferences
    local output = hs.execute("defaults read -g com.apple.mouse.scaling 2>/dev/null")
    if output then
        return tonumber(output:match("%d+%.?%d*"))
    end
    return nil
end
```

## Cursor Positioning System

### Smart Cursor Positioning

```lua
-- Intelligent cursor positioning
local function smartCenterOnWindow(window)
    if not window or not window:frame() then
        return false
    end

    local frame = window:frame()
    local center_x = frame.x + frame.w / 2
    local center_y = frame.y + frame.h / 2

    -- Center with slight offset for better visibility
    local offset_x = frame.w * 0.1
    local offset_y = frame.h * 0.1

    hs.mouse.setAbsolutePosition({
        x = center_x + offset_x,
        y = center_y + offset_y
    })

    return true
end

-- Animated cursor movement
local function animateCursorToPosition(target_x, target_y, duration)
    duration = duration or 0.2

    local start_pos = hs.mouse.getAbsolutePosition()
    local start_time = hs.timer.secondsSinceEpoch()

    local timer = hs.timer.new(0.016, function()  -- 60 FPS
        local elapsed = hs.timer.secondsSinceEpoch() - start_time
        local progress = math.min(elapsed / duration, 1.0)

        -- Easing function (easeInOutQuad)
        local ease_progress = progress < 0.5 and
            2 * progress * progress or
            1 - math.pow(-2 * progress + 2, 2) / 2

        local current_x = start_pos.x + (target_x - start_pos.x) * ease_progress
        local current_y = start_pos.y + (target_y - start_pos.y) * ease_progress

        hs.mouse.setAbsolutePosition({x = current_x, y = current_y})

        if progress >= 1.0 then
            return false  -- Stop timer
        end
        return true  -- Continue timer
    end)

    timer:start()
    return timer
end
```

### Multi-Screen Cursor Management

```lua
-- Cross-screen cursor positioning
local function moveCursorToScreenEdge(edge, screen)
    screen = screen or hs.screen.mainScreen()
    local frame = screen:frame()
    local mouse_pos = hs.mouse.getAbsolutePosition()

    local target_x = mouse_pos.x
    local target_y = mouse_pos.y

    if edge == "left" then
        target_x = frame.x + 10
    elseif edge == "right" then
        target_x = frame.x + frame.w - 10
    elseif edge == "top" then
        target_y = frame.y + 10
    elseif edge == "bottom" then
        target_y = frame.y + frame.h - 10
    end

    hs.mouse.setAbsolutePosition({x = target_x, y = target_y})
end

local function findNearestScreenEdge(position)
    local screens = hs.screen.allScreens()
    local nearest_screen = nil
    local nearest_edge = nil
    local min_distance = math.huge

    for _, screen in ipairs(screens) do
        local frame = screen:frame()

        -- Calculate distance to each edge
        local edges = {
            {edge = "left", dist = math.abs(position.x - frame.x)},
            {edge = "right", dist = math.abs(position.x - (frame.x + frame.w))},
            {edge = "top", dist = math.abs(position.y - frame.y)},
            {edge = "bottom", dist = math.abs(position.y - (frame.y + frame.h))}
        }

        for _, edge_info in ipairs(edges) do
            if edge_info.dist < min_distance then
                min_distance = edge_info.dist
                nearest_screen = screen
                nearest_edge = edge_info.edge
            end
        end
    end

    return nearest_screen, nearest_edge
end
```

## Paste Defeat Functionality

### Paste Defeat Implementation

```lua
-- Paste defeat to bypass paste blocking
local paste_defeat_enabled = false
local paste_event_tap = nil

local function createPasteDefeatEventTap()
    if paste_event_tap then
        paste_event_tap:stop()
        paste_event_tap = nil
    end

    paste_event_tap = hs.eventtap.new({
        hs.eventtap.event.types.keyDown
    }, function(event)
        if not paste_defeat_enabled then
            return false
        end

        local key = event:getCharacters()
        local modifiers = event:getFlags()

        -- Check for Command+V (paste)
        if key == "v" and modifiers.cmd then
            -- Type the clipboard content instead of pasting
            local clipboard = hs.pasteboard.getContents()
            if clipboard then
                -- Delete the paste event
                hs.timer.doAfter(0.01, function()
                    hs.eventtap.keyStrokes(clipboard)
                end)
                return true  -- Consume the paste event
            end
        end

        return false
    end)

    paste_event_tap:start()
end
```

### Enhanced Paste Defeat

```lua
-- Advanced paste defeat with multiple strategies
local paste_strategies = {
    -- Direct text input (bypasses most paste blockers)
    direct_input = function(clipboard)
        hs.eventtap.keyStrokes(clipboard)
    end,

    -- Simulated typing (slower but more reliable)
    simulated_typing = function(clipboard)
        for char in clipboard:gmatch(".") do
            hs.eventtap.keyStrokes(char)
            hs.timer.usleep(10000)  -- 10ms delay between characters
        end
    end,

    -- App-specific paste defeat
    app_specific = function(clipboard)
        local front_app = hs.application.frontmostApplication()
        local bundle_id = front_app and front_app:bundleID()

        if bundle_id == "com.apple.Terminal" then
            -- Terminal-specific handling
            hs.eventtap.keyStroke({"cmd", "shift"}, "v")
        elseif bundle_id == "com.microsoft.vscode" then
            -- VS Code-specific handling
            hs.eventtap.keyStroke({"ctrl", "shift"}, "v")
        else
            -- Fallback to direct input
            hs.eventtap.keyStrokes(clipboard)
        end
    end
}

local function pasteWithStrategy(strategy_name)
    local clipboard = hs.pasteboard.getContents()
    if not clipboard then
        return false
    end

    local strategy = paste_strategies[strategy_name]
    if not strategy then
        strategy = paste_strategies.direct_input
    end

    strategy(clipboard)
    return true
end
```

## Integration with Other Modules

### Window Management Integration

```lua
-- Used by window_management for cursor positioning
local window_management = {}

function window_management.moveWindowWithCursor(direction)
    local win = hs.window.focusedWindow()
    if not win then return end

    -- Move window
    if direction == "left" then
        window_utils.moveWindowToHalf(win, "left")
    elseif direction == "right" then
        window_utils.moveWindowToHalf(win, "right")
    end

    -- Center cursor on window after move
    mouse_management.centerMouseOnWindow(win)
end
```

### Application Launcher Integration

```lua
-- Used by app_launcher for cursor positioning
local app_launcher = {}

function app_launcher.launchAndFocus(app_config)
    local success, app = app_utils.launchApp(app_config.name, app_config.bundle_id)
    if success then
        -- Focus application
        app_utils.focusApp(app_config.bundle_id)

        -- Center cursor on focused window after delay
        hs.timer.doAfter(0.5, function()
            mouse_management.centerMouseOnWindow()
        end)
    end

    return success
end
```

## Performance Optimization

### Event Tap Optimization

```lua
-- Efficient event handling
local event_counters = {
    scroll_events = 0,
    button_events = 0,
    key_events = 0
}

local function updateEventCounter(event_type)
    event_counters[event_type] = event_counters[event_type] + 1

    -- Log high-frequency events (potential issues)
    if event_counters[event_type] > 100 then
        print("Warning: High frequency", event_type, "events detected")
    end
end

-- Rate limiting for scroll events
local last_scroll_time = 0
local scroll_rate_limit = 0.001  -- 1ms

local function rateLimitedScrollReversal(event)
    local current_time = hs.timer.secondsSinceEpoch()
    if current_time - last_scroll_time < scroll_rate_limit then
        return false  -- Skip this event
    end

    last_scroll_time = current_time
    updateEventCounter("scroll_events")

    -- Process scroll reversal
    -- ... (scroll reversal logic)
end
```

### Memory Management

```lua
-- Clean up resources periodically
local function cleanupMouseResources()
    -- Clear unused event taps
    if scroll_event_tap and not scroll_reversal_enabled then
        scroll_event_tap:stop()
        scroll_event_tap = nil
    end

    if button_event_tap and next(button_bindings) == nil then
        button_event_tap:stop()
        button_event_tap = nil
    end

    if paste_event_tap and not paste_defeat_enabled then
        paste_event_tap:stop()
        paste_event_tap = nil
    end

    -- Reset event counters periodically
    if event_counters.scroll_events > 1000 then
        event_counters.scroll_events = 0
        event_counters.button_events = 0
        event_counters.key_events = 0
    end
end

-- Set up periodic cleanup
hs.timer.new(60, cleanupMouseResources):start()
```

## Debugging and Monitoring

### Mouse Event Debugging

```lua
-- Debug mouse events
local function setupMouseDebugging()
    local debug_event_tap = hs.eventtap.new({
        hs.eventtap.event.types.mouseMoved,
        hs.eventtap.event.types.scrollWheel,
        hs.eventtap.event.types.leftMouseDown,
        hs.eventtap.event.types.rightMouseDown,
        hs.eventtap.event.types.otherMouseDown
    }, function(event)
        local event_type = event:type()
        local pos = event:location()

        if event_type == hs.eventtap.event.types.scrollWheel then
            local delta = event:getProperty(hs.eventtap.event.properties.scrollWheelEventDeltaAxis1)
            print("Scroll:", delta, "at", pos.x, pos.y)
        elseif event_type == hs.eventtap.event.types.mouseMoved then
            -- Only log every 100th move event to avoid spam
            if math.random(100) == 1 then
                print("Mouse moved to:", pos.x, pos.y)
            end
        else
            local button = event:getProperty(hs.eventtap.event.properties.mouseEventButtonNumber)
            print("Mouse button", button, "at", pos.x, pos.y)
        end

        return false
    end)

    debug_event_tap:start()
end

-- Performance monitoring
local function monitorMousePerformance()
    local start_time = hs.timer.secondsSinceEpoch()
    local event_count = 0

    local monitor_event_tap = hs.eventtap.new({
        hs.eventtap.event.types.mouseMoved,
        hs.eventtap.event.types.scrollWheel
    }, function(event)
        event_count = event_count + 1

        if event_count % 1000 == 0 then
            local elapsed = hs.timer.secondsSinceEpoch() - start_time
            local rate = event_count / elapsed
            print("Mouse event rate:", string.format("%.1f", rate), "events/second")
        end

        return false
    end)

    monitor_event_tap:start()
end
```

## Best Practices

### 1. Resource Management

```lua
-- Always clean up event taps when not needed
local function safeEnableScrollReversal()
    if scroll_event_tap then
        scroll_event_tap:stop()
    end

    scroll_reversal_enabled = true
    createScrollEventTap()
end
```

### 2. Error Handling

```lua
-- Robust error handling for mouse operations
local function safeMouseOperation(operation, ...)
    local success, result = pcall(operation, ...)
    if not success then
        print("Mouse operation failed:", result)
        -- Try to recover by resetting event taps
        resetMouseEventTaps()
        return false
    end
    return result
end
```

### 3. User Experience

```lua
-- Smooth animations for cursor movement
local function smoothCursorMove(target_pos, duration)
    duration = duration or 0.3
    animateCursorToPosition(target_pos.x, target_pos.y, duration)
end
```

### 4. Accessibility

```lua
-- Accessibility-friendly mouse controls
local function setAccessibilityMouseSpeed()
    -- Use system preferences for accessibility
    local speed = config.get("mouse.accessibility_speed", 2.0)
    mouse_management.setMouseSpeed(speed)
end
```

## Troubleshooting

### Common Issues

1. **Scroll Reversal Not Working**: Check event tap permissions
2. **Mouse Buttons Not Responding**: Verify button binding configuration
3. **Performance Issues**: Monitor event frequency and implement rate limiting
4. **Conflicts with Other Apps**: Check for multiple mouse management tools

### Debug Commands

```lua
-- Test scroll reversal
mouse_management.enableScrollReversal()
print("Scroll reversal enabled, test with mouse scroll wheel")

-- Test button bindings
mouse_management.setMouseButtonAction(3, function()
    print("Middle button clicked!")
end)

-- Test cursor positioning
mouse_management.centerMouseOnWindow()

-- Check mouse settings
local info = mouse_management.getMouseInfo()
print("Mouse info:", hs.inspect(info))

-- Monitor performance
mouse_management.monitorMousePerformance()
```

## Advanced Usage

### Gesture-Based Actions

```lua
-- Create custom mouse gestures
local function createGestureDetector()
    local gesture_points = {}
    local gesture_start_time = 0
    local is_recording = false

    local gesture_event_tap = hs.eventtap.new({
        hs.eventtap.event.types.rightMouseDown,
        hs.eventtap.event.types.rightMouseUp,
        hs.eventtap.event.types.mouseMoved
    }, function(event)
        local event_type = event:type()
        local pos = event:location()

        if event_type == hs.eventtap.event.types.rightMouseDown then
            -- Start gesture recording
            gesture_points = {pos}
            gesture_start_time = hs.timer.secondsSinceEpoch()
            is_recording = true
            return true  -- Consume right click
        elseif event_type == hs.eventtap.event.types.rightMouseUp then
            -- End gesture recording and recognize
            is_recording = false
            local gesture = recognizeGesture(gesture_points)
            if gesture then
                executeGestureAction(gesture)
            end
            return true  -- Consume right click
        elseif event_type == hs.eventtap.event.types.mouseMoved and is_recording then
            -- Record gesture point
            table.insert(gesture_points, pos)
            return false  -- Allow movement
        end

        return false
    end)

    gesture_event_tap:start()
end
```

### Application-Specific Mouse Behavior

```lua
-- Define app-specific mouse settings
local app_mouse_settings = {
    ["com.apple.Terminal"] = {
        scroll_speed = 2.0,
        button_3_action = "paste",
        center_on_focus = true
    },
    ["com.google.Chrome"] = {
        scroll_speed = 1.5,
        button_4_action = "back",
        button_5_action = "forward"
    },
    ["com.adobe.Photoshop"] = {
        scroll_speed = 1.0,
        scroll_reversal = false,
        precision_mode = true
    }
}

local function applyAppMouseSettings(bundle_id)
    local settings = app_mouse_settings[bundle_id]
    if not settings then return end

    if settings.scroll_speed then
        mouse_management.setMouseSpeed(settings.scroll_speed)
    end

    if settings.scroll_reversal ~= nil then
        if settings.scroll_reversal then
            mouse_management.enableScrollReversal()
        else
            mouse_management.disableScrollReversal()
        end
    end

    if settings.button_3_action then
        mouse_management.setMouseButtonAction(3, built_in_actions[settings.button_3_action])
    end
end
```