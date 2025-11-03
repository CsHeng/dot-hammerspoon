-- Display utilities for Hammerspoon
-- Provides functions for multi-monitor display management

local logger = require("core.logger")
local log = logger.getLogger("display_utils")

local M = {}

local function sortScreensLeftToRight(screens)
    if not screens then
        return {}
    end

    table.sort(screens, function(a, b)
        local a_frame = a:frame()
        local b_frame = b:frame()

        if not a_frame or not b_frame then
            return (a:id() or 0) < (b:id() or 0)
        end

        if a_frame.x == b_frame.x then
            return a_frame.y < b_frame.y
        end

        return a_frame.x < b_frame.x
    end)

    return screens
end

local function findScreenIndex(screens, target)
    for index, screen in ipairs(screens) do
        if screen == target then
            return index
        end
    end
    return nil
end

-- Get all screens in order
function M.getAllScreens()
    local screens = hs.screen.allScreens()
    if not screens or #screens == 0 then
        return {}
    end

    return sortScreensLeftToRight(screens)
end

-- Get main screen
function M.getMainScreen()
    return hs.screen.mainScreen()
end

-- Get current screen for focused window
function M.getCurrentScreen()
    local win = hs.window.focusedWindow()
    if not win then
        return M.getMainScreen()
    end
    return win:screen()
end

-- Get next screen in order
function M.getNextScreen(current_screen)
    if not current_screen then
        current_screen = M.getCurrentScreen()
    end

    if not current_screen then
        return nil
    end

    local all_screens = M.getAllScreens()
    if #all_screens <= 1 then
        return nil
    end

    local current_index = findScreenIndex(all_screens, current_screen)
    if not current_index then
        return nil
    end

    if current_index >= #all_screens then
        return nil -- Already at right-most screen, do not wrap
    end

    return all_screens[current_index + 1]
end

-- Get previous screen in order
function M.getPreviousScreen(current_screen)
    if not current_screen then
        current_screen = M.getCurrentScreen()
    end

    if not current_screen then
        return nil
    end

    local all_screens = M.getAllScreens()
    if #all_screens <= 1 then
        return nil
    end

    local current_index = findScreenIndex(all_screens, current_screen)
    if not current_index then
        return nil
    end

    if current_index <= 1 then
        return nil -- Already at left-most screen, do not wrap
    end

    return all_screens[current_index - 1]
end

-- Get screen frame with safety checks
function M.getScreenFrame(screen)
    if not screen then
        screen = M.getCurrentScreen()
    end

    local frame = screen:frame()
    if not frame then
        log.e("Failed to get screen frame")
        return nil
    end

    return frame
end

-- Calculate half frame for a screen
function M.getHalfFrame(screen, side)
    local frame = M.getScreenFrame(screen)
    if not frame then
        return nil
    end

    if side == "left" then
        return {
            x = frame.x,
            y = frame.y,
            w = frame.w / 2,
            h = frame.h
        }
    elseif side == "right" then
        return {
            x = frame.x + frame.w / 2,
            y = frame.y,
            w = frame.w / 2,
            h = frame.h
        }
    elseif side == "top" then
        return {
            x = frame.x,
            y = frame.y,
            w = frame.w,
            h = frame.h / 2
        }
    elseif side == "bottom" then
        return {
            x = frame.x,
            y = frame.y + frame.h / 2,
            w = frame.w,
            h = frame.h / 2
        }
    end

    log.w(string.format("Invalid side for half frame: %s", side))
    return nil
end

-- Calculate quarter frame for a screen
function M.getQuarterFrame(screen, quarter)
    local frame = M.getScreenFrame(screen)
    if not frame then
        return nil
    end

    local half_width = frame.w / 2
    local half_height = frame.h / 2

    if quarter == "topleft" then
        return {
            x = frame.x,
            y = frame.y,
            w = half_width,
            h = half_height
        }
    elseif quarter == "topright" then
        return {
            x = frame.x + half_width,
            y = frame.y,
            w = half_width,
            h = half_height
        }
    elseif quarter == "bottomleft" then
        return {
            x = frame.x,
            y = frame.y + half_height,
            w = half_width,
            h = half_height
        }
    elseif quarter == "bottomright" then
        return {
            x = frame.x + half_width,
            y = frame.y + half_height,
            w = half_width,
            h = half_height
        }
    end

    log.w(string.format("Invalid quarter for quarter frame: %s", quarter))
    return nil
end

-- Check if a position is at the edge of a frame with tolerance
function M.isAtEdge(current_frame, screen_frame, tolerance)
    tolerance = tolerance or 5

    return {
        left = math.abs(current_frame.x - screen_frame.x) < tolerance,
        right = math.abs((current_frame.x + current_frame.w) - (screen_frame.x + screen_frame.w)) < tolerance,
        top = math.abs(current_frame.y - screen_frame.y) < tolerance,
        bottom = math.abs((current_frame.y + current_frame.h) - (screen_frame.y + screen_frame.h)) < tolerance
    }
end

-- Get screen information for debugging
function M.getScreenInfo()
    local screens = M.getAllScreens()
    local info = {}

    for i, screen in ipairs(screens) do
        local frame = screen:frame()
        table.insert(info, {
            index = i,
            name = screen:name(),
            frame = frame,
            is_main = screen == M.getMainScreen()
        })
    end

    return info
end

-- Print screen layout for debugging
function M.printScreenLayout()
    local info = M.getScreenInfo()
    log.i("Screen layout:")

    for _, screen_info in ipairs(info) do
        local main_mark = screen_info.is_main and " (Main)" or ""
        log.i(string.format("  Screen %d%s: %s at (%.0f, %.0f) %.0fx%.0f",
            screen_info.index, main_mark, screen_info.name or "Unknown",
            screen_info.frame.x, screen_info.frame.y,
            screen_info.frame.w, screen_info.frame.h))
    end
end

return M
