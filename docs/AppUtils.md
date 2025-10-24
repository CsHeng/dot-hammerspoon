# Application Utilities (AppUtils)

## Overview

AppUtils provides comprehensive application management utilities including application detection, lifecycle management, and browser-specific functionality. This module serves as the foundation for application-related operations across the Hammerspoon configuration.

## Core Functionality

### Application Lifecycle Management

```lua
-- Launch or toggle application visibility
app_utils.toggleApp(name, bundle_id)
app_utils.launchApp(name, bundle_id)
app_utils.hideApp(identifier)
app_utils.focusApp(identifier)

-- Application process management
app_utils.restartApp(name, bundle_id)
app_utils.killApp(identifier, force)
app_utils.quitApp(identifier)
```

### Application Discovery and Information

```lua
-- Application listing and search
app_utils.listRunningApps()
app_utils.findApp(search_term)
app_utils.getApp(identifier)

-- Application state checking
app_utils.isAppRunning(bundle_id)
app_utils.isAppFocused(bundle_id)
app_utils.getFrontmostApp()
```

### Browser Detection and Special Handling

```lua
-- Browser-specific functionality
app_utils.isBrowser()
app_utils.isSafari()
app_utils.isChrome()
app_utils.isEdge()
```

## API Reference

### `app_utils.toggleApp(name, bundle_id)`

Toggles application visibility (launch if not running, hide if running and focused).

**Parameters:**
- `name` (string): Application name
- `bundle_id` (string): Application bundle identifier

**Returns:**
- `success` (boolean): Whether operation succeeded
- `app` (table): Hammerspoon application object if successful

**Example:**
```lua
-- Toggle Calendar application
local success, app = app_utils.toggleApp("Calendar", "com.apple.Calendar")
if success then
    print("Calendar toggled:", app:title())
end
```

### `app_utils.launchApp(name, bundle_id)`

Launches an application if it's not already running.

**Parameters:**
- `name` (string): Application name
- `bundle_id` (string): Application bundle identifier

**Returns:**
- `success` (boolean): Whether operation succeeded
- `app` (table): Hammerspoon application object if successful

**Example:**
```lua
-- Launch Safari
local success, app = app_utils.launchApp("Safari", "com.apple.Safari")
if not success then
    print("Failed to launch Safari")
end
```

### `app_utils.focusApp(identifier)`

Brings an application to the foreground.

**Parameters:**
- `identifier` (string): Application name or bundle ID

**Returns:**
- `success` (boolean): Whether operation succeeded
- `app` (table): Hammerspoon application object if successful

**Example:**
```lua
-- Focus Mail application
local success, app = app_utils.focusApp("Mail")
if success then
    print("Focused on:", app:title())
end
```

### `app_utils.hideApp(identifier)`

Hides an application (minimizes to background).

**Parameters:**
- `identifier` (string): Application name or bundle ID

**Returns:**
- `success` (boolean): Whether operation succeeded

**Example:**
```lua
-- Hide Preview application
local success = app_utils.hideApp("Preview")
if success then
    print("Preview hidden")
end
```

### `app_utils.restartApp(name, bundle_id)`

Restarts an application by killing and relaunching it.

**Parameters:**
- `name` (string): Application name
- `bundle_id` (string): Application bundle identifier

**Returns:**
- `success` (boolean): Whether operation succeeded

**Example:**
```lua
-- Restart problematic application
local success = app_utils.restartApp("Ghostty", "com.mitchellh.ghostty")
if success then
    print("Ghostty restarted")
end
```

### `app_utils.killApp(identifier, force)`

Kills an application process.

**Parameters:**
- `identifier` (string): Application name or bundle ID
- `force` (boolean, optional): Force kill (default: false)

**Returns:**
- `success` (boolean): Whether operation succeeded

**Example:**
```lua
-- Kill unresponsive application
local success = app_utils.killApp("UnresponsiveApp", true)
if success then
    print("Application force killed")
end
```

### `app_utils.listRunningApps()`

Returns a list of currently running applications.

**Returns:**
- `apps` (array): Array of application information objects

**Example:**
```lua
-- List all running applications
local apps = app_utils.listRunningApps()
for _, app in ipairs(apps) do
    print(app.name, app.bundle_id, app.title)
end
```

### `app_utils.findApp(search_term)`

Searches for applications matching the search term.

**Parameters:**
- `search_term` (string): Search term (name or bundle ID)

**Returns:**
- `app` (table): Application information if found, nil otherwise

**Example:**
```lua
-- Find Chrome application
local app = app_utils.findApp("Chrome")
if app then
    print("Found Chrome:", app.bundle_id)
end
```

### `app_utils.getApp(identifier)`

Gets an application object by name or bundle ID.

**Parameters:**
- `identifier` (string): Application name or bundle ID

**Returns:**
- `app` (table): Hammerspoon application object if found, nil otherwise

