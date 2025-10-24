# Display Utilities (DisplayUtils)

## Overview

DisplayUtils provides comprehensive multi-monitor support including screen ordering, frame calculations, and cross-display window positioning. This module is essential for sophisticated window management across multiple displays.

## Core Functionality

### Screen Management and Discovery

```lua
-- Screen discovery and ordering
display_utils.getAllScreens()
display_utils.getOrderedScreens()
display_utils.getNextScreen(current)
display_utils.getPreviousScreen(current)

-- Screen information retrieval
display_utils.getScreenInfo(screen)
display_utils.getScreenFrame(screen)
display_utils.getScreenName(screen)
```

### Frame Calculations and Geometry

```lua
-- Half-screen positioning
display_utils.getHalfFrame(screen, side)
display_utils.getLeftHalfFrame(screen)
display_utils.getRightHalfFrame(screen)
display_utils.getTopHalfFrame(screen)
display_utils.getBottomHalfFrame(screen)

-- Quarter-screen positioning
display_utils.getQuarterFrame(screen, quarter)
display_utils.getTopLeftQuarterFrame(screen)
display_utils.getTopRightQuarterFrame(screen)
display_utils.getBottomLeftQuarterFrame(screen)
display_utils.getBottomRightQuarterFrame(screen)

-- Custom positioning
display_utils.getCenterFrame(screen, scale)
display_utils.getMaximizedFrame(screen)
```

### Edge Detection and Multi-Monitor Logic

```lua
-- Edge detection for smart positioning
display_utils.isAtEdge(position, screen, tolerance)
display_utils.getClosestEdge(position, screen)
display_utils.findNearestScreenEdge(position)

-- Cross-display positioning
display_utils.getAdjacentScreens(screen)
display_utils.canMoveBetweenScreens(source, target, edge)
display_utils.calculateCrossDisplayMovement(source, target, edge)
```

## API Reference

### `display_utils.getAllScreens()`

Returns all available screens in their natural Hammerspoon order.

**Returns:**
- `screens` (array): Array of Hammerspoon screen objects

**Example:**
```lua
-- Get all screens
local screens = display_utils.getAllScreens()
for i, screen in ipairs(screens) do
    print("Screen", i, ":", screen:name())
end
```

### `display_utils.getOrderedScreens()`

Returns screens ordered by physical arrangement (left to right, top to bottom).

**Returns:**
- `screens` (array): Array of Hammerspoon screen objects in physical order

**Example:**
```lua
-- Get screens in physical order
local screens = display_utils.getOrderedScreens()
for i, screen in ipairs(screens) do
    local frame = screen:frame()
    print("Screen", i, "at", frame.x, frame.y)
end
```

### `display_utils.getNextScreen(current)`

Gets the next screen in the ordering (no cycling).

**Parameters:**
- `current` (screen): Current screen object

**Returns:**
- `next_screen` (screen): Next screen or nil if no next screen

**Example:**
```lua
-- Move to next display
local current = hs.screen.mainScreen()
local next_screen = display_utils.getNextScreen(current)
if next_screen then
    print("Next screen:", next_screen:name())
end
```

### `display_utils.getPreviousScreen(current)`

Gets the previous screen in the ordering (no cycling).

**Parameters:**
- `current` (screen): Current screen object

**Returns:**
- `previous_screen` (screen): Previous screen or nil if no previous screen

**Example:**
```lua
-- Move to previous display
local current = hs.screen.mainScreen()
local prev_screen = display_utils.getPreviousScreen(current)
if prev_screen then
    print("Previous screen:", prev_screen:name())
end
```

### `display_utils.getScreenFrame(screen)`

Gets the frame of a screen with safety checks.

**Parameters:**
- `screen` (screen): Screen object

**Returns:**
- `frame` (rect): Screen frame or nil if screen is invalid

**Example:**
```lua
-- Safe frame retrieval
local frame = display_utils.getScreenFrame(screen)
if frame then
    print("Screen dimensions:", frame.w, "x", frame.h)
end
```

### `display_utils.getHalfFrame(screen, side)`

Calculates half-screen frame for positioning.

**Parameters:**
- `screen` (screen): Target screen
- `side` (string): "left", "right", "top", or "bottom"

