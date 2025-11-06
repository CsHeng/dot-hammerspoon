-- Window Management Module for Hammerspoon
-- Provides Magnet-style window management with keyboard shortcuts
-- Refactored to use utility modules and eliminate duplicate code

local logger = require("core.logger")
local config = require("core.config_loader")
local display_utils = require("utils.display_utils")
local window_utils = require("utils.window_utils")

local log = logger.getLogger("window_management")

local M = {}

-- Get configuration values
local function getHotkey(path)
    return config.get("hotkeys." .. path)
end

local function getVisualConfig(path)
    return config.get("visual." .. path)
end

-- Initialize window management
function M.init()
    log.i("Initializing window management module")

    -- Setup hotkeys
    M.setupHotkeys()

    -- Setup periodic cleanup
    M.setupCleanup()

    log.i("Window management module initialized")
end

-- Setup all window management hotkeys
function M.setupHotkeys()
    -- Half screen positioning
    M.setupHalfScreenHotkeys()

    -- Quarter screen positioning
    M.setupQuarterScreenHotkeys()

    -- Special positioning
    M.setupSpecialPositioningHotkeys()

    log.i("Window management hotkeys configured")
end

-- Setup half screen positioning hotkeys
function M.setupHalfScreenHotkeys()
    local hyper = getHotkey("window.hyper") or {"ctrl", "alt"}

    -- Basic half positions without announcement overlay for responsiveness
    hs.hotkey.bind(hyper, "left", function()
        M.moveWindowHalf("left")
    end)

    hs.hotkey.bind(hyper, "right", function()
        M.moveWindowHalf("right")
    end)

    hs.hotkey.bind(hyper, "up", function()
        M.moveWindowHalf("top")
    end)

    hs.hotkey.bind(hyper, "down", function()
        M.moveWindowHalf("bottom")
    end)
end

-- Setup quarter screen positioning hotkeys
function M.setupQuarterScreenHotkeys()
    local hyper_shift = getHotkey("window.hyper_shift") or {"ctrl", "alt", "shift"}

    -- Quarter positions with contextual movement
    hs.hotkey.bind(hyper_shift, "left", function()
        M.moveWindowQuarter("left")
    end)

    hs.hotkey.bind(hyper_shift, "right", function()
        M.moveWindowQuarter("right")
    end)

    hs.hotkey.bind(hyper_shift, "up", function()
        M.moveWindowQuarter("up")
    end)

    hs.hotkey.bind(hyper_shift, "down", function()
        M.moveWindowQuarter("down")
    end)
end

-- Setup special positioning hotkeys
function M.setupSpecialPositioningHotkeys()
    local hyper = getHotkey("window.hyper") or {"ctrl", "alt"}

    -- Maximize, center, original
    hs.hotkey.bind(hyper, "return", function()
        M.maximizeWindow()
    end)

    hs.hotkey.bind(hyper, "c", function()
        M.centerWindow()
    end)

    hs.hotkey.bind(hyper, "o", function()
        M.restoreOriginalWindow()
    end)
end

-- Move window to half position
function M.moveWindowHalf(direction)
    local win = window_utils.getFocusedWindow()
    if not win then
        log.d("No focused window for half positioning")
        return
    end

    local success = window_utils.moveWindowToHalf(win, direction, true)
    if success then
        log.i(string.format("Moved window to %s half", direction))
    else
        log.w(string.format("Failed to move window to %s half", direction))
    end
end

