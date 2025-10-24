# Window Utils (WindowUtils)

## Overview

WindowUtils provides advanced window manipulation utilities including frame management, cross-display positioning, and original position preservation. This module is the foundation for sophisticated window management across multiple monitors.

## Core Functionality

### Window Discovery and Validation

```lua
-- Window discovery and safety checks
window_utils.getFocusedWindow()
window_utils.getAllWindows()
window_utils.isValidWindow(window)
window_utils.getWindowInfo(window)
```

### Frame Management and Storage

```lua
-- Frame manipulation and preservation
window_utils.saveOriginalFrame(window)
window_utils.restoreOriginalFrame(window)
window_utils.setWindowFrame(window, frame, save_original)
window_utils.getWindowFrame(window)
```

### Window Positioning Operations

```lua
-- Half-screen positioning
window_utils.moveWindowToHalf(window, side, cross_display)
window_utils.leftHalf(window, cross_display)
window_utils.rightHalf(window, cross_display)
window_utils.topHalf(window, cross_display)
window_utils.bottomHalf(window, cross_display)

-- Quarter-screen positioning
window_utils.moveWindowToQuarter(window, quarter, cross_display)
window_utils.topLeftQuarter(window, cross_display)
window_utils.bottomRightQuarter(window, cross_display)
```

### Advanced Positioning Operations

```lua
-- Special positioning modes
window_utils.maximizeWindow(window, screen)
window_utils.centerWindow(window, scale)
window_utils.restoreWindow(window)
window_utils.resizeWindow(window, dimensions)
window_utils.moveWindow(window, position)
```

### Cross-Display Operations

```lua
-- Multi-monitor window management
window_utils.moveWindowToScreen(window, target_screen, preserve_position)
window_utils.moveWindowToNextDisplay(window, direction)
window_utils.canMoveToScreen(window, target_screen)
window_utils.getRelativePosition(window, source_screen, target_screen)
```

## API Reference

### `window_utils.getFocusedWindow()`

Gets the currently focused window with comprehensive safety checks.

**Returns:**
- `window` (table): Hammerspoon window object if focused window is valid, nil otherwise

**Example:**
```lua
-- Get focused window safely
local win = window_utils.getFocusedWindow()
if win then
    print("Focused window:", win:title())
else
    print("No focused window")
end
```

### `window_utils.getAllWindows()`

Gets all visible windows across all screens.

**Returns:**
- `windows` (array): Array of valid window objects

**Example:**
```lua
-- List all windows
local windows = window_utils.getAllWindows()
for i, win in ipairs(windows) do
    print(i, win:title(), win:application():title())
end
```

### `window_utils.saveOriginalFrame(window)`

Saves the original frame of a window for later restoration.

**Parameters:**
- `window` (table): Hammerspoon window object

**Returns:**
- `success` (boolean): Whether frame was saved successfully

**Example:**
```lua
-- Save current window position
local win = window_utils.getFocusedWindow()
if win then
    window_utils.saveOriginalFrame(win)
    print("Original frame saved")
end
```

### `window_utils.restoreOriginalFrame(window)`

Restores a window to its previously saved original frame.

**Parameters:**
- `window` (table): Hammerspoon window object

**Returns:**
- `success` (boolean): Whether frame was restored successfully

**Example:**
```lua
-- Restore window to original position
local win = window_utils.getFocusedWindow()
if win then
    local success = window_utils.restoreOriginalFrame(win)
    if success then
        print("Window restored to original position")
    end
end
```

### `window_utils.setWindowFrame(window, frame, save_original)`

Sets a window's frame with optional original frame saving.

**Parameters:**
- `window` (table): Hammerspoon window object
- `frame` (rect): Target frame geometry
- `save_original` (boolean, optional): Whether to save current frame first

**Returns:**
- `success` (boolean): Whether frame was set successfully

**Example:**
```lua
-- Move window to specific position
local win = window_utils.getFocusedWindow()
if win then
    local newFrame = hs.geometry.rect(100, 100, 800, 600)
    window_utils.setWindowFrame(win, newFrame, true)
end
```

### `window_utils.moveWindowToHalf(window, side, cross_display)`

Moves a window to half-screen position with optional cross-display support.

