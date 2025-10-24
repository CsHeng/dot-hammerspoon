# Core Logger Module

## Overview

The `core.logger` module provides a sophisticated logging infrastructure for the Hammerspoon modular system. It offers structured logging with multiple levels, configurable outputs, and consistent formatting across all modules.

## Features

- **Structured Logging**: Consistent log format with timestamps and module identification
- **Log Levels**: Support for Debug, Info, Warning, and Error levels
- **Configurable Output**: Console and file output with level filtering
- **Module-Specific Loggers**: Each module gets its own logger instance
- **Performance Optimized**: Efficient logging with minimal overhead
- **Thread Safety**: Safe for use in callback functions and event handlers

## Logger Levels

| Level | Description | Usage |
|-------|-------------|---------|
| `debug` | Detailed diagnostic information | Development and troubleshooting |
| `info` | General informational messages | Normal operation tracking |
| `warning` | Potentially problematic situations | Non-critical issues |
| `error` | Error conditions that need attention | Failures and exceptions |

## API Reference

### `logger.getLogger(module_name)`
Creates and returns a logger instance for a specific module.

**Parameters:**
- `module_name` (string): Name of the module for this logger

**Returns:**
- Logger object with logging methods

**Example:**
```lua
local logger = require("core.logger")
local log = logger.getLogger("my_module")

log:i("Module initialized successfully")
log:d("Debug information: %s", debug_data)
```

### Logger Methods

All logger methods support formatted output with string formatting:

- `log:i(message, ...)` - Info level
- `log:w(message, ...)` - Warning level
- `log:e(message, ...)` - Error level
- `log:d(message, ...)` - Debug level

**Parameters:**
- `message` (string): Log message with optional formatting
- `...` (optional): Values for string formatting

## Usage Examples

### Basic Logging
```lua
local logger = require("core.logger")
local log = logger.getLogger("window_management")

-- Info messages
log:i("Window management module initialized")

-- Debug messages
log:d("Window frame: x=%d, y=%d, w=%d, h=%d", frame.x, frame.y, frame.w, frame.h)

-- Warning messages
log:w("Window not found for operation: %s", operation)

-- Error messages
log:e("Failed to move window: %s", error_message)
```

### Conditional Logging
```lua
-- Only log debug information in development
if debug_mode then
    log:d("Detailed debugging information")
end

-- Log warnings conditionally
if not success then
    log:w("Operation completed with warnings")
end
```

### Error Handling with Logging
```lua
local success, result = pcall(function()
    -- Potentially failing operation
    performComplexOperation()
end)

if not success then
    log:e("Operation failed: %s", result)
    -- Handle error appropriately
end
```

## Configuration

The logger can be configured through the system configuration:

```lua
-- In core/config_loader.lua
config.logger = {
    level = "info",  -- Minimum log level to display
    output = "console", -- Output destination
    format = "[%s] %s: %s", -- Log format: [timestamp] module: message
    timestamp_format = "%H:%M:%S" -- Timestamp format
}
```

## Log Format

Logs are formatted as:
```
[timestamp] module_name: message
```

**Example Output:**
```
[12:34:56] window_man: Window management module initialized
[12:34:57] window_man: Moving window to left half
[12:34:58] window_man: Window positioned successfully
[12:34:59] window_man: Warning: Window already at left edge
```

## Performance Considerations

### 1. **String Formatting**
- Use string formatting only when necessary
- Expensive operations should be guarded by log level checks
- Consider pre-formatting strings for frequently logged messages

### 2. **Level Filtering**
- Debug logs are only processed when debug level is enabled
- Use level checks for expensive logging operations:
```lua
if log:isDebugEnabled() then
    log:d("Expensive debug operation: %s", expensive_function())
end
```

### 3. **Minimal Overhead**
- Logger creation is lightweight
- Log level checks are fast
- Disabled log levels have minimal performance impact

## Best Practices

### 1. **Meaningful Log Messages**
- Be specific and descriptive
- Include relevant context and data
- Use consistent terminology

**Good:**
```lua
log:i("Window moved to screen %d, position: %s", screen_id, position)
```

**Poor:**
```lua
log:i("Window moved")
```

### 2. **Appropriate Log Levels**
- Use `debug` for detailed diagnostic information
- Use `info` for normal operation tracking
- Use `warning` for non-critical issues
- Use `error` for failures and exceptions

### 3. **Consistent Module Names**
- Use the same module name throughout the module
- Follow naming convention: `module_name` in lowercase
- Be descriptive but concise

## Troubleshooting

### 1. **Logs Not Appearing**
- Check log level configuration
- Verify logger is properly initialized
- Ensure log level is appropriate for message

### 2. **Performance Issues**
- Reduce debug logging in production
- Guard expensive operations with level checks
- Consider disabling specific module logging

### 3. **Format Issues**
- Verify string formatting syntax
- Ensure correct number of format arguments
- Check for special characters in messages

## Integration with Other Modules

### 1. **Module Initialization**
```lua
local logger = require("core.logger")
local log = logger.getLogger("my_module")

function M.init()
    log:i("Module initialization started")
    -- Module setup code
    log:i("Module initialization completed")
end
```

### 2. **Error Handling**
```lua
local function riskyOperation()
    local success, result = pcall(function()
        -- Operation that might fail
    end)

    if not success then
        log:e("Risk operation failed: %s", result)
        return false
    end

    return result
end
```

### 3. **Event Handling**
```lua
hs.wifi.watcher.new(function()
    log:i("WiFi state changed")
    -- Handle WiFi change
end):start()
```

## Future Enhancements

### 1. **File Output**
- Log to files with rotation
- Separate files by module and level
- Compressed log file support

### 2. **Remote Logging**
- Network logging support
- Log aggregation services
- Real-time monitoring

### 3. **Advanced Features**
- Log filtering and searching
- Performance metrics logging
- Log analysis tools