# Hammerspoon Window Manager

This document describes the complete window management system implemented in `window.lua`. The system provides two distinct window management modes: half-screen positioning and quarter-screen positioning.

## Overview

The window manager provides intuitive keyboard shortcuts for window positioning with support for multiple displays. Both systems use contextual movement and cross-display support where appropriate.

## Half-Screen Positioning

**Modifier:** `ctrl+alt` + arrow keys

Traditional half-screen window management that creates perfect halves of the screen.

### Key Bindings

| Shortcut | Action | Result |
|----------|--------|---------|
| `ctrl+alt+←` | Left Half | Left half of current screen (full height), or cross-display from edges |
| `ctrl+alt+→` | Right Half | Right half of current screen (full height), or cross-display from edges |
| `ctrl+alt+↑` | Top Half | Top half of current screen (full width) |
| `ctrl+alt+↓` | Bottom Half | Bottom half of current screen (full width) |

### Cross-Display Behavior

- **Same-screen movement first**: Left/right arrows create left/right halves on current screen
- **Cross-display from edges**: When already at left/right edge, moves to adjacent display
  - Left half + `←` → Previous display's right half
  - Right half + `→` → Next display's left half
  - Top/bottom halves maintain vertical position when crossing displays
- **Vertical movement** (`↑/↓`): Creates top/bottom halves on current display only
- **Edge behavior**: Only triggers at absolute edges (first screen left, last screen right)
  - First screen left edge + `←` → Creates left half on first screen (edge function)
  - Last screen right edge + `→` → Creates right half on last screen (edge function)

## Quarter-Screen Positioning

**Modifier:** `ctrl+alt+shift` + arrow keys

Smart contextual quarter positioning that maintains current window position when moving in orthogonal directions.

### Key Bindings

| Shortcut | Action | Behavior |
|----------|--------|----------|
| `ctrl+alt+shift+←` | Move Left | Moves to left side, maintaining current top/bottom position |
| `ctrl+alt+shift+→` | Move Right | Moves to right side, maintaining current top/bottom position |
| `ctrl+alt+shift+↑` | Move Up | Moves to top side, maintaining current left/right position |
| `ctrl+alt+shift+↓` | Move Down | Moves to bottom side, maintaining current left/right position |

### Contextual Behavior

The quarter system is contextual - it maintains your current position when moving perpendicular directions:

**If in left quarters:**
- `↑/↓` moves between top-left ↔ bottom-left

**If in right quarters:**
- `↑/↓` moves between top-right ↔ bottom-right

**If in top quarters:**
- `←/→` moves between top-left ↔ top-right

**If in bottom quarters:**
- `←/→` moves between bottom-left ↔ bottom-right

### Cross-Display Behavior

- **Horizontal movement only**: Left/right arrows at edges move to adjacent displays
- **No vertical cross-display**: Up/down arrows never cross display boundaries
- **Edge function**: Only at absolute edges (first screen left, last screen right) creates half-screen windows
  - Left quarters at first screen + `←` → Left half of first screen
  - Right quarters at last screen + `→` → Right half of last screen

## Special Actions

| Shortcut | Action | Result |
|----------|--------|---------|
| `ctrl+alt+return` | Maximize | Window fills entire screen |
| `ctrl+alt+c` | Center | Centers window at 80% screen size |
| `ctrl+alt+o` | Restore | Restores window to original position |

## Movement Examples

### Half-Screen Examples

1. **Basic half positioning:**
   - Any window + `ctrl+alt+←` → Left half of current screen
   - Any window + `ctrl+alt+→` → Right half of current screen
   - `ctrl+alt+↑` → Top half of current screen
   - `ctrl+alt+↓` → Bottom half of current screen

2. **Same-screen movement:**
   - Window anywhere + `ctrl+alt+←` → Left half of screen 1
   - Left half of screen 1 + `ctrl+alt+→` → Right half of screen 1

3. **Cross-display movement:**
   - Right half of screen 1 + `ctrl+alt+→` → Left half of screen 2
   - Left half of screen 2 + `ctrl+alt+←` → Right half of screen 1
   - Top half of screen 1 + `→` (from right half) → Top half of screen 2
   - Bottom half of screen 2 + `←` (from left half) → Bottom half of screen 1

4. **Edge behavior (2 screens):**
   - Screen 1 left half + `ctrl+alt+←` → Left half of screen 1 (edge function)
   - Screen 2 right half + `ctrl+alt+→` → Right half of screen 2 (edge function)

### Quarter-Screen Examples

1. **Same screen movement:**
   - `ctrl+alt+shift+←` → Left-top quarter
   - `ctrl+alt+shift+↓` → Left-bottom quarter
   - `ctrl+alt+shift+→` → Right-bottom quarter
   - `ctrl+alt+shift+↑` → Right-top quarter

2. **Cross-display movement:**
   - Screen 1 left-top + `→` → Screen 1 right-top
   - `→` again → Screen 2 left-top
   - `→` again → Screen 2 right-top
   - `→` again → Right half of screen 2 (edge function, last screen)

3. **Edge behavior (2 screens):**
   - Screen 1 left-quarter + `ctrl+alt+shift+←` → Left half of screen 1 (edge function)
   - Screen 2 right-quarter + `ctrl+alt+shift+→` → Right half of screen 2 (edge function)

## System Differences

| Feature | Half-Screen (`ctrl+alt`) | Quarter-Screen (`ctrl+alt+shift`) |
|---------|--------------------------|-----------------------------------|
| **Window Size** | 50% of screen (half) | 25% of screen (quarter) |
| **Vertical Arrows** | Creates top/bottom halves on current display | Moves within current left/right side |
| **Horizontal Arrows** | Same-screen left/right first, then cross-display from edges | Moves within current top/bottom side |
| **Movement Logic** | Same-screen movement, then cross-display from edges | Contextual positioning |
| **Edge Function** | Creates half-screen at absolute edges only | Creates half-screen at absolute edges only |
| **Cross-Display** | Horizontal arrows only, maintains vertical position | Horizontal only |

## Edge Behavior

- **No cycling**: Reaching screen edges does not wrap around
- **Smart detection**: System accurately detects current window position
- **Graceful failure**: When no more displays are available, movement does nothing
- **Position memory**: Original window position is saved for restoration
- **Edge function triggers**: Only at absolute edges (first screen left, last screen right)
  - Creates half-screen size windows instead of quarters
  - Maintains full height, half width positioning
- **Cross-display movement**: Maintains vertical position and size when moving between screens

## Technical Details

- **Tolerance**: 5-10 pixel tolerance for position detection
- **Multi-monitor**: Supports any number of displays in any arrangement
- **Frame storage**: Original positions stored per-window for restoration
- **Context awareness**: System detects current window state for intelligent movement

## Configuration

The window manager is automatically loaded when Hammerspoon starts. Configuration changes can be made by editing `window.lua` and Hammerspoon will automatically reload the configuration.

## Troubleshooting

- **Reload config**: Use `ctrl+cmd+alt+R` to reload Hammerspoon configuration
- **Open console**: Use `ctrl+cmd+alt+H` to open Hammerspoon console for debugging
- **Check conflicts**: Ensure no other applications conflict with the same key combinations