**Example:**
```lua
-- Get Safari application object
local safari = app_utils.getApp("Safari")
if safari then
    print("Safari is running:", safari:isRunning())
end
```

### `app_utils.isAppRunning(bundle_id)`

Checks if an application is currently running.

**Parameters:**
- `bundle_id` (string): Application bundle identifier

**Returns:**
- `running` (boolean): Whether application is running

**Example:**
```lua
-- Check if Music is running
if app_utils.isAppRunning("com.apple.Music") then
    print("Music is running")
end
```

### `app_utils.isAppFocused(bundle_id)`

Checks if an application is currently focused.

**Parameters:**
- `bundle_id` (string): Application bundle identifier

**Returns:**
- `focused` (boolean): Whether application is focused

**Example:**
```lua
-- Check if Mail is focused
if app_utils.isAppFocused("com.apple.Mail") then
    print("Mail is currently focused")
end
```

### `app_utils.getFrontmostApp()`

Gets the currently focused application.

**Returns:**
- `app` (table): Frontmost application object

**Example:**
```lua
-- Get current frontmost application
local app = app_utils.getFrontmostApp()
if app then
    print("Frontmost app:", app:title(), app:bundleID())
end
```

### `app_utils.isBrowser()`

Checks if the frontmost application is a web browser.

**Returns:**
- `is_browser` (boolean): Whether frontmost app is a browser

**Example:**
```lua
-- Check if current app is a browser
if app_utils.isBrowser() then
    print("Current app is a web browser")
end
```

### `app_utils.isSafari()`

Checks if the frontmost application is Safari.

**Returns:**
- `is_safari` (boolean): Whether frontmost app is Safari

**Example:**
```lua
-- Safari-specific handling
if app_utils.isSafari() then
    print("Safari detected - applying browser-specific settings")
end
```

### `app_utils.isChrome()`

Checks if the frontmost application is Chrome.

**Returns:**
- `is_chrome` (boolean): Whether frontmost app is Chrome

**Example:**
```lua
-- Chrome-specific handling
if app_utils.isChrome() then
    print("Chrome detected - applying browser-specific settings")
end
```

### `app_utils.isEdge()`

Checks if the frontmost application is Microsoft Edge.

**Returns:**
- `is_edge` (boolean): Whether frontmost app is Edge

**Example:**
```lua
-- Edge-specific handling
if app_utils.isEdge() then
    print("Edge detected - applying browser-specific settings")
end
```

## Application Information Structure

Functions return application information in this format:

```lua
{
    name = "Safari",
    bundle_id = "com.apple.Safari",
    title = "Apple - Search",
    path = "/Applications/Safari.app",
    running = true,
    focused = true,
    pid = 1234
}
```

## Browser Bundle IDs

The module recognizes these browsers:

```lua
local BROWSER_BUNDLE_IDS = {
    "com.apple.Safari",          -- Safari
    "com.google.Chrome",         -- Google Chrome
    "com.microsoft.edgemac",    -- Microsoft Edge
    "com.mozilla.firefox",       -- Mozilla Firefox
    "com.operasoftware.Opera",    -- Opera
    "com.vivaldi.Vivaldi"        -- Vivaldi
}
```

## Error Handling

All functions include comprehensive error handling:

```lua
-- Safe application toggling
local function safeToggleApp(name, bundle_id)
    local success, app = app_utils.toggleApp(name, bundle_id)
    if not success then
        print("Failed to toggle " .. name .. ": " .. (app or "unknown error"))
        return false
    end
    return true, app
end
```

## Performance Considerations

### Caching Strategies

```lua
-- Cache running applications to reduce system calls
local cached_apps = nil
local last_cache_time = 0

local function getCachedRunningApps()
    local current_time = hs.timer.secondsSinceEpoch()
    if not cached_apps or current_time - last_cache_time > 5 then
        cached_apps = app_utils.listRunningApps()
        last_cache_time = current_time
    end
    return cached_apps
end
```

### Batch Operations

```lua
-- Efficiently check multiple application states
local function checkMultipleApps(bundle_ids)
    local results = {}
    local running_apps = app_utils.listRunningApps()
    local running_set = {}

    -- Build lookup set
    for _, app in ipairs(running_apps) do
        running_set[app.bundle_id] = true
    end

    -- Check all requested apps
    for _, bundle_id in ipairs(bundle_ids) do
        results[bundle_id] = running_set[bundle_id] or false
    end

    return results
end
```

## Integration with Other Modules

### App Launcher Integration

```lua
-- Used by app_launcher module for hotkey-based app launching
local app_launcher = {}

function app_launcher.handleHotkey(app_config)
    local success, app = app_utils.toggleApp(app_config.name, app_config.bundle_id)
    if success then
        -- Additional launcher-specific logic
        app_launcher.onAppLaunched(app_config, app)
    end
end
```

### Window Management Integration