**Parameters:**
- `window` (table): Hammerspoon window object
- `side` (string): "left", "right", "top", or "bottom"
- `cross_display` (boolean, optional): Enable cross-display movement

**Returns:**
- `success` (boolean): Whether operation succeeded

**Example:**
```lua
-- Move window to left half of screen
local win = window_utils.getFocusedWindow()
if win then
    window_utils.moveWindowToHalf(win, "left", true)
end
```

### `window_utils.moveWindowToQuarter(window, quarter, cross_display)`

Moves a window to quarter-screen position with optional cross-display support.

**Parameters:**
- `window` (table): Hammerspoon window object
- `quarter` (string): "top_left", "top_right", "bottom_left", or "bottom_right"
- `cross_display` (boolean, optional): Enable cross-display movement

**Returns:**
- `success` (boolean): Whether operation succeeded

**Example:**
```lua
-- Move window to top-right quarter
local win = window_utils.getFocusedWindow()
if win then
    window_utils.moveWindowToQuarter(win, "top_right", true)
end
```

### `window_utils.maximizeWindow(window, screen)`

Maximizes a window on the specified screen.

**Parameters:**
- `window` (table): Hammerspoon window object
- `screen` (table, optional): Target screen (default: current screen)

**Returns:**
- `success` (boolean): Whether operation succeeded

**Example:**
```lua
-- Maximize current window
local win = window_utils.getFocusedWindow()
if win then
    window_utils.maximizeWindow(win)
end
```

### `window_utils.centerWindow(window, scale)`

Centers a window on its current screen with optional scaling.

**Parameters:**
- `window` (table): Hammerspoon window object
- `scale` (number, optional): Scale factor (default: 0.8)

**Returns:**
- `success` (boolean): Whether operation succeeded

**Example:**
```lua
-- Center window at 80% of screen size
local win = window_utils.getFocusedWindow()
if win then
    window_utils.centerWindow(win, 0.8)
end
```

### `window_utils.isValidWindow(window)`

Validates that a window object is usable for operations.

**Parameters:**
- `window` (any): Object to validate

**Returns:**
- `valid` (boolean): Whether object is a valid window

**Example:**
```lua
-- Validate window before operations
local win = hs.window.focusedWindow()
if window_utils.isValidWindow(win) then
    -- Safe to perform operations
    window_utils.maximizeWindow(win)
end
```

### `window_utils.getWindowInfo(window)`

Gets comprehensive information about a window.

**Parameters:**
- `window` (table): Hammerspoon window object

**Returns:**
- `info` (table): Window information object

**Example:**
```lua
-- Get detailed window information
local win = window_utils.getFocusedWindow()
if win then
    local info = window_utils.getWindowInfo(win)
    print("Window:", info.title)
    print("App:", info.application_name)
    print("Frame:", info.frame.x, info.frame.y, info.frame.w, info.frame.h)
    print("Screen:", info.screen_name)
end
```

### `window_utils.moveWindowToScreen(window, target_screen, preserve_position)`

Moves a window to a different screen with position preservation options.

**Parameters:**
- `window` (table): Hammerspoon window object
- `target_screen` (table): Target screen object
- `preserve_position` (boolean, optional): Whether to preserve relative position

**Returns:**
- `success` (boolean): Whether operation succeeded

**Example:**
```lua
-- Move window to next screen
local win = window_utils.getFocusedWindow()
if win then
    local nextScreen = require("utils.display_utils").getNextScreen(win:screen())
    if nextScreen then
        window_utils.moveWindowToScreen(win, nextScreen, true)
    end
end
```

## Window Frame Management

### Original Frame Storage

```lua
-- Internal frame storage with cleanup
local original_frames = {}
local frame_timestamps = {}
local CLEANUP_INTERVAL = 300  -- 5 minutes
local MAX_FRAME_AGE = 3600    -- 1 hour

local function saveOriginalFrameInternal(window)
    local window_id = window:id()
    local frame = window:frame()

    original_frames[window_id] = hs.geometry.copy(frame)
    frame_timestamps[window_id] = os.time()
end

local function cleanupOldFrames()
    local current_time = os.time()
    local to_remove = {}

    for window_id, timestamp in pairs(frame_timestamps) do
        if current_time - timestamp > MAX_FRAME_AGE then
            table.insert(to_remove, window_id)
        end
    end

    for _, window_id in ipairs(to_remove) do
        original_frames[window_id] = nil
        frame_timestamps[window_id] = nil
    end

    -- Log cleanup activity
    if #to_remove > 0 then
        print("Cleaned up", #to_remove, "old window frames")
    end
end
```

