-- Window utilities for Hammerspoon
-- Provides functions for window manipulation and management

local logger = require("core.logger")
local display_utils = require("utils.display_utils")
local log = logger.getLogger("window_utils")

local M = {}

-- Table to store original window frames for restore functionality
local original_frames = {}

-- Get focused window with safety checks
function M.getFocusedWindow()
    local win = hs.window.focusedWindow()
    if not win then
        log.d("No focused window found")
        return nil
    end
    return win
end

-- Get window frame with safety checks
function M.getWindowFrame(win)
    if not win then
        return nil
    end

    local frame = win:frame()
    if not frame then
        log.e("Failed to get window frame")
        return nil
    end

    return frame
end

-- Save original frame for a window
function M.saveOriginalFrame(win)
    if not win then
        return false
    end

    local win_id = win:id()
    local current_frame = M.getWindowFrame(win)

    if win_id and current_frame then
        original_frames[win_id] = current_frame
        log.d(string.format("Saved original frame for window %d", win_id))
        return true
    end

    return false
end

-- Restore original frame for a window
function M.restoreOriginalFrame(win)
    if not win then
        return false
    end

    local win_id = win:id()
    local original_frame = original_frames[win_id]

    if win_id and original_frame then
        win:setFrame(original_frame)
        original_frames[win_id] = nil -- Clear the saved frame
        log.d(string.format("Restored original frame for window %d", win_id))
        return true
    end

    log.w(string.format("No original frame found for window %d", win_id or 0))
    return false
end

-- Set window frame with safety checks
function M.setWindowFrame(win, frame, save_original)
    if not win or not frame then
        return false
    end

    -- Save original frame if requested and not already saved
    if save_original then
        M.saveOriginalFrame(win)
    end

    local success = win:setFrame(frame)
    if success then
        log.d(string.format("Set window frame: x=%.0f, y=%.0f, w=%.0f, h=%.0f",
            frame.x, frame.y, frame.w, frame.h))
    else
        log.e("Failed to set window frame")
    end

    return success
end

