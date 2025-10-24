# Window Management Module

## Overview

The `modules.window_management` module provides sophisticated window positioning functionality with Magnet-style behavior. It supports both half-screen and quarter-screen positioning with contextual movement, cross-display support, and advanced edge function behavior.

## Features

- **Half-Screen Positioning**: Left, right, top, bottom halves with smart edge behavior
- **Quarter-Screen Positioning**: Contextual quarter positioning with intelligent movement
- **Multi-Monitor Support**: Seamless window movement across multiple displays
- **Edge Functions**: Special behavior at screen boundaries (first/last screen edges)
- **Contextual Behavior**: Maintains position context when moving perpendicularly
- **Frame Memory**: Remembers original window positions for restoration
- **Cross-Display Movement**: Preserves window state when moving between displays

## Key Bindings

### Half-Screen Positioning (`ctrl+alt` + arrow keys)
| Shortcut | Action | Behavior |
|----------|--------|----------|
| `ctrl+alt+←` | Left Half | Left half of current screen, or cross-display from edges |
| `ctrl+alt+→` | Right Half | Right half of current screen, or cross-display from edges |
| `ctrl+alt+↑` | Top Half | Top half of current screen (full width) |
| `ctrl+alt+↓` | Bottom Half | Bottom half of current screen (full width) |

### Quarter-Screen Positioning (`ctrl+alt+shift` + arrow keys)
| Shortcut | Action | Behavior |
|----------|--------|----------|
| `ctrl+alt+shift+←` | Move Left | Moves to left side, maintaining current top/bottom position |
| `ctrl+alt+shift+→` | Move Right | Moves to right side, maintaining current top/bottom position |
| `ctrl+alt+shift+↑` | Move Up | Moves to top side, maintaining current left/right position |
| `ctrl+alt+shift+↓` | Move Down | Moves to bottom side, maintaining current left/right position |

### Special Actions
| Shortcut | Action | Result |
|----------|--------|---------|
| `ctrl+alt+return` | Maximize | Window fills entire screen |
| `ctrl+alt+c` | Center | Centers window at 80% screen size |
| `ctrl+alt+o` | Restore | Restores window to original position |

## API Reference

### `window_management.moveWindowHalf(direction)`
Move window to half-screen position.

**Parameters:**
- `direction` (string): `"left"`, `"right"`, `"top"`, or `"bottom"`

**Example:**
```lua
local window_management = require("modules.window_management")

-- Move window to left half
window_management.moveWindowHalf("left")

-- Move window to top half
window_management.moveWindowHalf("top")
```

### `window_management.moveWindowQuarter(direction)`
Move window to quarter-screen position with contextual behavior.

**Parameters:**
- `direction` (string): `"left"`, `"right"`, `"up"`, or `"down"`

**Example:**
```lua
local window_management = require("modules.window_management")

-- Move window to top-left quarter
window_management.moveWindowQuarter("up")
window_management.moveWindowQuarter("left")

-- Contextual movement maintains position
window_management.moveWindowQuarter("down") -- Moves to bottom-left
```

### `window_management.maximizeWindow()`
Maximize window to fill entire screen.

**Example:**
```lua
local window_management = require("modules.window_management")
window_management.maximizeWindow()
```

### `window_management.centerWindow()`
Center window on screen at 80% size.

**Example:**
```lua
local window_management = require("modules.window_management")
window_management.centerWindow()
```

### `window_management.restoreOriginalWindow()`
Restore window to its original position.

**Example:**
```lua
local window_management = require("modules.window_management")
window_management.restoreOriginalWindow()
```

### `window_management.moveWindow(position)` [Compatibility]
Legacy compatibility function for window positioning.

**Parameters:**
- `position` (string): `"maximize"`, `"center"`, `"original"`, or directional positions

## Behavior Details

### Half-Screen Positioning Logic

**Same-Screen Movement:**
- Left/right arrows create left/right halves on current screen
- Top/bottom arrows create top/bottom halves on current screen

**Cross-Display Movement:**
- When at left edge + `←` → Move to previous display's right half
- When at right edge + `→` → Move to next display's left half
- Top/bottom halves maintain vertical position when crossing displays