### Frame Calculations

```lua
-- Calculate half-screen frames
local function calculateHalfFrame(screen_frame, side, window_min_size)
    local half_frame = hs.geometry.copy(screen_frame)

    if side == "left" then
        half_frame.w = half_frame.w / 2
    elseif side == "right" then
        half_frame.w = half_frame.w / 2
        half_frame.x = half_frame.x + half_frame.w
    elseif side == "top" then
        half_frame.h = half_frame.h / 2
    elseif side == "bottom" then
        half_frame.h = half_frame.h / 2
        half_frame.y = half_frame.y + half_frame.h
    end

    -- Apply minimum size constraints
    if window_min_size then
        half_frame.w = math.max(half_frame.w, window_min_size.w)
        half_frame.h = math.max(half_frame.h, window_min_size.h)
    end

    return half_frame
end

-- Calculate quarter-screen frames
local function calculateQuarterFrame(screen_frame, quarter, window_min_size)
    local quarter_frame = hs.geometry.copy(screen_frame)
    quarter_frame.w = quarter_frame.w / 2
    quarter_frame.h = quarter_frame.h / 2

    if quarter == "top_left" then
        -- No adjustment needed
    elseif quarter == "top_right" then
        quarter_frame.x = quarter_frame.x + quarter_frame.w
    elseif quarter == "bottom_left" then
        quarter_frame.y = quarter_frame.y + quarter_frame.h
    elseif quarter == "bottom_right" then
        quarter_frame.x = quarter_frame.x + quarter_frame.w
        quarter_frame.y = quarter_frame.y + quarter_frame.h
    end

    -- Apply minimum size constraints
    if window_min_size then
        quarter_frame.w = math.max(quarter_frame.w, window_min_size.w)
        quarter_frame.h = math.max(quarter_frame.h, window_min_size.h)
    end

    return quarter_frame
end
```

### Frame Constraints and Safety

```lua
-- Apply frame constraints for safety
local function applyFrameConstraints(frame, screen_frame, window)
    local constrained = hs.geometry.copy(frame)

    -- Ensure frame is within screen bounds
    constrained.x = math.max(screen_frame.x,
        math.min(constrained.x, screen_frame.x + screen_frame.w - constrained.w))
    constrained.y = math.max(screen_frame.y,
        math.min(constrained.y, screen_frame.y + screen_frame.h - constrained.h))

    -- Apply minimum size constraints
    local min_size = window:minSize()
    if min_size then
        constrained.w = math.max(constrained.w, min_size.w)
        constrained.h = math.max(constrained.h, min_size.h)
    end

    -- Apply maximum size constraints
    local max_size = window:maxSize()
    if max_size then
        constrained.w = math.min(constrained.w, max_size.w)
        constrained.h = math.min(constrained.h, max_size.h)
    end

    return constrained
end
```

## Cross-Display Window Management

### Position Translation

```lua
-- Translate window position between screens
local function translatePositionBetweenScreens(window, source_screen, target_screen, current_frame)
    local source_frame = source_screen:frame()
    local target_frame = target_screen:frame()

    -- Calculate relative position within source screen
    local rel_x = (current_frame.x - source_frame.x) / source_frame.w
    local rel_y = (current_frame.y - source_frame.y) / source_frame.h
    local rel_w = current_frame.w / source_frame.w
    local rel_h = current_frame.h / source_frame.h

    -- Apply to target screen
    local new_frame = hs.geometry.rect(
        target_frame.x + (rel_x * target_frame.w),
        target_frame.y + (rel_y * target_frame.h),
        rel_w * target_frame.w,
        rel_h * target_frame.h
    )

    return new_frame
end

-- Smart positioning across screens
local function smartCrossDisplayPosition(window, target_screen)
    local current_frame = window:frame()
    local current_screen = window:screen()
    local target_frame = target_screen:frame()

    -- Try to preserve relative position
    local new_frame = translatePositionBetweenScreens(
        window, current_screen, target_screen, current_frame
    )

    -- Ensure frame is within target screen bounds
    if new_frame.x < target_frame.x then
        new_frame.x = target_frame.x
    elseif new_frame.x + new_frame.w > target_frame.x + target_frame.w then
        new_frame.x = target_frame.x + target_frame.w - new_frame.w
    end

    if new_frame.y < target_frame.y then
        new_frame.y = target_frame.y
    elseif new_frame.y + new_frame.h > target_frame.y + target_frame.h then
        new_frame.y = target_frame.y + target_frame.h - new_frame.h
    end

    return new_frame
end
```

