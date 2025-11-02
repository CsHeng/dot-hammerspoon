--- Notch hider module for MacBook Pro integrated screens
-- Creates a black window covering the notch area (like Boring Notch)

local config = require("core.config_loader")
local log = require("core.logger").getLogger("notch_hider")

local M = {}

-- Local state
local notchWindow = nil
local isActive = false
local notchScreen = nil
local warnedNoNotch = false
local CONFIG_UUID_SENTINEL = "__NOTCH_UUID_SENTINEL__"
local screenWatcher = nil

-- Default configuration
local defaultConfig = {
  enabled = false,
  auto_hide = true,
  cover_height = 40,  -- Height to cover notch and menubar area
  opacity = 1.0,
  show_on_menu_bar = false,
  corner_radius = 18,
  overscan = 8,
  screen_uuid = false,
}

-- Get notch screen (built-in MacBook display)
local function getNotchScreen()
  local screens = hs.screen.allScreens()

  -- Prefer explicitly configured screen UUID if provided
  local configuredUUID = config.get("notch_hider.screen_uuid", CONFIG_UUID_SENTINEL)
  if configuredUUID ~= CONFIG_UUID_SENTINEL and configuredUUID then
    for _, screen in ipairs(screens) do
      if screen.getUUID and screen:getUUID() == configuredUUID then
        log:i("Using configured notch display uuid: " .. configuredUUID)
        return screen
      end
    end
    log:w("Configured notch display uuid not found, falling back to auto-detection")
  end

  -- First try to find built-in display using multiple methods
  for _, screen in ipairs(screens) do
    local screenName = screen:name() or ""
    local lowerName = screenName:lower()
    local uuid = screen.getUUID and screen:getUUID() or ""

    if screen.isBuiltIn and screen:isBuiltIn() then
      log:i("Found built-in display via API: " .. screenName)
      return screen
    end

    if uuid ~= "" and uuid:find("Builtin", 1, true) then
      log:i("Found built-in display via UUID: " .. screenName .. " (" .. uuid .. ")")
      return screen
    end

    if string.match(lowerName, "built%-in") or
       string.match(lowerName, "retina") or
       string.match(lowerName, "macbook") or
       string.match(lowerName, "color%s*lcd") then
      log:i("Found built-in display via name match: " .. screenName)
      return screen
    end

    -- Check safe frame difference to detect notch characteristics
    if screen == hs.screen.mainScreen() then
      local frame = screen:fullFrame()
      local safeFrame = screen:frame()
      if frame and safeFrame and (safeFrame.w < frame.w or safeFrame.x > frame.x) then
        log:i("Found main display with notch: " .. screenName)
        return screen
      end
    end

    local frame = screen:fullFrame()
    local safeFrame = screen:frame()
    if frame and safeFrame and ((safeFrame.w < frame.w) or (safeFrame.x > frame.x) or (safeFrame.h < frame.h) or (safeFrame.y > frame.y)) then
      log:i("Found notch display via safe frame diff: " .. screenName)
      return screen
    end
  end

  -- Fallback: use the primary screen for testing/demo purposes
  local primaryScreen = hs.screen.mainScreen()
  if primaryScreen then
    if not warnedNoNotch then
      log:w("No notch display found, using primary screen for demo")
      warnedNoNotch = true
    else
      log:d("No notch display found, continuing to use primary screen")
    end
    return primaryScreen
  end

  return nil
end

-- Create notch covering window
local function createNotchCover()
  if not notchScreen then return end

  local screenFrame = notchScreen:fullFrame() or notchScreen:frame()
  if not screenFrame then
    log:e("Unable to determine screen frame for notch display")
    return false
  end

  -- Calculate the area to cover - full width at top of screen
  local coverHeight = config.get("notch_hider.cover_height", defaultConfig.cover_height)
  local coverWidth = screenFrame.w
  local opacity = config.get("notch_hider.opacity", defaultConfig.opacity)
  local cornerRadius = config.get("notch_hider.corner_radius", defaultConfig.corner_radius)
  local overscan = config.get("notch_hider.overscan", defaultConfig.overscan)

  cornerRadius = tonumber(cornerRadius) or defaultConfig.corner_radius
  overscan = tonumber(overscan) or defaultConfig.overscan
  cornerRadius = math.max(0, cornerRadius)
  overscan = math.max(0, overscan)

  local windowRect = {
    x = screenFrame.x - overscan,
    y = screenFrame.y - cornerRadius,
    w = coverWidth + (overscan * 2),
    h = coverHeight + cornerRadius + overscan
  }

  cornerRadius = math.min(cornerRadius, windowRect.h / 2)

  notchWindow = hs.canvas.new(windowRect)
  notchWindow:behavior(hs.canvas.windowBehaviors.canJoinAllSpaces)
  if notchWindow.clickThrough then
    notchWindow:clickThrough(true)
  elseif notchWindow.canvasMouseEvents then
    notchWindow:canvasMouseEvents(false)
  end
  notchWindow:level(hs.canvas.windowLevels.desktopIcon + 1)
  notchWindow[1] = {
    type = "rectangle",
    action = "fill",
    fillColor = {hex = "#000000", alpha = opacity},
    frame = {x = 0, y = 0, w = windowRect.w, h = math.max(cornerRadius * 2, cornerRadius + 1)},
    roundedRectRadii = {
      xRadius = cornerRadius,
      yRadius = cornerRadius
    }
  }

  notchWindow[2] = {
    type = "rectangle",
    action = "fill",
    fillColor = {hex = "#000000", alpha = opacity},
    frame = {x = 0, y = cornerRadius, w = windowRect.w, h = math.max(windowRect.h - cornerRadius, 0)}
  }

  notchWindow:show()
  log:i("Notch cover window created successfully")
  return true
