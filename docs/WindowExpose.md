# Window Expose

## Overview

Window Expose provides thumbnail-based window overview functionality similar to macOS Mission Control. This module displays all visible windows across all spaces as thumbnails, allowing quick window selection and navigation. Implemented with lazy loading for optimal performance.

## Core Functionality

### Thumbnail Generation

- **Window Thumbnails**: Creates thumbnail previews of all visible windows
- **Cross-Space Visibility**: Shows windows from all desktop spaces
- **Automatic Filtering**: Filters out minimized and hidden windows
- **Thumbnail Sizing**: Calculates appropriate thumbnail sizes based on window count

### Display Management

- **Grid Layout**: Arranges thumbnails in organized grid pattern
- **Multi-Screen Support**: Works across multiple displays
- **Responsive Layout**: Adapts layout to available screen space
- **Smart Spacing**: Maintains appropriate spacing between thumbnails

### Window Selection

- **Click Navigation**: Click thumbnails to focus corresponding windows
- **Keyboard Navigation**: Navigate thumbnails with arrow keys
- **Visual Feedback**: Highlights selected thumbnails
- **Quick Access**: Rapid window switching without mouse

### Lazy Loading System

- **Performance Optimization**: Module loads only when first used
- **Memory Management**: Efficient resource usage
- **On-Demand Loading**: Initializes functionality on first activation
- **Clean Unloading**: Releases resources when not needed

## API Reference

### Core Functions

- `window_expose.toggle()` - Toggle expose visibility
- `window_expose.show()` - Show expose view
- `window_expose.hide()` - Hide expose view
- `window_expose.isLoaded()` - Check if module is loaded
- `window_expose.loadExpose()` - Load expose functionality

### Window Management

- `window_expose.getVisibleWindows()` - Get all visible windows
- `window_expose.focusWindow(thumbnail)` - Focus window from thumbnail
- `window_expose.refreshThumbnails()` - Refresh thumbnail images
- `window_expose.getWindowsForScreen(screen)` - Get windows for specific screen

### Display Functions

- `window_expose.calculateLayout(windows, screen)` - Calculate thumbnail grid layout
- `window_expose.createThumbnail(window, frame)` - Create window thumbnail
- `window_expose.updateThumbnailPositions()` - Update thumbnail positions
- `window_expose.clearThumbnails()` - Clear all thumbnails

### Navigation Functions

- `window_expose.selectNextThumbnail()` - Select next thumbnail
- `window_expose.selectPreviousThumbnail()` - Select previous thumbnail
- `window_expose.selectThumbnail(direction)` - Select thumbnail in direction
- `window_expose.getSelectedThumbnail()` - Get currently selected thumbnail

## Display Layout

### Grid Calculation

Automatically calculates optimal grid layout based on:
- Number of visible windows
- Available screen space
- Thumbnail aspect ratios
- Minimum thumbnail size requirements

### Sizing Algorithm

Determines thumbnail sizes using:
- Screen dimensions and resolution
- Window count and aspect ratios
- Minimum readable size constraints
- User preference settings

### Positioning Logic

Positions thumbnails using:
- Centered grid alignment
- Consistent spacing between thumbnails
- Screen edge constraints
- Visual hierarchy organization

## Lazy Loading Implementation

### Initialization Trigger

Module loads when:
- User presses expose hotkey (ctrl+cmd+tab)
- Explicit function call to loadExpose()
- First access to expose functionality

### Loading Process

1. **Dependency Check**: Verifies required modules are available
2. **Resource Allocation**: Sets up necessary resources and event taps
3. **Thumbnail Generation**: Creates initial window thumbnails
4. **Display Setup**: Configures visual elements and layouts
5. **Event Binding**: Sets up keyboard and mouse event handlers

### Performance Benefits

- **Reduced Memory Usage**: No resources consumed until needed
- **Faster Startup**: Improves initial Hammerspoon loading time
- **On-Demand Processing**: Only processes windows when expose is active
- **Resource Cleanup**: Releases resources when module is inactive

## Integration

### Hotkey System

- Integrated with main hotkey configuration
- Uses `ctrl+cmd+tab` hotkey for expose toggle
- Supports keyboard navigation within expose view
- Respects user-defined hotkey preferences

### Window Management Integration

- Works with window management utilities
- Respects window positioning and sizing
- Coordinates with multi-monitor window operations
- Maintains consistency with other window features

### Display Utils Integration

- Uses display utilities for multi-monitor support
- Calculates layouts across multiple screens
- Handles screen configuration changes
- Provides consistent cross-display behavior

## Use Cases

### Window Navigation

- Quickly locate specific windows among many open applications
- Switch between windows without using application switcher
- Navigate windows across multiple desktop spaces
- Find windows when they're hidden behind other windows

### Visual Overview

- Get overview of all current workspace windows
- Identify window contents at a glance
- Organize workspace by seeing all windows simultaneously
- Clean up desktop by identifying unnecessary windows

### Productivity Enhancement

- Rapid window switching for multitasking workflows
- Visual workspace management and organization
- Quick access to specific windows in complex setups
- Reduced time spent searching for windows

## Configuration Options

### Visual Settings
- **Thumbnail Size**: Minimum and maximum thumbnail dimensions
- **Grid Spacing**: Space between thumbnails
- **Selection Highlight**: Visual feedback for selected thumbnails
- **Background Opacity**: Background dimming level

### Behavior Settings
- **Auto-hide Duration**: Time before auto-hiding expose
- **Window Filtering**: Types of windows to include/exclude
- **Animation Settings**: Enable/disable transition animations
- **Keyboard Navigation**: Configure navigation keys

### Performance Settings
- **Thumbnail Quality**: Balance between quality and performance
- **Refresh Rate**: Thumbnail update frequency
- **Memory Limits**: Maximum memory usage for thumbnails
- **Cache Settings**: Thumbnail caching behavior

## Performance Considerations

### Optimization Features

- **Smart Filtering**: Only processes relevant windows
- **Thumbnail Caching**: Caches thumbnails to reduce redraws
- **Lazy Updates**: Updates only visible thumbnails
- **Memory Management**: Automatically cleans up unused resources

### Resource Management

- **Efficient Rendering**: Uses optimized drawing methods
- **Background Processing**: Non-blocking thumbnail generation
- **Resource Cleanup**: Releases resources when expose is hidden
- **Memory Monitoring**: Tracks and controls memory usage

## Troubleshooting

### Common Issues

- **Slow Loading**: Performance optimization through lazy loading
- **Memory Usage**: Automatic resource cleanup and monitoring
- **Thumbnail Quality**: Adjustable quality settings
- **Display Issues**: Multi-monitor layout recalculations

### Debug Functions

- **Status Checking**: Verify module loading state
- **Window Listing**: Debug window detection and filtering
- **Layout Debugging**: Verify thumbnail positioning calculations
- **Performance Monitoring**: Track resource usage and timing