### Multi-Screen Edge Detection

```lua
-- Detect screen edges for smart movement
local function getScreenEdges(screen)
    local frame = screen:frame()
    local all_screens = hs.screen.allScreens()

    local edges = {
        left = true, right = true, top = true, bottom = true
    }

    -- Check for adjacent screens
    for _, other_screen in ipairs(all_screens) do
        if other_screen ~= screen then
            local other_frame = other_screen:frame()

            -- Left edge adjacency
            if math.abs(frame.x - (other_frame.x + other_frame.w)) < 10 then
                edges.left = false
            end

            -- Right edge adjacency
            if math.abs((frame.x + frame.w) - other_frame.x) < 10 then
                edges.right = false
            end

            -- Top edge adjacency
            if math.abs(frame.y - (other_frame.y + other_frame.h)) < 10 then
                edges.top = false
            end

            -- Bottom edge adjacency
            if math.abs((frame.y + frame.h) - other_frame.y) < 10 then
                edges.bottom = false
            end
        end
    end

    return edges
end
```

## Window Information and Metadata

### Comprehensive Window Information

```lua
-- Gather detailed window information
local function getWindowInformation(window)
    if not window or not window:frame() then
        return nil
    end

    local app = window:application()
    local screen = window:screen()

    return {
        -- Basic window info
        id = window:id(),
        title = window:title(),
        role = window:role(),
        subrole = window:subrole(),

        -- Application info
        application_name = app and app:title() or "Unknown",
        application_bundle_id = app and app:bundleID() or "Unknown",

        -- Geometry info
        frame = hs.geometry.copy(window:frame()),
        screen_frame = screen and screen:frame() or nil,
        screen_name = screen and screen:name() or "Unknown",

        -- State info
        visible = window:isVisible(),
        focused = window:isFocused(),
        minimized = window:isMinimized(),
        fullscreen = window:isFullScreen(),

        -- Size constraints
        min_size = window:minSize(),
        max_size = window:maxSize(),

        -- Timestamps
        info_timestamp = os.time()
    }
end

-- Window state tracking
local window_states = {}

local function updateWindowState(window, operation)
    local window_id = window:id()
    local info = getWindowInformation(window)

    if info then
        window_states[window_id] = {
            current_info = info,
            last_operation = operation,
            operation_timestamp = os.time(),
            operation_history = window_states[window_id] and
                window_states[window_id].operation_history or {}
        }

        -- Add to operation history
        table.insert(window_states[window_id].operation_history, {
            operation = operation,
            timestamp = os.time(),
            frame = hs.geometry.copy(info.frame)
        })

        -- Limit history size
        local history = window_states[window_id].operation_history
        if #history > 10 then
            table.remove(history, 1)
        end
    end
end
```

## Integration with Other Modules

### Display Utils Integration

```lua
-- Integration with display_utils for multi-monitor support
local display_utils = require("utils.display_utils")

local function moveWindowWithScreenSupport(window, side, cross_display)
    local current_screen = window:screen()

    if cross_display then
        local edges = getScreenEdges(current_screen)

        -- Check if we should move to adjacent screen
        if side == "left" and not edges.left then
            local adjacent_screens = display_utils.getAdjacentScreens(current_screen)
            if adjacent_screens.left then
                window_utils.moveWindowToScreen(window, adjacent_screens.left, true)
                return true
            end
        elseif side == "right" and not edges.right then
            local adjacent_screens = display_utils.getAdjacentScreens(current_screen)
            if adjacent_screens.right then
                window_utils.moveWindowToScreen(window, adjacent_screens.right, true)
                return true
            end
        end
    end

    -- Normal screen positioning
    local frame = calculateHalfFrame(current_screen:frame(), side)
    window_utils.setWindowFrame(window, frame, true)
    return true
end
```