-- Move window to half position with edge function behavior
function M.moveWindowToHalf(win, side, cross_display)
    if not win then
        return false
    end

    local current_screen = win:screen()
    local current_frame = M.getWindowFrame(win)
    local screen_frame = display_utils.getScreenFrame(current_screen)

    if not current_screen or not current_frame or not screen_frame then
        return false
    end

    -- Check if window is already at the edge
    local tolerance = 5
    local edge = display_utils.isAtEdge(current_frame, screen_frame, tolerance)
    local all_screens = display_utils.getAllScreens()
    local is_first_screen = current_screen == all_screens[1]
    local is_last_screen = current_screen == all_screens[#all_screens]

    -- Enhanced cross-display logic for horizontal movement only
    if cross_display and (side == "left" or side == "right") then
        if side == "left" and edge.left then
            if is_first_screen then
                -- Edge function: create left half on first screen (no change needed)
                local new_frame = display_utils.getHalfFrame(current_screen, "left")
                if new_frame then
                    return M.setWindowFrame(win, new_frame, true)
                end
            else
                -- Move to previous display's right half
                local prev_screen = display_utils.getPreviousScreen(current_screen)
                if prev_screen then
                    -- Preserve vertical position from current window
                    local new_frame = display_utils.getHalfFrame(prev_screen, "right")
                    if new_frame then
                        return M.setWindowFrame(win, new_frame, true)
                    end
                end
            end
            return false
        elseif side == "right" and edge.right then
            if is_last_screen then
                -- Edge function: create right half on last screen (no change needed)
                local new_frame = display_utils.getHalfFrame(current_screen, "right")
                if new_frame then
                    return M.setWindowFrame(win, new_frame, true)
                end
            else
                -- Move to next display's left half
                local next_screen = display_utils.getNextScreen(current_screen)
                if next_screen then
                    -- Preserve vertical position from current window
                    local new_frame = display_utils.getHalfFrame(next_screen, "left")
                    if new_frame then
                        return M.setWindowFrame(win, new_frame, true)
                    end
                end
            end
            return false
        end
    end

    -- Regular half screen movement
    local new_frame = display_utils.getHalfFrame(current_screen, side)
    if new_frame then
        return M.setWindowFrame(win, new_frame, true)
    end

    return false
end

-- Move window to quarter position with edge function behavior
function M.moveWindowToQuarter(win, quarter, cross_display)
    if not win then
        return false
    end

    local current_screen = win:screen()
    local current_frame = M.getWindowFrame(win)
    local screen_frame = display_utils.getScreenFrame(current_screen)

    if not current_screen or not current_frame or not screen_frame then
        return false
    end

    -- Check current position for contextual movement
    local tolerance = 5
    local edge = display_utils.isAtEdge(current_frame, screen_frame, tolerance)
    local all_screens = display_utils.getAllScreens()
    local is_first_screen = current_screen == all_screens[1]
    local is_last_screen = current_screen == all_screens[#all_screens]

    -- Enhanced cross-display logic with edge functions
    if cross_display and (quarter == "left" or quarter == "right") then
        if quarter == "left" and edge.left then
            if is_first_screen then
                -- Edge function: create left half on first screen (instead of quarter)
                local new_frame = display_utils.getHalfFrame(current_screen, "left")
                if new_frame then
                    return M.setWindowFrame(win, new_frame, true)
                end
            else
                -- Move to previous display with context preservation
                local prev_screen = display_utils.getPreviousScreen(current_screen)
                if prev_screen then
                    -- Determine target quarter on previous display based on current vertical position
                    local target_quarter = edge.top and "topright" or "bottomright"
                    local new_frame = display_utils.getQuarterFrame(prev_screen, target_quarter)
                    if new_frame then
                        return M.setWindowFrame(win, new_frame, true)
                    end
                end
            end
            return false
        elseif quarter == "right" and edge.right then
            if is_last_screen then
                -- Edge function: create right half on last screen (instead of quarter)
                local new_frame = display_utils.getHalfFrame(current_screen, "right")
                if new_frame then
                    return M.setWindowFrame(win, new_frame, true)
                end
            else
                -- Move to next display with context preservation
                local next_screen = display_utils.getNextScreen(current_screen)
                if next_screen then
                    -- Determine target quarter on next display based on current vertical position
                    local target_quarter = edge.top and "topleft" or "bottomleft"
                    local new_frame = display_utils.getQuarterFrame(next_screen, target_quarter)
                    if new_frame then
                        return M.setWindowFrame(win, new_frame, true)
                    end
                end
            end
            return false
        end
    end

    -- Regular quarter screen movement
    local new_frame = display_utils.getQuarterFrame(current_screen, quarter)
    if new_frame then
        return M.setWindowFrame(win, new_frame, true)
    end

    return false
end

-- Maximize window
function M.maximizeWindow(win)
    if not win then
        return false
    end

    local screen = win:screen()
    local screen_frame = display_utils.getScreenFrame(screen)

    if screen_frame then
        return M.setWindowFrame(win, screen_frame, true)
    end

    return false
end

-- Center window (80% of screen size)
function M.centerWindow(win)
    if not win then
        return false
    end

    local screen = win:screen()
    local screen_frame = display_utils.getScreenFrame(screen)

    if screen_frame then
        local new_frame = {
            x = screen_frame.x + screen_frame.w * 0.1,
            y = screen_frame.y + screen_frame.h * 0.1,
            w = screen_frame.w * 0.8,
            h = screen_frame.h * 0.8
        }
        return M.setWindowFrame(win, new_frame, true)
    end

    return false
end

-- Get window information for debugging
function M.getWindowInfo(win)
    if not win then
        return nil
    end

    local frame = M.getWindowFrame(win)
    local screen = win:screen()
    local screen_frame = display_utils.getScreenFrame(screen)

    return {
        id = win:id(),
        title = win:title(),
        application = win:application():name(),
        frame = frame,
        screen = screen and screen:name() or "Unknown",
        is_fullscreen = win:isFullScreen(),
        is_minimized = win:isMinimized(),
        is_visible = win:isVisible()
    }
end

-- List all visible windows
function M.listVisibleWindows()
    local windows = hs.window.visibleWindows()
    local window_list = {}

    for _, win in ipairs(windows) do
        table.insert(window_list, M.getWindowInfo(win))
    end

    return window_list
end

-- Clean up original frames storage (for memory management)
function M.cleanupOriginalFrames()
    local current_windows = hs.window.allWindows()
    local current_ids = {}

    -- Get current window IDs
    for _, win in ipairs(current_windows) do
        local win_id = win:id()
        if win_id then
            current_ids[win_id] = true
        end
    end

    -- Remove frames for closed windows
    local count = 0
    for win_id, _ in pairs(original_frames) do
        if not current_ids[win_id] then
            original_frames[win_id] = nil
            count = count + 1
        end
    end

    if count > 0 then
        log.d(string.format("Cleaned up %d saved window frames", count))
    end
end

-- Get saved original frames (for debugging)
function M.getSavedOriginalFrames()
    local frames = {}
    for win_id, frame in pairs(original_frames) do
        frames[win_id] = frame
    end
    return frames
end

-- Enhanced cross-display movement functions
-- Move window to next display with context preservation
function M.moveToNextDisplayContext(win)
    if not win then
        return false
    end

    local current_screen = win:screen()
    local current_frame = M.getWindowFrame(win)
    if not current_screen or not current_frame then
        return false
    end

    local next_screen = display_utils.getNextScreen(current_screen)
    if not next_screen then
        return false
    end

    -- Preserve vertical position from current window
    local next_screen_frame = display_utils.getScreenFrame(next_screen)
    if not next_screen_frame then
        return false
    end

    local new_frame = {
        x = next_screen_frame.x,
        y = current_frame.y,  -- Preserve vertical position
        w = next_screen_frame.w / 2,
        h = current_frame.h   -- Preserve height
    }

    return M.setWindowFrame(win, new_frame, true)
end

-- Move window to previous display with context preservation
function M.moveToPreviousDisplayContext(win)
    if not win then
        return false
    end

    local current_screen = win:screen()
    local current_frame = M.getWindowFrame(win)
    if not current_screen or not current_frame then
        return false
    end

    local prev_screen = display_utils.getPreviousScreen(current_screen)
    if not prev_screen then
        return false
    end

    -- Preserve vertical position from current window
    local prev_screen_frame = display_utils.getScreenFrame(prev_screen)
    if not prev_screen_frame then
        return false
    end

    local new_frame = {
        x = prev_screen_frame.x + prev_screen_frame.w / 2,
        y = current_frame.y,  -- Preserve vertical position
        w = prev_screen_frame.w / 2,
        h = current_frame.h   -- Preserve height
    }

    return M.setWindowFrame(win, new_frame, true)
end

-- Move window to next display quarter with context preservation
function M.moveToNextDisplayQuarterContext(win, target_quarter)
    if not win then
        return false
    end

    local current_screen = win:screen()
    local all_screens = display_utils.getAllScreens()

    -- Check if we're at the last screen
    if current_screen == all_screens[#all_screens] then
        -- Edge function: create half-screen instead
        local current_frame = display_utils.getScreenFrame(current_screen)
        if current_frame then
            local new_frame = {
                x = current_frame.x + current_frame.w / 2,
                y = current_frame.y,
                w = current_frame.w / 2,
                h = current_frame.h
            }
            return M.setWindowFrame(win, new_frame, true)
        end
        return false
    end

    local next_screen = display_utils.getNextScreen(current_screen)
    if not next_screen then
        return false
    end

    local new_frame = display_utils.getQuarterFrame(next_screen, target_quarter)
    if new_frame then
        return M.setWindowFrame(win, new_frame, true)
    end

    return false
end

-- Move window to previous display quarter with context preservation
function M.moveToPreviousDisplayQuarterContext(win, target_quarter)
    if not win then
        return false
    end

    local current_screen = win:screen()
    local all_screens = display_utils.getAllScreens()

    -- Check if we're at the first screen
    if current_screen == all_screens[1] then
        -- Edge function: create half-screen instead
        local current_frame = display_utils.getScreenFrame(current_screen)
        if current_frame then
            local new_frame = {
                x = current_frame.x,
                y = current_frame.y,
                w = current_frame.w / 2,
                h = current_frame.h
            }
            return M.setWindowFrame(win, new_frame, true)
        end
        return false
    end

    local prev_screen = display_utils.getPreviousScreen(current_screen)
    if not prev_screen then
        return false
    end

    local new_frame = display_utils.getQuarterFrame(prev_screen, target_quarter)
    if new_frame then
        return M.setWindowFrame(win, new_frame, true)
    end

    return false
end

return M