-- Hammerspoon Magnet Window Manager Script

-- https://www.hammerspoon.org/Spoons/WinWin.html

-- Table to store original window frames for restore functionality
local originalFrames = {}

-- Bind hotkeys to window management actions
local hyper = {"ctrl", "alt"} -- Define a hyper key combination
-- local super = {"ctrl", "cmd", "alt"} -- Define a super key combination

-- Basic Half Positions with consistent arrow logic
hs.hotkey.bind(hyper, "left", function() moveWindowHalf("left") end)      -- Left Half
hs.hotkey.bind(hyper, "right", function() moveWindowHalf("right") end)    -- Right Half
hs.hotkey.bind(hyper, "up", function() moveWindowHalf("top") end)         -- Top Half
hs.hotkey.bind(hyper, "down", function() moveWindowHalf("bottom") end)      -- Bottom Half

-- Quarter Positions with ctrl+alt+shift+arrows
-- Contextual movement within current screen
local hyperShift = {"ctrl", "alt", "shift"}
hs.hotkey.bind(hyperShift, "left", function() moveWindowQuarter("left") end)        -- Left side (cycle top/bottom)
hs.hotkey.bind(hyperShift, "right", function() moveWindowQuarter("right") end)      -- Right side (cycle top/bottom)
hs.hotkey.bind(hyperShift, "up", function() moveWindowQuarter("up") end)           -- Top side (cycle left/right)
hs.hotkey.bind(hyperShift, "down", function() moveWindowQuarter("down") end)        -- Bottom side (cycle left/right)

-- Maximize, Center, Original
hs.hotkey.bind(hyper, "return", function() moveWindow("maximize") end)   -- Maximize
hs.hotkey.bind(hyper, "c", function() moveWindow("center") end)          -- Center
hs.hotkey.bind(hyper, "o", function() moveWindow("original") end)        -- Original

-- -- Thirds
-- hs.hotkey.bind(hyper, "d", function() moveWindow("leftthird") end)    -- Left Third
-- hs.hotkey.bind(hyper, "f", function() moveWindow("centerthird") end)  -- Center Third
-- hs.hotkey.bind(hyper, "g", function() moveWindow("rightthird") end)   -- Right Third

-- -- Two Thirds
-- hs.hotkey.bind(hyper, "e", function() moveWindow("lefttwothirds") end)   -- Left Two Thirds
-- hs.hotkey.bind(hyper, "r", function() moveWindow("centertwothirds") end) -- Center Two Thirds
-- hs.hotkey.bind(hyper, "t", function() moveWindow("righttwothirds") end)  -- Right Two Thirds

-- -- Display Navigation
-- hs.hotkey.bind(super, "left", function() moveToPreviousDisplay() end) -- Previous Display
-- hs.hotkey.bind(super, "right", function() moveToNextDisplay() end)    -- Next Display

-- Function to move window to half positions with proper half-screen behavior
function moveWindowHalf(direction)
    local win = hs.window.focusedWindow()
    if not win then return end

    local screen = win:screen()
    local rect = screen:frame()
    local currentFrame = win:frame()
    local winId = win:id()

    -- Save original frame if this is the first move operation for this window
    if not originalFrames[winId] then
        originalFrames[winId] = currentFrame
    end

    local newFrame = {}
    local tolerance = 5 -- pixels tolerance for position detection

    if direction == "left" then
        -- Check if window is already at the left edge (left half)
        if math.abs(currentFrame.x - rect.x) < tolerance and math.abs(currentFrame.w - rect.w / 2) < tolerance then
            -- Window is already left half, move to previous display's right half
            if not moveToPreviousDisplay() then
                -- Edge case: create left half on current screen (does nothing since already there)
                return
            end
        else
            -- Move to left half on current screen
            newFrame = {x = rect.x, y = rect.y, w = rect.w / 2, h = rect.h}
        end
    elseif direction == "right" then
        -- Check if window is already at the right edge (right half)
        if math.abs(currentFrame.x - (rect.x + rect.w / 2)) < tolerance and math.abs(currentFrame.w - rect.w / 2) < tolerance then
            -- Window is already right half, move to next display's left half
            if not moveToNextDisplayHalf() then
                -- Edge case: create right half on current screen (does nothing since already there)
                return
            end
        else
            -- Move to right half on current screen
            newFrame = {x = rect.x + rect.w / 2, y = rect.y, w = rect.w / 2, h = rect.h}
        end
    elseif direction == "top" then
        newFrame = {x = rect.x, y = rect.y, w = rect.w, h = rect.h / 2}
    elseif direction == "bottom" then
        newFrame = {x = rect.x, y = rect.y + rect.h / 2, w = rect.w, h = rect.h / 2}
    end

    if newFrame and not (newFrame.x == nil) then
        win:setFrame(newFrame)
    end