### App Utils Integration

```lua
-- Integration with app_utils for application-specific window behavior
local app_utils = require("utils.app_utils")

local function getAppSpecificWindowBehavior(window)
    local app = window:application()
    if not app then return nil end

    local bundle_id = app:bundleID()

    -- Define app-specific behaviors
    local app_behaviors = {
        ["com.apple.Terminal"] = {
            default_size = {w = 800, h = 600},
            snap_to_grid = true,
            prefer_quarter = true
        },
        ["com.google.Chrome"] = {
            default_size = {w = 1200, h = 800},
            snap_to_grid = false,
            prefer_half = true
        },
        ["com.apple.TextEdit"] = {
            default_size = {w = 600, h = 700},
            snap_to_grid = true,
            prefer_centered = true
        }
    }

    return app_behaviors[bundle_id]
end
```

## Performance Optimization

### Window Caching

```lua
-- Cache window information to reduce system calls
local window_cache = {}
local cache_timestamp = 0
local CACHE_DURATION = 0.1  -- 100ms

local function getCachedWindowInfo(window)
    local current_time = hs.timer.secondsSinceEpoch()
    local window_id = window:id()

    -- Check if cache is valid
    if window_cache[window_id] and
       current_time - window_cache[window_id].timestamp < CACHE_DURATION then
        return window_cache[window_id].info
    end

    -- Update cache
    local info = getWindowInformation(window)
    if info then
        window_cache[window_id] = {
            info = info,
            timestamp = current_time
        }
    end

    return info
end

-- Clean up cache periodically
local function cleanupWindowCache()
    local current_time = hs.timer.secondsSinceEpoch()
    local to_remove = {}

    for window_id, cached_data in pairs(window_cache) do
        if current_time - cached_data.timestamp > CACHE_DURATION * 10 then
            table.insert(to_remove, window_id)
        end
    end

    for _, window_id in ipairs(to_remove) do
        window_cache[window_id] = nil
    end
end
```

### Batch Operations

```lua
-- Efficient batch window operations
local function batchWindowOperation(windows, operation, ...)
    local results = {}
    local errors = {}

    for _, window in ipairs(windows) do
        local success, result = pcall(operation, window, ...)

        if success then
            table.insert(results, result)
        else
            table.insert(errors, {
                window = window,
                error = result
            })
        end
    end

    return results, errors
end

-- Multi-window positioning
local function arrangeWindowsInGrid(windows, grid_cols, grid_rows)
    local screen = hs.screen.mainScreen()
    local screen_frame = screen:frame()

    local cell_width = screen_frame.w / grid_cols
    local cell_height = screen_frame.h / grid_rows

    for i, window in ipairs(windows) do
        local col = (i - 1) % grid_cols
        local row = math.floor((i - 1) / grid_cols)

        local frame = hs.geometry.rect(
            screen_frame.x + col * cell_width,
            screen_frame.y + row * cell_height,
            cell_width,
            cell_height
        )

        window_utils.setWindowFrame(window, frame, true)
    end
end
```

## Debugging and Monitoring

### Window State Monitoring

```lua
-- Monitor window state changes
local function setupWindowMonitoring()
    hs.window.filter.new():subscribe(hs.window.filter.windowFocused, function(window)
        local info = window_utils.getWindowInfo(window)
        if info then
            print("Window focused:", info.title, "(", info.application_name, ")")
        end
    end)

    hs.window.filter.new():subscribe(hs.window.filter.windowCreated, function(window)
        local info = window_utils.getWindowInfo(window)
        if info then
            print("Window created:", info.title, "(", info.application_name, ")")
        end
    end)

    hs.window.filter.new():subscribe(hs.window.filter.windowDestroyed, function(window)
        print("Window destroyed:", window:id())
    end)
end

-- Debug window positioning
local function debugWindowPositioning(window)
    local info = window_utils.getWindowInfo(window)
    if not info then return end

    print("=== Window Debug Info ===")
    print("Title:", info.title)
    print("App:", info.application_name)
    print("Current frame:", info.frame.x, info.frame.y, info.frame.w, info.frame.h)
    print("Screen:", info.screen_name)
    print("Screen frame:", info.screen_frame.x, info.screen_frame.y,
          info.screen_frame.w, info.screen_frame.h)
    print("Min size:", info.min_size.w, info.min_size.h)
    print("Max size:", info.max_size.w, info.max_size.h)
    print("Visible:", info.visible, "Focused:", info.focused)
    print("Minimized:", info.minimized, "Fullscreen:", info.fullscreen)
    print("========================")
end
```