**Edge Functions:**
- First screen left edge + `←` → Creates left half (edge function)
- Last screen right edge + `→` → Creates right half (edge function)
- No cycling between displays

### Quarter-Screen Positioning Logic

**Contextual Movement:**
The quarter system is contextual - it maintains current position when moving perpendicularly:

**If in left quarters:**
- `↑/↓` moves between top-left ↔ bottom-left

**If in right quarters:**
- `↑/↓` moves between top-right ↔ bottom-right

**If in top quarters:**
- `←/→` moves between top-left ↔ top-right

**If in bottom quarters:**
- `←/→` moves between bottom-left ↔ bottom-right

**Cross-Display Behavior:**
- Horizontal movement only between displays
- Vertical movement never crosses display boundaries
- Edge functions create half-screens at absolute edges

### Edge Detection Logic

The system uses tolerance-based edge detection:

- **Half-screen tolerance**: 5 pixels
- **Quarter-screen tolerance**: 10 pixels

```lua
-- Left edge detection for half-screen
math.abs(current_frame.x - screen_frame.x) < 5

-- Left edge detection for quarter-screen
math.abs(current_frame.x - screen_frame.x) < 10
```

## Usage Examples

### Basic Window Positioning
```lua
local window_management = require("modules.window_management")

-- Move to left half
window_management.moveWindowHalf("left")

-- Move to top-right quarter (contextual)
window_management.moveWindowQuarter("up")
window_management.moveWindowQuarter("right")

-- Maximize window
window_management.maximizeWindow()

-- Restore original position
window_management.restoreOriginalWindow()
```

### Complex Multi-Monitor Workflow
```lua
local window_management = require("modules.window_management")

-- Setup main workspace
window_management.moveWindowHalf("left")  -- Left half of main display

-- Move to secondary monitor
window_management.moveWindowHalf("right") -- Right half (may cross to next display)
window_management.moveWindowHalf("right") -- Right half of secondary display

-- Setup quarter layout
window_management.moveWindowQuarter("up")    -- Top-right quarter
window_management.moveWindowQuarter("left")  -- Top-left quarter
window_management.moveWindowQuarter("down")  -- Bottom-left quarter
```

### Programmatic Window Management
```lua
local window_management = require("modules.window_management")

-- Function to setup development workspace
function setupDevWorkspace()
    -- Code editor on left
    window_management.moveWindowHalf("left")

    -- Terminal on right-top
    window_management.moveWindowQuarter("up")
    window_management.moveWindowQuarter("right")

    -- Browser on right-bottom
    window_management.moveWindowQuarter("down")
    window_management.moveWindowQuarter("right")
end

-- Function to reset all windows
function resetAllWindows()
    window_management.restoreOriginalWindow()
end
```

## Configuration

The window management module can be configured through the system configuration:

```lua
-- In config/hotkeys.lua
config.hotkeys.window = {
    hyper = {"ctrl", "alt"},
    hyper_shift = {"ctrl", "alt", "shift"},
    maximize = {"ctrl", "alt", "return"},
    center = {"ctrl", "alt", "c"},
    original = {"ctrl", "alt", "o"}
}
```

## Performance Considerations

### 1. **Frame Storage**
- Original window frames are stored per window
- Automatic cleanup prevents memory leaks
- Frames removed when windows are closed

### 2. **Edge Detection**
- Efficient mathematical calculations
- Minimal overhead in positioning operations
- Tolerance values optimized for typical usage

### 3. **Multi-Monitor Support**
- Efficient display detection algorithms
- Fast cross-display movement calculations
- Smart handling of display arrangement changes

## Best Practices

### 1. **Position Selection**
- Use half-screen positioning for primary workspace
- Use quarter-screen positioning for secondary content
- Take advantage of contextual movement for efficient workflows
- Use maximize for full-screen applications

### 2. **Multi-Monitor Usage**
- Understand edge behavior for display boundaries
- Use cross-display movement for multi-monitor workflows
- Leverage edge functions for display-edge positioning

### 3. **Keyboard Shortcuts**
- Memorize key patterns for efficient usage
- Use consistent modifier combinations
- Practice contextual movement patterns

## Troubleshooting

### 1. **Window Not Moving**
- Check if window has focus
- Verify window is not maximized or fullscreen
- Ensure target screen space is available

