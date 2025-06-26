-- Hammerspoon Magnet Window Manager Script

-- https://www.hammerspoon.org/Spoons/WinWin.html

-- Table to store original window frames for restore functionality
local originalFrames = {}

-- Bind hotkeys to window management actions
local hyper = {"ctrl", "alt"} -- Define a hyper key combination
-- local super = {"ctrl", "cmd", "alt"} -- Define a super key combination

-- Basic Half Positions
hs.hotkey.bind(hyper, "left", function() moveWindow("left") end)      -- Left Half
hs.hotkey.bind(hyper, "right", function() moveWindow("right") end)    -- Right Half
hs.hotkey.bind(hyper, "up", function() moveWindow("top") end)         -- Top Half
hs.hotkey.bind(hyper, "down", function() moveWindow("bottom") end)    -- Bottom Half

-- Basic Quarter Positions
hs.hotkey.bind(hyper, "h", function() moveWindow("topleft") end)      -- Top Left
hs.hotkey.bind(hyper, "l", function() moveWindow("topright") end)     -- Top Right
hs.hotkey.bind(hyper, "j", function() moveWindow("bottomleft") end)   -- Bottom Left
hs.hotkey.bind(hyper, "k", function() moveWindow("bottomright") end)  -- Bottom Right

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

-- Function to move and resize window
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
        newFrame = {x = rect.x, y = rect.y, w = rect.w / 2, h = rect.h / 2}
    elseif position == "topright" then
        newFrame = {x = rect.x + rect.w / 2, y = rect.y, w = rect.w / 2, h = rect.h / 2}
    elseif position == "bottomleft" then
        newFrame = {x = rect.x, y = rect.y + rect.h / 2, w = rect.w / 2, h = rect.h / 2}
    elseif position == "bottomright" then
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
    if not win then return end

    local currentScreen = win:screen()
    local nextScreen = currentScreen:next()

    -- Don't cycle - if we're at the last screen, do nothing
    if not nextScreen or nextScreen == hs.screen.allScreens()[1] then 
        return
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
end

function moveToPreviousDisplay()
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
    -- Calculate right half position on the previous screen directly
    local newFrame = {
        x = prevRect.x + prevRect.w / 2,
        y = prevRect.y,
        w = prevRect.w / 2,
        h = prevRect.h
    }

    win:setFrame(newFrame)
end