### Performance Metrics

```lua
-- Track window operation performance
local operation_metrics = {}

local function trackWindowOperation(operation_name, operation_func, ...)
    local start_time = hs.timer.secondsSinceEpoch()

    local success, result = pcall(operation_func, ...)
    local end_time = hs.timer.secondsSinceEpoch()

    local duration = end_time - start_time

    -- Update metrics
    if not operation_metrics[operation_name] then
        operation_metrics[operation_name] = {
            total_calls = 0,
            total_time = 0,
            average_time = 0,
            max_time = 0,
            errors = 0
        }
    end

    local metrics = operation_metrics[operation_name]
    metrics.total_calls = metrics.total_calls + 1
    metrics.total_time = metrics.total_time + duration
    metrics.average_time = metrics.total_time / metrics.total_calls
    metrics.max_time = math.max(metrics.max_time, duration)

    if not success then
        metrics.errors = metrics.errors + 1
    end

    -- Log slow operations
    if duration > 0.1 then  -- 100ms threshold
        print("Slow window operation:", operation_name, "took", duration, "seconds")
    end

    return success, result
end
```

## Best Practices

### 1. Safe Window Operations

```lua
-- Always validate windows before operations
local function safeWindowOperation(window, operation, ...)
    if not window_utils.isValidWindow(window) then
        print("Invalid window object")
        return false
    end

    local success, result = pcall(operation, window, ...)
    if not success then
        print("Window operation failed:", result)
        return false
    end

    return true, result
end
```

### 2. Original Frame Preservation

```lua
-- Always save original frames before repositioning
local function safeRepositionWindow(window, new_frame)
    window_utils.saveOriginalFrame(window)
    return window_utils.setWindowFrame(window, new_frame)
end
```

### 3. Multi-Screen Considerations

```lua
-- Handle multi-screen edge cases
local function safeMultiScreenOperation(window, operation)
    local screen = window:screen()
    if not screen then
        print("Window has no associated screen")
        return false
    end

    -- Check if window can be moved to target position
    local frame = window:frame()
    local screen_frame = screen:frame()

    if frame.x < screen_frame.x or
       frame.y < screen_frame.y or
       frame.x + frame.w > screen_frame.x + screen_frame.w or
       frame.y + frame.h > screen_frame.y + screen_frame.h then

        -- Window would be off-screen, try to reposition
        frame.x = math.max(screen_frame.x, frame.x)
        frame.y = math.max(screen_frame.y, frame.y)
        frame.x = math.min(screen_frame.x + screen_frame.w - frame.w, frame.x)
        frame.y = math.min(screen_frame.y + screen_frame.h - frame.h, frame.y)

        window:setFrame(frame)
    end

    return operation(window)
end
```

### 4. Performance Optimization

```lua
-- Batch window operations for better performance
local function optimizeWindowOperations(operations)
    -- Group operations by window
    local window_operations = {}

    for _, op in ipairs(operations) do
        local window_id = op.window:id()
        if not window_operations[window_id] then
            window_operations[window_id] = {}
        end
        table.insert(window_operations[window_id], op)
    end

    -- Execute operations per window
    for window_id, ops in pairs(window_operations) do
        for _, op in ipairs(ops) do
            safeWindowOperation(op.window, op.func, unpack(op.args))
        end
    end
end
```

## Troubleshooting

### Common Issues

1. **Window Not Found**: Always validate window objects before operations
2. **Frame Outside Screen**: Use frame constraints to keep windows visible
3. **Multi-Screen Issues**: Check screen adjacency and positioning logic
4. **Performance Issues**: Use caching and batch operations

### Debug Commands