**Returns:**
- `frame` (rect): Half-screen frame

**Example:**
```lua
-- Get left half of main screen
local mainScreen = hs.screen.mainScreen()
local leftHalf = display_utils.getHalfFrame(mainScreen, "left")
print("Left half dimensions:", leftHalf.w, "x", leftHalf.h)
```

### `display_utils.getQuarterFrame(screen, quarter)`

Calculates quarter-screen frame for positioning.

**Parameters:**
- `screen` (screen): Target screen
- `quarter` (string): "top_left", "top_right", "bottom_left", or "bottom_right"

**Returns:**
- `frame` (rect): Quarter-screen frame

**Example:**
```lua
-- Get top-right quarter of main screen
local mainScreen = hs.screen.mainScreen()
local topRight = display_utils.getQuarterFrame(mainScreen, "top_right")
print("Top-right quarter:", topRight.x, topRight.y, topRight.w, topRight.h)
```

### `display_utils.isAtEdge(position, screen, tolerance)`

Checks if a position is at the edge of a screen.

**Parameters:**
- `position` (point): Position to check
- `screen` (screen): Screen to check against
- `tolerance` (number): Pixel tolerance for edge detection

**Returns:**
- `at_edge` (boolean): Whether position is at screen edge

**Example:**
```lua
-- Check if cursor is at screen edge
local mousePos = hs.mouse.getAbsolutePosition()
local mainScreen = hs.screen.mainScreen()
if display_utils.isAtEdge(mousePos, mainScreen, 20) then
    print("Mouse is at screen edge")
end
```

### `display_utils.getAdjacentScreens(screen)`

Gets screens adjacent to the specified screen.

**Parameters:**
- `screen` (screen): Reference screen

**Returns:**
- `adjacent` (table): Table with left, right, top, bottom adjacent screens

**Example:**
```lua
-- Find adjacent screens
local mainScreen = hs.screen.mainScreen()
local adjacent = display_utils.getAdjacentScreens(mainScreen)
if adjacent.right then
    print("Screen to the right:", adjacent.right:name())
end
```

### `display_utils.getCenterFrame(screen, scale)`

Calculates centered frame with optional scaling.

**Parameters:**
- `screen` (screen): Target screen
- `scale` (number, optional): Scale factor (default: 0.8)

**Returns:**
- `frame` (rect): Centered frame

**Example:**
```lua
-- Get centered frame at 80% of screen size
local mainScreen = hs.screen.mainScreen()
local centerFrame = display_utils.getCenterFrame(mainScreen, 0.8)
print("Center frame:", centerFrame.x, centerFrame.y, centerFrame.w, centerFrame.h)
```

### `display_utils.getMaximizedFrame(screen)`

Calculates maximized frame (excluding menu bar and dock areas).

**Parameters:**
- `screen` (screen): Target screen

**Returns:**
- `frame` (rect): Maximized frame

**Example:**
```lua
-- Get maximized frame
local mainScreen = hs.screen.mainScreen()
local maxFrame = display_utils.getMaximizedFrame(mainScreen)
print("Maximized frame size:", maxFrame.w, "x", maxFrame.h)
```

## Screen Ordering Algorithm

The module implements a sophisticated screen ordering system:

### Physical Layout Detection

```lua
-- Screen ordering based on physical position
local function orderScreensByPosition(screens)
    table.sort(screens, function(a, b)
        local frameA = a:frame()
        local frameB = b:frame()

        -- First sort by Y position (top to bottom)
        if math.abs(frameA.y - frameB.y) > 100 then
            return frameA.y < frameB.y
        end

        -- Then sort by X position (left to right)
        return frameA.x < frameB.x
    end)

    return screens
end
```

### Multi-Row Layout Support

```lua
-- Handle multi-row screen arrangements
local function detectScreenRows(screens)
    local rows = {}
    local tolerance = 50  -- Pixel tolerance for row detection

    for _, screen in ipairs(screens) do
        local frame = screen:frame()
        local y_pos = frame.y

        -- Find matching row
        local row_found = false
        for _, row in ipairs(rows) do
            if math.abs(y_pos - row.y_pos) <= tolerance then
                table.insert(row.screens, screen)
                row_found = true
                break
            end
        end

        -- Create new row if needed
        if not row_found then
            table.insert(rows, {
                y_pos = y_pos,
                screens = {screen}
            })
        end
    end

    return rows
end
```