```lua
-- Used by window_management for app-specific window behavior
local window_management = {}

function window_management.getAppWindows(bundle_id)
    local app = app_utils.getApp(bundle_id)
    if not app then
        return {}
    end

    local windows = app:allWindows()
    -- Filter and return relevant windows
    return windows
end
```

## Debugging and Monitoring

### Application State Monitoring

```lua
-- Monitor application lifecycle events
local function monitorAppChanges()
    local previous_apps = {}

    hs.application.watcher.new(function(app_name, event, app_object)
        if event == hs.application.watcher.launched then
            print("App launched:", app_name)
        elseif event == hs.application.watcher.terminated then
            print("App terminated:", app_name)
        elseif event == hs.application.watcher.activated then
            print("App activated:", app_name)
        end
    end):start()
end
```

### Application Performance Metrics

```lua
-- Track application launch times
local launch_times = {}

local function measureLaunchTime(name, bundle_id)
    local start_time = hs.timer.secondsSinceEpoch()
    local success, app = app_utils.launchApp(name, bundle_id)
    local end_time = hs.timer.secondsSinceEpoch()

    if success then
        launch_times[name] = end_time - start_time
        print(name .. " launched in " .. launch_times[name] .. " seconds")
    end

    return success, app
end
```

## Best Practices

### 1. Application Identification

```lua
-- Always prefer bundle IDs for reliable identification
local function openBrowser()
    -- Bundle ID is more reliable than app name
    local success, app = app_utils.launchApp("Safari", "com.apple.Safari")
    return success, app
end
```

### 2. Error Recovery

```lua
-- Implement fallback strategies
local function robustToggleApp(name, bundle_id)
    local success, app = app_utils.toggleApp(name, bundle_id)

    if not success then
        -- Try alternative approach
        success, app = app_utils.launchApp(name, bundle_id)
        if success then
            app_utils.focusApp(bundle_id)
        end
    end

    return success, app
end
```

### 3. Resource Management

```lua
-- Clean up application references
local function cleanupAppReferences()
    -- Clear cached data
    cached_apps = nil
    last_cache_time = 0

    -- Force garbage collection
    collectgarbage("collect")
end
```

### 4. Concurrent Operations

```lua
-- Handle multiple application operations safely
local function safeBatchOperation(operations)
    local results = {}
    local errors = {}

    for _, op in ipairs(operations) do
        local success, result = pcall(function()
            return op.func(unpack(op.args))
        end)

        results[op.name] = success and result or nil
        if not success then
            errors[op.name] = result
        end
    end

    return results, errors
end
```

## Troubleshooting

### Common Issues

1. **Application Not Found**: Verify bundle ID and application name
2. **Permission Denied**: Check if Hammerspoon has Accessibility permissions
3. **Application Not Responding**: Use force kill option
4. **Bundle ID Mismatch**: Use `app_utils.listRunningApps()` to verify correct bundle IDs

### Debug Commands

```lua
-- List all running applications with details
local apps = app_utils.listRunningApps()
for _, app in ipairs(apps) do
    print(app.name, app.bundle_id, app.title, app.pid)
end

-- Test application detection
print("Is current app browser?", app_utils.isBrowser())
print("Frontmost app:", app_utils.getFrontmostApp():title())

-- Check specific application state
print("Safari running?", app_utils.isAppRunning("com.apple.Safari"))
print("Safari focused?", app_utils.isAppFocused("com.apple.Safari"))
```

## Advanced Usage

### Application Groups

```lua
-- Define application groups for batch operations
local app_groups = {
    browsers = {"com.apple.Safari", "com.google.Chrome", "com.microsoft.edgemac"},
    editors = {"com.apple.TextEdit", "com.sublimetext.3", "com.microsoft.vscode"},
    communication = {"com.apple.Mail", "com.apple.iChat", "com.tinyspeck.slackmacgap"}
}

local function toggleAppGroup(group_name)
    local group = app_groups[group_name]
    if not group then
        print("Unknown group:", group_name)
        return false
    end

    for _, bundle_id in ipairs(group) do
        local app = app_utils.getApp(bundle_id)
        if app and app:isRunning() then
            app_utils.hideApp(bundle_id)
        else
            app_utils.launchApp(bundle_id)
        end
    end

    return true
end
```

### Application Workflows

```lua
-- Define application workflows
local function startCodingSession()
    -- Launch development environment
    app_utils.launchApp("Code", "com.microsoft.vscode")
    app_utils.launchApp("Terminal", "com.apple.Terminal")
    app_utils.launchApp("Safari", "com.apple.Safari")

    -- Arrange windows
    hs.timer.doAfter(2, function()
        -- Window arrangement logic
    end)
end

local function startMeeting()
    -- Launch meeting applications
    app_utils.launchApp("Zoom", "us.zoom.xos")
    app_utils.launchApp("Calendar", "com.apple.Calendar")
end
```