```lua
-- Debug current window
local win = window_utils.getFocusedWindow()
if win then
    window_utils.debugWindowPositioning(win)
end

-- Test window positioning
local test_positions = {"left", "right", "top", "bottom", "top_left", "top_right"}
for _, pos in ipairs(test_positions) do
    print("Testing position:", pos)
    if pos:match("left|right|top|bottom") then
        window_utils.moveWindowToHalf(win, pos, false)
    else
        window_utils.moveWindowToQuarter(win, pos, false)
    end
    hs.timer.doAfter(1, function()
        window_utils.restoreOriginalFrame(win)
    end)
end

-- Check operation metrics
for op_name, metrics in pairs(operation_metrics) do
    print(op_name .. ":",
          metrics.total_calls, "calls,",
          string.format("%.3f", metrics.average_time), "avg time,",
          metrics.errors, "errors")
end
```

## Advanced Usage

### Window Workflows

```lua
-- Define window layout workflows
local window_workflows = {
    coding = {
        {app = "com.apple.Terminal", position = "left_half"},
        {app = "com.microsoft.vscode", position = "right_half"}
    },
    design = {
        {app = "com.adobe.Photoshop", position = "center", scale = 0.9},
        {app = "com.apple.Safari", position = "right_quarter"}
    },
    meeting = {
        {app = "us.zoom.xos", position = "center", scale = 0.8},
        {app = "com.apple.Notes", position = "bottom_quarter"}
    }
}

local function applyWindowWorkflow(workflow_name)
    local workflow = window_workflows[workflow_name]
    if not workflow then
        print("Unknown workflow:", workflow_name)
        return false
    end

    for _, item in ipairs(workflow) do
        local app = hs.application.get(item.app)
        if app then
            local windows = app:allWindows()
            if #windows > 0 then
                local window = windows[1]

                if item.position == "left_half" then
                    window_utils.moveWindowToHalf(window, "left")
                elseif item.position == "right_half" then
                    window_utils.moveWindowToHalf(window, "right")
                elseif item.position == "center" then
                    window_utils.centerWindow(window, item.scale or 0.8)
                elseif item.position == "right_quarter" then
                    window_utils.moveWindowToQuarter(window, "top_right")
                elseif item.position == "bottom_quarter" then
                    window_utils.moveWindowToQuarter(window, "bottom_left")
                end
            end
        end
    end

    return true
end
```

### Smart Window Management

```lua
-- Intelligent window positioning based on usage patterns
local function smartWindowArrangement()
    local windows = window_utils.getAllWindows()
    local screen = hs.screen.mainScreen()
    local screen_frame = screen:frame()

    -- Categorize windows by type
    local categories = {
        browsers = {},
        terminals = {},
        editors = {},
        utilities = {}
    }

    for _, window in ipairs(windows) do
        local info = window_utils.getWindowInfo(window)
        if info then
            if info.application_bundle_id:match("com%.apple%.Safari|com%.google%.Chrome") then
                table.insert(categories.browsers, window)
            elseif info.application_bundle_id:match("com%.apple%.Terminal") then
                table.insert(categories.terminals, window)
            elseif info.application_bundle_id:match("com%.microsoft%.vscode|com%.sublimetext%.3") then
                table.insert(categories.editors, window)
            else
                table.insert(categories.utilities, window)
            end
        end
    end

    -- Smart arrangement based on categories
    local arrangements = {
        browsers = {position = "right_half", count = 1},
        terminals = {position = "left_half", count = 2},
        editors = {position = "center", count = 1, scale = 0.8},
        utilities = {position = "bottom_quarter", count = 4}
    }

    for category, windows_list in pairs(categories) do
        local arrangement = arrangements[category]
        if arrangement and #windows_list > 0 then
            local max_windows = math.min(arrangement.count, #windows_list)

            for i = 1, max_windows do
                local window = windows_list[i]

                if arrangement.position == "left_half" then
                    if i == 1 then
                        window_utils.moveWindowToHalf(window, "left")
                    elseif i == 2 then
                        window_utils.moveWindowToQuarter(window, "bottom_left")
                    end
                elseif arrangement.position == "right_half" then
                    window_utils.moveWindowToHalf(window, "right")
                elseif arrangement.position == "center" then
                    window_utils.centerWindow(window, arrangement.scale)
                elseif arrangement.position == "bottom_quarter" then
                    local quarters = {"bottom_left", "bottom_right"}
                    local quarter = quarters[(i - 1) % #quarters + 1]
                    window_utils.moveWindowToQuarter(window, quarter)
                end
            end
        end
    end
end
```