-- Move window to quarter position with proper contextual behavior
function M.moveWindowQuarter(direction)
    local win = window_utils.getFocusedWindow()
    if not win then
        log.d("No focused window for quarter positioning")
        return
    end

    local current_frame = window_utils.getWindowFrame(win)
    if not current_frame then
        log.w("Could not get window frame for quarter positioning")
        return
    end

    local current_screen = win:screen()
    local screen_frame = display_utils.getScreenFrame(current_screen)
    if not screen_frame then
        log.w("Could not get screen frame for quarter positioning")
        return
    end

    -- Determine current quarter position with precise tolerance logic
    local tolerance = 10
    local isLeftSide = math.abs(current_frame.x - screen_frame.x) < tolerance
    local isRightSide = math.abs(current_frame.x - (screen_frame.x + screen_frame.w / 2)) < tolerance
    local isTopSide = math.abs(current_frame.y - screen_frame.y) < tolerance
    local isBottomSide = math.abs(current_frame.y - (screen_frame.y + screen_frame.h / 2)) < tolerance

    -- Contextual quarter movement logic - create frame directly
    local new_frame = {}

    if direction == "left" then
        if isLeftSide then
            -- Currently at left edge, try to move to previous display
            local target_quarter = isTopSide and "topright" or "bottomright"
            local success = window_utils.moveToPreviousDisplayQuarterContext(win, target_quarter)
            if success then
                log.i(string.format("Cross-display quarter movement: %s", target_quarter))
            else
                log.d("No previous display available, no movement")
            end
            return
        else
            -- Move to left side within current display
            new_frame = {
                x = screen_frame.x,
                y = isTopSide and screen_frame.y or screen_frame.y + screen_frame.h / 2,
                w = screen_frame.w / 2,
                h = screen_frame.h / 2
            }
        end
    elseif direction == "right" then
        if isRightSide then
            -- Currently at right edge, try to move to next display
            local target_quarter = isTopSide and "topleft" or "bottomleft"
            local success = window_utils.moveToNextDisplayQuarterContext(win, target_quarter)
            if success then
                log.i(string.format("Cross-display quarter movement: %s", target_quarter))
            else
                log.d("No next display available, no movement")
            end
            return
        else
            -- Move to right side within current display
            new_frame = {
                x = screen_frame.x + screen_frame.w / 2,
                y = isTopSide and screen_frame.y or screen_frame.y + screen_frame.h / 2,
                w = screen_frame.w / 2,
                h = screen_frame.h / 2
            }
        end
    elseif direction == "up" then
        log.d(string.format("Up movement: isTopSide=%s, isLeftSide=%s, isRightSide=%s",
            tostring(isTopSide), tostring(isLeftSide), tostring(isRightSide)))
        if isTopSide then
            -- Currently at top edge, do nothing (no vertical cross-display movement)
            -- Don't cycle within same screen either
            log.d("At top edge, no vertical cross-display movement")
            return
        else
            -- Move to top side within current display
            new_frame = {
                x = isLeftSide and screen_frame.x or screen_frame.x + screen_frame.w / 2,
                y = screen_frame.y,
                w = screen_frame.w / 2,
                h = screen_frame.h / 2
            }
            log.d(string.format("Moving up: new_frame={x=%.0f,y=%.0f,w=%.0f,h=%.0f}",
                new_frame.x, new_frame.y, new_frame.w, new_frame.h))
        end
    elseif direction == "down" then
        if isBottomSide then
            -- Currently at bottom edge, do nothing (no vertical cross-display movement)
            -- Don't cycle within same screen either
            log.d("At bottom edge, no vertical cross-display movement")
            return
        else
            -- Move to bottom side within current display
            new_frame = {
                x = isLeftSide and screen_frame.x or screen_frame.x + screen_frame.w / 2,
                y = screen_frame.y + screen_frame.h / 2,
                w = screen_frame.w / 2,
                h = screen_frame.h / 2
            }
        end
    else
        log.e(string.format("Invalid quarter direction: %s", direction))
        return
    end

    -- Set the frame directly
    if new_frame and new_frame.x then
        local success = window_utils.setWindowFrame(win, new_frame, true)
        if success then
            log.i(string.format("Quarter movement successful: direction=%s", direction))
        else
            log.w(string.format("Quarter movement failed: direction=%s", direction))
        end
    else
        log.w(string.format("No frame calculated for quarter movement: direction=%s", direction))
    end
end

-- Maximize window
function M.maximizeWindow()
    local win = window_utils.getFocusedWindow()
    if not win then
        log.d("No focused window for maximize")
        return
    end

    local success = window_utils.maximizeWindow(win)
    if success then
        log.i("Maximized window")
    else
        log.w("Failed to maximize window")
    end
end

-- Center window
function M.centerWindow()
    local win = window_utils.getFocusedWindow()
    if not win then
        log.d("No focused window for center")
        return
    end

    local success = window_utils.centerWindow(win)
    if success then
        log.i("Centered window")
    else
        log.w("Failed to center window")
    end