## Edge Detection System

### Edge Positioning Logic

```lua
-- Smart edge detection for window positioning
local function detectWindowEdge(window, screen, tolerance)
    local frame = window:frame()
    local screenFrame = screen:frame()

    local edges = {}

    -- Check each edge
    if math.abs(frame.x - screenFrame.x) <= tolerance then
        table.insert(edges, "left")
    end
    if math.abs((frame.x + frame.w) - (screenFrame.x + screenFrame.w)) <= tolerance then
        table.insert(edges, "right")
    end
    if math.abs(frame.y - screenFrame.y) <= tolerance then
        table.insert(edges, "top")
    end
    if math.abs((frame.y + frame.h) - (screenFrame.y + screenFrame.h)) <= tolerance then
        table.insert(edges, "bottom")
    end

    return edges
end
```

### Cross-Screen Edge Detection

```lua
-- Detect edges between adjacent screens
local function findCrossScreenEdges(screens)
    local cross_edges = {}

    for i, screen1 in ipairs(screens) do
        local frame1 = screen1:frame()
        for j, screen2 in ipairs(screens) do
            if i ~= j then
                local frame2 = screen2:frame()

                -- Check for horizontal adjacency
                if math.abs(frame1.x + frame1.w - frame2.x) <= 10 then
                    cross_edges[screen1] = cross_edges[screen1] or {}
                    cross_edges[screen1].right = screen2
                    cross_edges[screen2] = cross_edges[screen2] or {}
                    cross_edges[screen2].left = screen1
                end

                -- Check for vertical adjacency
                if math.abs(frame1.y + frame1.h - frame2.y) <= 10 then
                    cross_edges[screen1] = cross_edges[screen1] or {}
                    cross_edges[screen1].bottom = screen2
                    cross_edges[screen2] = cross_edges[screen2] or {}
                    cross_edges[screen2].top = screen1
                end
            end
        end
    end

    return cross_edges
end
```

## Frame Calculations

### Half-Screen Positioning

```lua
-- Calculate half-screen frames
local function calculateHalfFrame(screenFrame, side)
    local halfFrame = hs.geometry.copy(screenFrame)

    if side == "left" then
        halfFrame.w = halfFrame.w / 2
    elseif side == "right" then
        halfFrame.w = halfFrame.w / 2
        halfFrame.x = halfFrame.x + halfFrame.w
    elseif side == "top" then
        halfFrame.h = halfFrame.h / 2
    elseif side == "bottom" then
        halfFrame.h = halfFrame.h / 2
        halfFrame.y = halfFrame.y + halfFrame.h
    end

    return halfFrame
end
```

### Quarter-Screen Positioning

```lua
-- Calculate quarter-screen frames
local function calculateQuarterFrame(screenFrame, quarter)
    local quarterFrame = hs.geometry.copy(screenFrame)
    quarterFrame.w = quarterFrame.w / 2
    quarterFrame.h = quarterFrame.h / 2

    if quarter == "top_left" then
        -- No adjustment needed, already in top-left position
    elseif quarter == "top_right" then
        quarterFrame.x = quarterFrame.x + quarterFrame.w
    elseif quarter == "bottom_left" then
        quarterFrame.y = quarterFrame.y + quarterFrame.h
    elseif quarter == "bottom_right" then
        quarterFrame.x = quarterFrame.x + quarterFrame.w
        quarterFrame.y = quarterFrame.y + quarterFrame.h
    end

    return quarterFrame
end
```

## Performance Optimization

### Screen Caching

```lua
-- Cache screen information to reduce system calls
local screen_cache = {}
local last_screen_count = 0
local cache_timestamp = 0

local function getCachedScreens()
    local current_time = hs.timer.secondsSinceEpoch()
    local current_screens = hs.screen.allScreens()

    -- Only refresh cache if screen count changed or cache is old
    if #current_screens ~= last_screen_count or
       current_time - cache_timestamp > 5 then

        screen_cache = {}
        for i, screen in ipairs(current_screens) do
            screen_cache[i] = {
                screen = screen,
                frame = screen:frame(),
                name = screen:name(),
                id = screen:id()
            }
        end

        last_screen_count = #current_screens
        cache_timestamp = current_time
    end

    return screen_cache
end
```