end

-- Remove notch covering window
local function removeNotchCover()
  if notchWindow then
    notchWindow:delete()
    notchWindow = nil
    log:d("Notch cover window removed")
  end
end

-- Show notch hider
function M.show()
  if isActive then
    log:w("Notch hider is already active")
    hs.alert.show("Notch hider already active", {atScreen = 0})
    return
  end

  if notchScreen then
    local stillExists = false
    for _, screen in ipairs(hs.screen.allScreens()) do
      if screen == notchScreen then
        stillExists = true
        break
      end
    end
    if not stillExists then
      notchScreen = nil
    end
  end

  if not notchScreen then
    local configuredUUID = config.get("notch_hider.screen_uuid", CONFIG_UUID_SENTINEL)
    if configuredUUID ~= CONFIG_UUID_SENTINEL and configuredUUID then
      for _, screen in ipairs(hs.screen.allScreens()) do
        if screen.getUUID and screen:getUUID() == configuredUUID then
          notchScreen = screen
          log:i("Using configured notch display: " .. configuredUUID)
          break
        end
      end
      if not notchScreen then
        log:w("Configured notch display uuid not found, falling back to auto-detection")
      end
    end
  end

  if not notchScreen then
    notchScreen = getNotchScreen()
  end
  if not notchScreen then
    log:e("No display found")
    hs.alert.show("No display found", {atScreen = 0})
    return false
  end

  if createNotchCover() then
    isActive = true
    warnedNoNotch = false
    log:i("Notch hider activated")
    hs.alert.show("Notch hider enabled", {atScreen = 0}, 2.0)
    return true
  else
    log:e("Failed to create notch cover")
    hs.alert.show("Failed to enable notch hider", {atScreen = 0})
    return false
  end
end

-- Hide notch hider
function M.hide()
  if not isActive then
    log:w("Notch hider is not active")
    hs.alert.show("Notch hider already disabled", {atScreen = 0})
    return
  end

  removeNotchCover()
  isActive = false
  warnedNoNotch = false
  log:i("Notch hider deactivated")
  hs.alert.show("Notch hider disabled", {atScreen = 0}, 2.0)
end

-- Toggle notch hider
function M.toggle()
  if isActive then
    M.hide()
  else
    M.show()
  end
end

-- Get current status
function M.getStatus()
  return {
    active = isActive,
    hasNotchScreen = notchScreen ~= nil,
    windowExists = notchWindow ~= nil
  }
end

-- Auto-hide when display configuration changes
local function displayChangedHandler()
  if not config.get("notch_hider.auto_hide", defaultConfig.auto_hide) then
    return
  end

  local newNotchScreen = getNotchScreen()
  if isActive and newNotchScreen ~= notchScreen then
    log:i("Display configuration changed, updating notch hider")
    removeNotchCover()
    notchScreen = newNotchScreen
    if notchScreen then
      createNotchCover()
    else
      isActive = false
      log:w("Notch display no longer available")
    end
  end
end

-- Initialize module
function M.init()
  log:i("Initializing notch hider module")

  -- Load hotkey configuration
  local hotkeys = require("config.hotkeys")
  local hotkey = require("hs.hotkey")

  -- Set up display change watcher
  if screenWatcher then
    screenWatcher:stop()
    screenWatcher = nil
  end
  screenWatcher = hs.screen.watcher.new(displayChangedHandler)
  screenWatcher:start()

  -- Set up toggle hotkey
  if hotkeys.hotkeys.notch_hider and hotkeys.hotkeys.notch_hider.toggle then
    local hotkeyConfig = hotkeys.hotkeys.notch_hider.toggle
    log:i("Registering notch hider hotkey: " .. table.concat(hotkeyConfig, "+"))

    -- hotkey.bind expects modifiers as first argument, key as second
    local modifiers = {}
    local key = nil

    for i, v in ipairs(hotkeyConfig) do
      if i < #hotkeyConfig then
        table.insert(modifiers, v)
      else
        key = v
      end
    end

    hotkey.bind(modifiers, key, function()
      log:i("Notch hider hotkey triggered!")
      M.toggle()
    end)
    log:i("Notch hider toggle hotkey registered successfully")
  else
    log:e("Notch hider hotkey configuration not found - using fallback")
    -- Try to register with hardcoded keybinding as fallback
    hotkey.bind({"ctrl", "alt"}, "N", function()
      log:i("Fallback notch hider hotkey triggered!")
      M.toggle()
    end)
    log:i("Fallback notch hider hotkey registered")
  end

  -- Auto-enable if configured
  if config.get("notch_hider.enabled", defaultConfig.enabled) then
    log:i("Auto-enabling notch hider")
    M.show()
  end

  log:i("Notch hider module initialized")
end

-- Cleanup module
function M.cleanup()
  log:d("Cleaning up notch hider module")
  removeNotchCover()
  isActive = false
  notchScreen = nil
  if screenWatcher then
    screenWatcher:stop()
    screenWatcher = nil
  end
end

-- Initialize the module immediately when loaded
M.init()

return M