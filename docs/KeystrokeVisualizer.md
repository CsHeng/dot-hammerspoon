# Keystroke Visualizer

## Overview

Keystroke Visualizer provides real-time visual feedback for keyboard input and mouse clicks. This module displays keystrokes on screen with customizable appearance, supporting multiple display modes and effects for training, demonstrations, and accessibility.

## Core Functionality

### Keystroke Display

- **Real-time Visualization**: Shows keyboard input as it happens
- **Multiple Display Modes**: Command-only, all modifiers, or all keys
- **Configurable Appearance**: Customizable colors, fonts, and positioning
- **Fade Effects**: Automatic fade-out after specified duration
- **Continuous Input Mode**: Chains multiple keystrokes in sequence

### Mouse Click Visualization

- **Click Circle Display**: Shows mouse clicks with animated circles
- **Button Identification**: Differentiates between left, right, and middle clicks
- **Click Position Tracking**: Displays circles at click locations
- **Configurable Duration**: Adjustable display time for click indicators

### Display Management

- **Draggable Interface**: Users can drag the display to preferred position
- **Screen Edge Support**: Positions display at any screen edge
- **Multi-Monitor Support**: Works across multiple displays
- **Show/Hide Controls**: Toggle visualization on/off with hotkeys

### Performance Features

- **Event Filtering**: Filters out unwanted keys and applications
- **Cleanup Management**: Automatic cleanup of expired visualizations
- **Memory Optimization**: Efficient rendering and resource management
- **Background Processing**: Minimal impact on system performance

## API Reference

### Control Functions

- `keystroke_visualizer.toggleKeystrokes()` - Toggle keystroke visualization
- `keystroke_visualizer.toggleClickCircle()` - Toggle mouse click visualization
- `keystroke_visualizer.toggleContinuousInput()` - Toggle continuous input mode
- `keystroke_visualizer.clearAllDrawings()` - Clear all current visualizations

### Display Functions

- `keystroke_visualizer.drawEvent(text, type, modifier)` - Draw keyboard event
- `keystroke_visualizer.show()` - Show visualizer display
- `keystroke_visualizer.hide()` - Hide visualizer display
- `keystroke_visualizer.setPosition(x, y)` - Set display position

### Configuration Functions

- `keystroke_visualizer.setDisplayMode(mode)` - Set display mode
- `keystroke_visualizer.setDuration(seconds)` - Set display duration
- `keystroke_visualizer.setFont(font, size)` - Set font settings
- `keystroke_visualizer.setColors(colors)` - Set color scheme

### Utility Functions

- `keystroke_visualizer.formatKeystroke(event)` - Format key for display
- `keystroke_visualizer.getDisplayInfo()` - Get current display information
- `keystroke_visualizer.isKeystrokeVisible()` - Check if keystrokes are visible
- `keystroke_visualizer.isClickCircleVisible()` - Check if click circles are visible

## Display Modes

### Command-Only Mode
- Shows only command key combinations (⌘ key)
- Filters out single key presses
- Ideal for demonstrating shortcuts

### All-Modifiers Mode
- Shows all modifier key combinations
- Displays ⌘, ⌥, ⌃, and ⇧ combinations
- Useful for comprehensive shortcut training

### All-Keys Mode
- Shows all keyboard input
- Displays individual key presses and combinations
- Best for detailed typing demonstrations

## Configuration Options

### Visual Settings
- **Display Duration**: Time before keystrokes fade out
- **Font Size**: Adjustable text size for visibility
- **Colors**: Configurable text and background colors
- **Position**: Draggable or fixed positioning

### Behavior Settings
- **Continuous Input**: Chain multiple keystrokes together
- **Character Limits**: Maximum characters in continuous mode
- **Timeout Settings**: Delay before clearing continuous input
- **Application Filtering**: Exclude specific applications

### Performance Settings
- **Cleanup Interval**: Frequency of expired drawing cleanup
- **Cache Settings**: Manage display cache for performance
- **Event Filtering**: Filter unnecessary events for efficiency

## Integration

### Hotkey System
- Integrated with main hotkey configuration
- Uses `ctrl+cmd+alt` modifier pattern
- Supports multiple control hotkeys:
  - Toggle keystroke display
  - Toggle click circle display
  - Toggle continuous input mode
  - Clear all visualizations

### Configuration System
- Reads settings from `config/keycastr.lua`
- Supports preset configurations
- Allows runtime configuration changes
- Provides configuration validation

### Display Utils Integration
- Uses display utilities for multi-monitor support
- Calculates optimal positioning across screens
- Handles screen configuration changes
- Provides edge detection for smart positioning

## Use Cases

### Training and Education
- Demonstrating keyboard shortcuts
- Teaching typing techniques
- Showing complex key combinations
- Accessibility for visual feedback

### Presentations and Demos
- Live coding demonstrations
- Software feature presentations
- Keyboard shortcut tutorials
- User interface demonstrations

### Accessibility Support
- Visual feedback for keyboard input
- Assistive technology for hearing-impaired users
- Confirmation of key press registration
- Training for new keyboard users

## Performance Considerations

- **Low Memory Usage**: Efficient rendering with automatic cleanup
- **Minimal CPU Impact**: Optimized event processing
- **Smart Filtering**: Reduces unnecessary visualizations
- **Background Operation**: Runs without affecting foreground applications

## Customization

### Visual Themes
- Pre-defined color schemes for different use cases
- High-contrast mode for accessibility
- Dark/light theme support
- Custom color configuration

### Behavior Tweaks
- Application-specific settings
- User-specific preferences
- Context-aware display adjustments
- Performance tuning options