end

-- Function to move window to quarter positions with contextual movement and cross-display support
function moveWindowQuarter(direction)
    local win = hs.window.focusedWindow()
    if not win then return end

    local screen = win:screen()
    local rect = screen:frame()
    local currentFrame = win:frame()
    local winId = win:id()

    -- Save original frame if this is the first move operation for this window
    if not originalFrames[winId] then
        originalFrames[winId] = currentFrame
    end

    local newFrame = {}
    local tolerance = 10 -- pixels tolerance for position detection

    -- Determine current quarter position
    local isLeftSide = math.abs(currentFrame.x - rect.x) < tolerance
    local isRightSide = math.abs(currentFrame.x - (rect.x + rect.w / 2)) < tolerance
    local isTopSide = math.abs(currentFrame.y - rect.y) < tolerance
    local isBottomSide = math.abs(currentFrame.y - (rect.y + rect.h / 2)) < tolerance

    if direction == "left" then
        if isLeftSide then
            -- Currently at left edge, try to move to previous display
            local targetPos = isTopSide and "topright" or "bottomright"
            moveToPreviousDisplayQuarterContext(targetPos)
            -- If no previous display, do nothing (don't cycle within same screen)
        else
            -- Move to left side within current display
            newFrame = {x = rect.x, y = isTopSide and rect.y or rect.y + rect.h / 2, w = rect.w / 2, h = rect.h / 2}
        end
    elseif direction == "right" then
        if isRightSide then
            -- Currently at right edge, try to move to next display
            local targetPos = isTopSide and "topleft" or "bottomleft"
            moveToNextDisplayQuarterContext(targetPos)
            -- If no next display, do nothing (don't cycle within same screen)
        else
            -- Move to right side within current display
            newFrame = {x = rect.x + rect.w / 2, y = isTopSide and rect.y or rect.y + rect.h / 2, w = rect.w / 2, h = rect.h / 2}
        end
    elseif direction == "up" then
        if isTopSide then
            -- Currently at top edge, do nothing (no vertical cross-display movement)
            -- Don't cycle within same screen either
        else
            -- Move to top side within current display
            newFrame = {x = isLeftSide and rect.x or rect.x + rect.w / 2, y = rect.y, w = rect.w / 2, h = rect.h / 2}
        end
    elseif direction == "down" then
        if isBottomSide then
            -- Currently at bottom edge, do nothing (no vertical cross-display movement)
            -- Don't cycle within same screen either
        else
            -- Move to bottom side within current display
            newFrame = {x = isLeftSide and rect.x or rect.x + rect.w / 2, y = rect.y + rect.h / 2, w = rect.w / 2, h = rect.h / 2}
        end
    end

    if newFrame and not (newFrame.x == nil) then
        win:setFrame(newFrame)
    end
end

-- Function to move and resize window (legacy function for other actions)
function moveWindow(position)
    local win = hs.window.focusedWindow()
    if not win then return end

    local screen = win:screen()
    local rect = screen:frame()
    local currentFrame = win:frame()
    local newFrame = {}

    -- Save original frame if this is the first move operation for this window
    local winId = win:id()
    if not originalFrames[winId] and position ~= "original" then
        originalFrames[winId] = currentFrame
    end

    if position == "left" then
        -- Check if window is already at the left edge
        if math.abs(currentFrame.x - rect.x) < 5 and math.abs(currentFrame.w - rect.w / 2) < 5 then
            -- Window is already left half, move to previous display right half
            moveToPreviousDisplay()
            return
        end
        newFrame = {x = rect.x, y = rect.y, w = rect.w / 2, h = rect.h}
    elseif position == "right" then
        -- Check if window is already at the right edge
        if math.abs(currentFrame.x - (rect.x + rect.w / 2)) < 5 and math.abs(currentFrame.w - rect.w / 2) < 5 then
            -- Window is already right half, move to next display left half
            moveToNextDisplay()
            return
        end
        newFrame = {x = rect.x + rect.w / 2, y = rect.y, w = rect.w / 2, h = rect.h}
    elseif position == "top" then
        newFrame = {x = rect.x, y = rect.y, w = rect.w, h = rect.h / 2}
    elseif position == "bottom" then
        newFrame = {x = rect.x, y = rect.y + rect.h / 2, w = rect.w, h = rect.h / 2}
    elseif position == "topleft" then
        -- Check if window is already at the top left corner
        if math.abs(currentFrame.x - rect.x) < 5 and math.abs(currentFrame.y - rect.y) < 5 and
           math.abs(currentFrame.w - rect.w / 2) < 5 and math.abs(currentFrame.h - rect.h / 2) < 5 then
            -- Window is already top left quarter, move to previous display top right quarter
            moveToPreviousDisplayQuarter("topright")
            return
        end
        newFrame = {x = rect.x, y = rect.y, w = rect.w / 2, h = rect.h / 2}
    elseif position == "topright" then
        -- Check if window is already at the top right corner
        if math.abs(currentFrame.x - (rect.x + rect.w / 2)) < 5 and math.abs(currentFrame.y - rect.y) < 5 and
           math.abs(currentFrame.w - rect.w / 2) < 5 and math.abs(currentFrame.h - rect.h / 2) < 5 then
            -- Window is already top right quarter, move to next display top left quarter
            moveToNextDisplayQuarter("topleft")
            return
        end
        newFrame = {x = rect.x + rect.w / 2, y = rect.y, w = rect.w / 2, h = rect.h / 2}
    elseif position == "bottomleft" then
        -- Check if window is already at the bottom left corner
        if math.abs(currentFrame.x - rect.x) < 5 and math.abs(currentFrame.y - (rect.y + rect.h / 2)) < 5 and
           math.abs(currentFrame.w - rect.w / 2) < 5 and math.abs(currentFrame.h - rect.h / 2) < 5 then
            -- Window is already bottom left quarter, move to previous display bottom right quarter
            moveToPreviousDisplayQuarter("bottomright")
            return
        end
        newFrame = {x = rect.x, y = rect.y + rect.h / 2, w = rect.w / 2, h = rect.h / 2}
    elseif position == "bottomright" then
        -- Check if window is already at the bottom right corner
        if math.abs(currentFrame.x - (rect.x + rect.w / 2)) < 5 and math.abs(currentFrame.y - (rect.y + rect.h / 2)) < 5 and
           math.abs(currentFrame.w - rect.w / 2) < 5 and math.abs(currentFrame.h - rect.h / 2) < 5 then
            -- Window is already bottom right quarter, move to next display bottom left quarter
            moveToNextDisplayQuarter("bottomleft")
            return
        end
        newFrame = {x = rect.x + rect.w / 2, y = rect.y + rect.h / 2, w = rect.w / 2, h = rect.h / 2}
    elseif position == "leftthird" then
        newFrame = {x = rect.x, y = rect.y, w = rect.w / 3, h = rect.h}
    elseif position == "centerthird" then
        newFrame = {x = rect.x + rect.w / 3, y = rect.y, w = rect.w / 3, h = rect.h}
    elseif position == "rightthird" then
        newFrame = {x = rect.x + 2 * rect.w / 3, y = rect.y, w = rect.w / 3, h = rect.h}
    elseif position == "lefttwothirds" then
        newFrame = {x = rect.x, y = rect.y, w = 2 * rect.w / 3, h = rect.h}
    elseif position == "centertwothirds" then
        newFrame = {x = rect.x + rect.w / 3, y = rect.y, w = 2 * rect.w / 3, h = rect.h}
    elseif position == "righttwothirds" then
        newFrame = {x = rect.x + rect.w / 3, y = rect.y, w = 2 * rect.w / 3, h = rect.h}
    elseif position == "maximize" then
        newFrame = rect
    elseif position == "center" then
        newFrame = {x = rect.x + rect.w * 0.1, y = rect.y + rect.h * 0.1, w = rect.w * 0.8, h = rect.h * 0.8}
    elseif position == "original" then
        -- Restore to original frame if available
        if originalFrames[winId] then
            win:setFrame(originalFrames[winId])
            originalFrames[winId] = nil  -- Clear the saved frame after restoring
        end
        return
    end

    win:setFrame(newFrame)
end

-- Function to move window to next/previous display
function moveToNextDisplay()
    local win = hs.window.focusedWindow()
    if not win then return false end

    local currentScreen = win:screen()
    local nextScreen = currentScreen:next()

    -- Don't cycle - if we're at the last screen, return false
    if not nextScreen or nextScreen == hs.screen.allScreens()[1] then
        return false
    end

    local nextRect = nextScreen:frame()
    -- Calculate left half position on the next screen directly
    local newFrame = {
        x = nextRect.x,
        y = nextRect.y,
        w = nextRect.w / 2,
        h = nextRect.h
    }

    win:setFrame(newFrame)
    return true
end

function moveToPreviousDisplay()
    local win = hs.window.focusedWindow()
    if not win then return false end

    local currentScreen = win:screen()
    local prevScreen = currentScreen:previous()

    -- Don't cycle - if we're at the first screen, return false
    local allScreens = hs.screen.allScreens()
    if not prevScreen or prevScreen == allScreens[#allScreens] then
        return false
    end

    local prevRect = prevScreen:frame()
    -- Calculate right half position on the previous screen directly
    local newFrame = {
        x = prevRect.x + prevRect.w / 2,
        y = prevRect.y,
        w = prevRect.w / 2,
        h = prevRect.h
    }

    win:setFrame(newFrame)
    return true
end

-- Function to move window to next display with quarter positioning
function moveToNextDisplayQuarter(position)
    local win = hs.window.focusedWindow()
    if not win then return end

    local currentScreen = win:screen()
    local nextScreen = currentScreen:next()

    -- Don't cycle - if we're at the last screen, do nothing
    if not nextScreen or nextScreen == hs.screen.allScreens()[1] then
        return
    end

    local nextRect = nextScreen:frame()
    local newFrame = {}

    if position == "topleft" then
        newFrame = {x = nextRect.x, y = nextRect.y, w = nextRect.w / 2, h = nextRect.h / 2}
    elseif position == "topright" then
        newFrame = {x = nextRect.x + nextRect.w / 2, y = nextRect.y, w = nextRect.w / 2, h = nextRect.h / 2}
    elseif position == "bottomleft" then
        newFrame = {x = nextRect.x, y = nextRect.y + nextRect.h / 2, w = nextRect.w / 2, h = nextRect.h / 2}
    elseif position == "bottomright" then
        newFrame = {x = nextRect.x + nextRect.w / 2, y = nextRect.y + nextRect.h / 2, w = nextRect.w / 2, h = nextRect.h / 2}
    end

    win:setFrame(newFrame)
end

function moveToPreviousDisplayQuarter(position)
    local win = hs.window.focusedWindow()
    if not win then return end

    local currentScreen = win:screen()
    local prevScreen = currentScreen:previous()

    -- Don't cycle - if we're at the first screen, do nothing
    local allScreens = hs.screen.allScreens()
    if not prevScreen or prevScreen == allScreens[#allScreens] then
        return
    end

    local prevRect = prevScreen:frame()
    local newFrame = {}

    if position == "topleft" then
        newFrame = {x = prevRect.x, y = prevRect.y, w = prevRect.w / 2, h = prevRect.h / 2}
    elseif position == "topright" then
        newFrame = {x = prevRect.x + prevRect.w / 2, y = prevRect.y, w = prevRect.w / 2, h = prevRect.h / 2}
    elseif position == "bottomleft" then
        newFrame = {x = prevRect.x, y = prevRect.y + prevRect.h / 2, w = prevRect.w / 2, h = prevRect.h / 2}
    elseif position == "bottomright" then
        newFrame = {x = prevRect.x + prevRect.w / 2, y = prevRect.y + prevRect.h / 2, w = prevRect.w / 2, h = prevRect.h / 2}
    end

    win:setFrame(newFrame)
end

-- Helper functions for cross-display half movement
function moveToNextDisplayHalf()
    local win = hs.window.focusedWindow()
    if not win then return false end

    local currentScreen = win:screen()
    local nextScreen = currentScreen:next()

    -- Don't cycle - if we're at the last screen, return false
    if not nextScreen or nextScreen == hs.screen.allScreens()[1] then
        return false
    end

    local nextRect = nextScreen:frame()
    -- Calculate left half position on the next screen directly
    local newFrame = {
        x = nextRect.x,
        y = nextRect.y,
        w = nextRect.w / 2,
        h = nextRect.h
    }

    win:setFrame(newFrame)
    return true
end

function moveToNextDisplayHalfTop()
    local win = hs.window.focusedWindow()
    if not win then return false end

    local currentScreen = win:screen()
    local nextScreen = currentScreen:next()
    local allScreens = hs.screen.allScreens()

    -- If at the last screen, create right half on current screen instead (edge function)
    if not nextScreen or currentScreen == allScreens[#allScreens] then
        local currentRect = currentScreen:frame()
        local newFrame = {
            x = currentRect.x + currentRect.w / 2,
            y = currentRect.y,
            w = currentRect.w / 2,
            h = currentRect.h
        }
        win:setFrame(newFrame)
        return true
    end

    local nextRect = nextScreen:frame()
    -- Calculate top half position on the next screen (full width, half height)
    local newFrame = {
        x = nextRect.x,
        y = nextRect.y,
        w = nextRect.w,
        h = nextRect.h / 2
    }

    win:setFrame(newFrame)
    return true
end

function moveToNextDisplayHalfBottom()
    local win = hs.window.focusedWindow()
    if not win then return false end

    local currentScreen = win:screen()
    local nextScreen = currentScreen:next()
    local allScreens = hs.screen.allScreens()

    -- If at the last screen, create right half on current screen instead (edge function)
    if not nextScreen or currentScreen == allScreens[#allScreens] then
        local currentRect = currentScreen:frame()
        local newFrame = {
            x = currentRect.x + currentRect.w / 2,
            y = currentRect.y,
            w = currentRect.w / 2,
            h = currentRect.h
        }
        win:setFrame(newFrame)
        return true
    end

    local nextRect = nextScreen:frame()
    -- Calculate bottom half position on the next screen (full width, half height)
    local newFrame = {
        x = nextRect.x,
        y = nextRect.y + nextRect.h / 2,
        w = nextRect.w,
        h = nextRect.h / 2
    }

    win:setFrame(newFrame)
    return true
end

function moveToPreviousDisplayHalf()
    local win = hs.window.focusedWindow()
    if not win then return false end

    local currentScreen = win:screen()
    local prevScreen = currentScreen:previous()

    -- Don't cycle - if we're at the first screen, return false
    local allScreens = hs.screen.allScreens()
    if not prevScreen or prevScreen == allScreens[#allScreens] then
        return false
    end

    local prevRect = prevScreen:frame()
    -- Calculate right half position on the previous screen directly
    local newFrame = {
        x = prevRect.x + prevRect.w / 2,
        y = prevRect.y,
        w = prevRect.w / 2,
        h = prevRect.h
    }

    win:setFrame(newFrame)
    return true
end

function moveToPreviousDisplayHalfTop()
    local win = hs.window.focusedWindow()
    if not win then return false end

    local currentScreen = win:screen()
    local prevScreen = currentScreen:previous()
    local allScreens = hs.screen.allScreens()

    -- If at the first screen, create left half on current screen instead (edge function)
    if not prevScreen or currentScreen == allScreens[1] then
        local currentRect = currentScreen:frame()
        local newFrame = {
            x = currentRect.x,
            y = currentRect.y,
            w = currentRect.w / 2,
            h = currentRect.h
        }
        win:setFrame(newFrame)
        return true
    end

    local prevRect = prevScreen:frame()
    -- Calculate top half position on the previous screen (full width, half height)
    local newFrame = {
        x = prevRect.x,
        y = prevRect.y,
        w = prevRect.w,
        h = prevRect.h / 2
    }

    win:setFrame(newFrame)
    return true
end

function moveToPreviousDisplayHalfBottom()
    local win = hs.window.focusedWindow()
    if not win then return false end

    local currentScreen = win:screen()
    local prevScreen = currentScreen:previous()
    local allScreens = hs.screen.allScreens()

    -- If at the first screen, create left half on current screen instead (edge function)
    if not prevScreen or currentScreen == allScreens[1] then
        local currentRect = currentScreen:frame()
        local newFrame = {
            x = currentRect.x,
            y = currentRect.y,
            w = currentRect.w / 2,
            h = currentRect.h
        }
        win:setFrame(newFrame)
        return true
    end

    local prevRect = prevScreen:frame()
    -- Calculate bottom half position on the previous screen (full width, half height)
    local newFrame = {
        x = prevRect.x,
        y = prevRect.y + prevRect.h / 2,
        w = prevRect.w,
        h = prevRect.h / 2
    }

    win:setFrame(newFrame)
    return true
end

-- Helper functions for cross-display quarter movement
function moveToNextDisplayQuarterContext(position)
    local win = hs.window.focusedWindow()
    if not win then return false end

    local currentScreen = win:screen()
    local nextScreen = currentScreen:next()
    local allScreens = hs.screen.allScreens()

    local currentRect = currentScreen:frame()
    local newFrame = {}

    -- If at the last screen, create right half on current screen instead (edge function)
    if not nextScreen or currentScreen == allScreens[#allScreens] then
        if position == "topleft" or position == "bottomleft" then
            -- Create right half (half-screen size) on current screen
            newFrame = {
                x = currentRect.x + currentRect.w / 2,
                y = currentRect.y,
                w = currentRect.w / 2,
                h = currentRect.h
            }
        elseif position == "topright" or position == "bottomright" then
            -- Already at right edge, do nothing
            return false
        end
    else
        local nextRect = nextScreen:frame()
        if position == "topleft" then
            newFrame = {x = nextRect.x, y = nextRect.y, w = nextRect.w / 2, h = nextRect.h / 2}
        elseif position == "topright" then
            newFrame = {x = nextRect.x + nextRect.w / 2, y = nextRect.y, w = nextRect.w / 2, h = nextRect.h / 2}
        elseif position == "bottomleft" then
            newFrame = {x = nextRect.x, y = nextRect.y + nextRect.h / 2, w = nextRect.w / 2, h = nextRect.h / 2}
        elseif position == "bottomright" then
            newFrame = {x = nextRect.x + nextRect.w / 2, y = nextRect.y + nextRect.h / 2, w = nextRect.w / 2, h = nextRect.h / 2}
        end
    end

    win:setFrame(newFrame)
    return true
end

function moveToPreviousDisplayQuarterContext(position)
    local win = hs.window.focusedWindow()
    if not win then return false end

    local currentScreen = win:screen()
    local prevScreen = currentScreen:previous()
    local allScreens = hs.screen.allScreens()

    local currentRect = currentScreen:frame()
    local newFrame = {}

    -- If at the first screen, create left half on current screen instead (edge function)
    if not prevScreen or currentScreen == allScreens[1] then
        if position == "topright" or position == "bottomright" then
            -- Create left half (half-screen size) on current screen
            newFrame = {
                x = currentRect.x,
                y = currentRect.y,
                w = currentRect.w / 2,
                h = currentRect.h
            }
        elseif position == "topleft" or position == "bottomleft" then
            -- Already at left edge, do nothing
            return false
        end
    else
        local prevRect = prevScreen:frame()
        if position == "topleft" then
            newFrame = {x = prevRect.x, y = prevRect.y, w = prevRect.w / 2, h = prevRect.h / 2}
        elseif position == "topright" then
            newFrame = {x = prevRect.x + prevRect.w / 2, y = prevRect.y, w = prevRect.w / 2, h = prevRect.h / 2}
        elseif position == "bottomleft" then
            newFrame = {x = prevRect.x, y = prevRect.y + prevRect.h / 2, w = prevRect.w / 2, h = prevRect.h / 2}
        elseif position == "bottomright" then
            newFrame = {x = prevRect.x + prevRect.w / 2, y = prevRect.y + prevRect.h / 2, w = prevRect.w / 2, h = prevRect.h / 2}
        end
    end

    win:setFrame(newFrame)
    return true
end