end

-- Restore window to original position
function M.restoreOriginalWindow()
    local win = window_utils.getFocusedWindow()
    if not win then
        log.d("No focused window for restore")
        return
    end

    local success = window_utils.restoreOriginalFrame(win)
    if success then
        log.i("Restored window to original position")
    else
        log.w("Failed to restore window to original position")
    end
end

-- Move window to next display
function M.moveToNextDisplay()
    local win = window_utils.getFocusedWindow()
    if not win then
        log.d("No focused window for next display")
        return false
    end

    local current_screen = win:screen()
    local next_screen = display_utils.getNextScreen(current_screen)

    if not next_screen then
        log.d("No next display available")
        return false
    end

    local new_frame = display_utils.getHalfFrame(next_screen, "left")
    if new_frame then
        local success = window_utils.setWindowFrame(win, new_frame, true)
        if success then
            log.i("Moved window to next display")
        end
        return success
    end

    return false
end

-- Move window to previous display
function M.moveToPreviousDisplay()
    local win = window_utils.getFocusedWindow()
    if not win then
        log.d("No focused window for previous display")
        return false
    end

    local current_screen = win:screen()
    local prev_screen = display_utils.getPreviousScreen(current_screen)

    if not prev_screen then
        log.d("No previous display available")
        return false
    end

    local new_frame = display_utils.getHalfFrame(prev_screen, "right")
    if new_frame then
        local success = window_utils.setWindowFrame(win, new_frame, true)
        if success then
            log.i("Moved window to previous display")
        end
        return success
    end

    return false
end

-- Setup periodic cleanup
function M.setupCleanup()
    local cleanup_interval = getVisualConfig("window.cleanup_interval") or 300

    -- Cleanup saved frames periodically
    hs.timer.doEvery(cleanup_interval, function()
        window_utils.cleanupOriginalFrames()
    end)

    log.d(string.format("Setup cleanup with interval: %ds", cleanup_interval))
end

-- Compatibility functions for older API
function M.moveWindow(position)
    -- Map position calls to new functions
    if position == "maximize" then
        M.maximizeWindow()
    elseif position == "center" then
        M.centerWindow()
    elseif position == "original" then
        M.restoreOriginalWindow()
    else
        -- Handle half/quarter positions
        local direction_map = {
            left = "left", right = "right", top = "top", bottom = "bottom",
            topleft = "left", topright = "right", bottomleft = "left", bottomright = "right"
        }
        local direction = direction_map[position]
        if direction then
            M.moveWindowHalf(direction)
        else
            log.w(string.format("Position not supported: %s", position))
        end
    end
end

-- Get window management status
function M.getStatus()
    local win = window_utils.getFocusedWindow()
    local screens = display_utils.getAllScreens()
    local saved_frames = window_utils.getSavedOriginalFrames()

    return {
        focused_window = win and true or false,
        window_count = win and 1 or 0,
        screen_count = #screens,
        saved_frames_count = #hs.fnutils.keys(saved_frames),
        main_screen = display_utils.getMainScreen():name()
    }
end

-- Print debugging information
function M.debug()
    local status = M.getStatus()
    local screens = display_utils.getScreenInfo()
    local windows = window_utils.listVisibleWindows()

    log.i("Window Management Debug Info:")
    log.i(string.format("  Screens: %d", status.screen_count))
    log.i(string.format("  Main screen: %s", status.main_screen))
    log.i(string.format("  Saved frames: %d", status.saved_frames_count))

    for _, screen_info in ipairs(screens) do
        log.i(string.format("  Screen %d: %s (%.0fx%.0f at %.0f,%.0f)",
            screen_info.index, screen_info.name,
            screen_info.frame.w, screen_info.frame.h,
            screen_info.frame.x, screen_info.frame.y))
    end

    if #windows > 0 then
        log.i("  Visible windows:")
        for _, win_info in ipairs(windows) do
            log.i(string.format("    %s (%s)", win_info.title or "Untitled", win_info.application))
        end
    end
end

-- Register module with init system
local init_system = require("core.init_system")
init_system.registerModule("modules.window_management", {
    init = M.init,
    dependencies = {
        "utils.display_utils",
        "utils.window_utils"
    }
})

return M