### Efficient Screen Matching

```lua
-- Fast screen matching by various criteria
local function findScreenByPosition(position)
    local screens = hs.screen.allScreens()

    for _, screen in ipairs(screens) do
        if screen:frame():containsPoint(position) then
            return screen
        end
    end

    -- Fallback to main screen if position not in any screen
    return hs.screen.mainScreen()
end
```

## Error Handling and Validation

### Screen Validation

```lua
-- Validate screen objects
local function isValidScreen(screen)
    return screen and type(screen) == "userdata" and screen:frame()
end

local function validateScreenForOperation(screen, operation)
    if not isValidScreen(screen) then
        return false, "Invalid screen object"
    end

    local frame = screen:frame()
    if not frame then
        return false, "Cannot get screen frame"
    end

    if frame.w <= 0 or frame.h <= 0 then
        return false, "Screen has invalid dimensions"
    end

    return true, "Screen is valid"
end
```

### Graceful Degradation

```lua
-- Handle screen configuration changes gracefully
local function handleScreenConfigurationChange()
    local success, screens = pcall(hs.screen.allScreens)
    if not success then
        print("Warning: Could not enumerate screens:", screens)
        -- Fallback to main screen only
        return {hs.screen.mainScreen()}
    end

    return screens
end
```

## Integration with Other Modules

### Window Management Integration

```lua
-- Used by window_management for multi-monitor support
local window_management = {}

function window_management.moveToDisplay(direction)
    local win = hs.window.focusedWindow()
    if not win then return end

    local currentScreen = win:screen()
    local targetScreen = nil

    if direction == "next" then
        targetScreen = display_utils.getNextScreen(currentScreen)
    elseif direction == "previous" then
        targetScreen = display_utils.getPreviousScreen(currentScreen)
    end

    if targetScreen then
        -- Move window to target screen
        win:moveToScreen(targetScreen)
    end
end
```

### Expose Integration

```lua
-- Used by window_expose for cross-space window thumbnails
local window_expose = {}

function window_expose.getAllVisibleWindows()
    local windows = {}
    local screens = display_utils.getAllScreens()

    for _, screen in ipairs(screens) do
        local screenWindows = hs.window.orderedWindows()
        for _, window in ipairs(screenWindows) do
            if window:screen() == screen then
                table.insert(windows, window)
            end
        end
    end

    return windows
end
```

## Debugging and Monitoring

### Screen Configuration Monitoring

```lua
-- Monitor screen configuration changes
local function monitorScreenChanges()
    local last_screen_count = 0
    local last_screen_names = {}

    hs.screen.watcher.new(function()
        local current_screens = hs.screen.allScreens()
        local current_count = #current_screens

        if current_count ~= last_screen_count then
            print("Screen count changed:", current_count)
            last_screen_count = current_count

            -- Log screen names
            local current_names = {}
            for _, screen in ipairs(current_screens) do
                table.insert(current_names, screen:name() or "Unknown")
            end
            print("Current screens:", table.concat(current_names, ", "))
        end
    end):start()
end
```

### Screen Layout Visualization

```lua
-- Visualize screen layout for debugging
local function visualizeScreenLayout()
    local screens = hs.screen.allScreens()

    for i, screen in ipairs(screens) do
        local frame = screen:frame()
        local name = screen:name() or "Screen " .. i

        print(string.format("%s: (%d, %d) %dx%d",
            name, frame.x, frame.y, frame.w, frame.h))
    end
end
```

## Best Practices

### 1. Screen Detection

```lua
-- Always validate screen objects
local function safeScreenOperation(screen, operation)
    local valid, error = validateScreenForOperation(screen, operation)
    if not valid then
        print("Screen validation failed:", error)
        return false
    end

    return true
end
```

### 2. Multi-Monitor Considerations