### 2. **Multi-Monitor Issues**
- Verify display arrangement in system preferences
- Check if displays are properly detected
- Ensure display boundaries are correctly calculated

### 3. **Contextual Movement Problems**
- Verify current window position
- Check edge detection tolerance
- Ensure display layout is as expected

### 4. **Frame Memory Issues**
- Check if original frame was saved
- Verify window still exists
- Ensure frame cleanup is working properly

## Advanced Features

### 1. **Custom Positioning**
The system can be extended with custom positioning logic:

```lua
-- Add custom positioning function
function window_management.moveToCustomPosition()
    local win = window_utils.getFocusedWindow()
    if not win then return end

    local screen = win:screen()
    local frame = screen:frame()

    -- Custom positioning logic
    local custom_frame = {
        x = frame.x + frame.w * 0.2,
        y = frame.y + frame.h * 0.2,
        w = frame.w * 0.6,
        h = frame.h * 0.6
    }

    win:setFrame(custom_frame)
end
```

### 2. **Workspace Layouts**
Create predefined workspace layouts:

```lua
-- Development workspace layout
function window_management.setupDevLayout()
    local apps = {"Code", "Terminal", "Browser"}
    local positions = {"left", "top-right", "bottom-right"}

    for i, app in ipairs(apps) do
        hs.application.launchOrFocus(app)
        hs.timer.doAfter(i * 0.5, function()
            if positions[i] == "left" then
                window_management.moveWindowHalf("left")
            elseif positions[i] == "top-right" then
                window_management.moveWindowQuarter("up")
                window_management.moveWindowQuarter("right")
            elseif positions[i] == "bottom-right" then
                window_management.moveWindowQuarter("down")
                window_management.moveWindowQuarter("right")
            end
        end)
    end
end
```

### 3. **Display-Specific Behavior**
Implement behavior specific to different display arrangements:

```lua
-- Handle display arrangement changes
hs.screen.watcher.new(function()
    log:i("Display arrangement changed, updating window positions")
    -- Custom logic for display changes
end):start()
```

## Integration with Other Modules

### 1. **App Launcher Integration**
```lua
-- Position window after launching app
local app_launcher = require("modules.app_launcher")

-- Override app launcher to position windows
app_launcher.launchAppWithPosition("Code", "left")
app_launcher.launchAppWithPosition("Terminal", "right")
```

### 2. **WiFi Automation Integration**
```lua
-- Change window layout based on network
local wifi_automation = require("modules.wifi_automation")

wifi_automation.onNetworkChange(function(ssid)
    if ssid == "WorkNetwork" then
        window_management.setupWorkLayout()
    else
        window_management.setupHomeLayout()
    end
end)
```

### 3. **Media Controls Integration**
```lua
-- Fullscreen media mode with window management
local media_controls = require("modules.media_controls")

media_controls.onMediaStart(function()
    window_management.maximizeWindow()
end)

media_controls.onMediaStop(function()
    window_management.restoreOriginalWindow()
end)
```

## Error Handling and Recovery

### 1. **Graceful Degradation**
```lua
function window_management.safeMoveWindow(direction)
    local success, err = pcall(function()
        window_management.moveWindowQuarter(direction)
    end)

    if not success then
        log:e("Failed to move window: " .. err)
        -- Fallback to simple centering
        window_management.centerWindow()
    end
end
```

### 2. **State Recovery**
```lua
-- Recover from invalid window states
function window_management.recoverWindowState(win)
    if not win then return end

    local frame = win:frame()
    local screen = win:screen()

    -- If window is outside screen bounds, center it
    if not screen:frame():contains(frame) then
        window_management.centerWindow()
    end
end
```

## Future Enhancements

### 1. **Advanced Features**
- Workspace presets and management
- Window snapping and grid systems
- Application-specific positioning rules
- Multi-window orchestration

### 2. **User Interface**
- Visual feedback for positioning
- On-screen indicators for movement
- Interactive positioning helpers
- Learning and recommendation system

### 3. **Performance Optimization**
- Cached display calculations
- Optimized edge detection algorithms
- Reduced memory footprint for frame storage
- Faster cross-display movement