```lua
-- Handle multi-monitor edge cases
local function getSafeTargetScreen(sourceScreen, direction)
    local targetScreen = nil

    if direction == "next" then
        targetScreen = display_utils.getNextScreen(sourceScreen)
    elseif direction == "previous" then
        targetScreen = display_utils.getPreviousScreen(sourceScreen)
    end

    -- Return source screen if no target available (no cycling)
    return targetScreen or sourceScreen
end
```

### 3. Frame Calculations

```lua
-- Ensure frames are within screen bounds
local function constrainFrameToScreen(frame, screen)
    local screenFrame = screen:frame()
    local constrained = hs.geometry.copy(frame)

    -- Constrain X coordinate
    constrained.x = math.max(screenFrame.x, math.min(constrained.x, screenFrame.x + screenFrame.w - constrained.w))

    -- Constrain Y coordinate
    constrained.y = math.max(screenFrame.y, math.min(constrained.y, screenFrame.y + screenFrame.h - constrained.h))

    return constrained
end
```

### 4. Performance Considerations

```lua
-- Batch screen operations to minimize system calls
local function batchScreenOperation(screens, operation)
    local results = {}

    for _, screen in ipairs(screens) do
        local success, result = pcall(operation, screen)
        if success then
            table.insert(results, result)
        else
            print("Screen operation failed:", result)
        end
    end

    return results
end
```

## Troubleshooting

### Common Issues

1. **Screen Not Found**: Verify screen objects are valid before use
2. **Frame Calculation Errors**: Check screen dimensions and ensure frames are within bounds
3. **Multi-Monitor Detection**: Ensure screens are properly arranged in macOS Display settings
4. **Edge Detection Issues**: Adjust tolerance values for edge detection

### Debug Commands

```lua
-- Display current screen configuration
display_utils.visualizeScreenLayout()

-- Test screen ordering
local screens = display_utils.getOrderedScreens()
print("Screen order:")
for i, screen in ipairs(screens) do
    print(i, screen:name() or "Unknown", screen:id())
end

-- Test frame calculations
local main = hs.screen.mainScreen()
local frame = display_utils.getCenterFrame(main, 0.8)
print("Center frame:", frame.x, frame.y, frame.w, frame.h)

-- Test edge detection
local mousePos = hs.mouse.getAbsolutePosition()
local isAtEdge = display_utils.isAtEdge(mousePos, main, 20)
print("Mouse at edge:", isAtEdge)
```

## Advanced Usage

### Custom Screen Arrangements

```lua
-- Define custom screen arrangements
local custom_arrangements = {
    work = {
        primary = "Built-in Retina Display",
        secondary = "LG UltraFine"
    },
    home = {
        primary = "LG UltraFine",
        secondary = "Built-in Retina Display"
    }
}

local function applyCustomArrangement(arrangement_name)
    local arrangement = custom_arrangements[arrangement_name]
    if not arrangement then return false end

    local screens = hs.screen.allScreens()
    local primaryScreen = nil
    local secondaryScreen = nil

    -- Find screens by name
    for _, screen in ipairs(screens) do
        local screenName = screen:name()
        if screenName == arrangement.primary then
            primaryScreen = screen
        elseif screenName == arrangement.secondary then
            secondaryScreen = screen
        end
    end

    -- Apply arrangement-specific logic
    if primaryScreen and secondaryScreen then
        -- Position windows based on arrangement
        -- ...
        return true
    end

    return false
end
```

### Dynamic Screen Profiles

```lua
-- Create screen profiles based on configuration
local function createScreenProfile()
    local screens = hs.screen.allScreens()
    local profile = {
        timestamp = hs.timer.secondsSinceEpoch(),
        screen_count = #screens,
        screens = {},
        total_width = 0,
        total_height = 0
    }

    for _, screen in ipairs(screens) do
        local frame = screen:frame()
        local screen_info = {
            name = screen:name() or "Unknown",
            id = screen:id(),
            frame = frame,
            is_main = screen == hs.screen.mainScreen()
        }

        table.insert(profile.screens, screen_info)
        profile.total_width = profile.total_width + frame.w
        profile.total_height = math.max(profile.total_height, frame.h)
    end

    return profile
end
```