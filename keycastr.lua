-- KeyCastr for Hammerspoon
-- Keystroke visualizer inspired by https://github.com/keycastr/keycastr

-- Configuration
local config = {
    enabled = false,                -- Initially disabled
    duration = 1.5,                 -- How long each keystroke stays visible (seconds)
    fontSize = 24,                  -- Font size for keystrokes
    maxDisplayed = 6,               -- Maximum number of keystrokes to display
    fadeOutDuration = 0.3,          -- Fade out animation duration (seconds)
    padding = 4,                    -- Padding inside keystroke box (减小内边距)
    margin = 6,                     -- Margin between keystrokes (减小间距)
    screenEdgeMargin = 20,          -- Margin from screen edge
    position = {                    -- Default position (bottom left)
        x = 30,
        y = nil                     -- Will be calculated based on screen height
    },
    colors = {
        text = {hex = "#FFFFFF"},
        background = {hex = "#333333", alpha = 0.8}
    },
    draggable = true,               -- Allow dragging the visualization
    displayMode = "all_modifiers",  -- Options: "command_only", "all_modifiers", "all_keys"
    showMouseClicks = false,        -- Show mouse click events in keystroke display
    showClickCircle = false,        -- Show circle animation at mouse click location
    clickCircle = {
        size = 40,                  -- Size of click circle
        color = {hex = "#FF7700", alpha = 0.7},  -- Circle color
        duration = 0.3,             -- How long the circle animation lasts
        fadeOut = 0.2               -- Fade out duration
    },
    continuousInput = {
        enabled = true,             -- enable continuous input on the same line
        maxChars = 20,              -- max chars per line
        timeout = 1.0               -- timeout after this time (seconds) to start a new line
    }
}

-- Special key mapping
local specialKeys = {
    tab = "⇥",
    capslock = "⇪",
    up = "↑",
    down = "↓",
    left = "←",
    right = "→",
    escape = "⎋",
    forwarddelete = "⌦",
    delete = "⌫",
    home = "↖",
    ["end"] = "↘",        -- Using bracket notation to avoid keyword conflict
    pageup = "⇞",
    pagedown = "⇟",
    space = "␣",
    ["return"] = "↩",
    fn = "fn",
    eject = "⏏",
}

-- Modifier key symbols
local modifierSymbols = {
    cmd = "⌘",
    alt = "⌥",
    shift = "⇧", 
    ctrl = "⌃",
    rightcmd = "⌘",
    rightalt = "⌥",
    rightshift = "⇧",
    rightctrl = "⌃",
}

-- Mouse button symbols
local mouseButtonSymbols = {
    left = "🖱️LB",
    right = "🖱️RB",
    middle = "🖱️MB",
    button4 = "🖱️B4", -- actually, this is the back button, and have been remap to ctrl-left
    button5 = "🖱️B5", -- actually, this is the forward button, and have been remap to ctrl-right
}

-- State variables
local keystrokeDrawings = {}
local dragInitial = nil
local offsetPosition = {x = 0, y = 0}
local continuousText = ""           -- current continuous input text
local lastInputTime = 0

-- Calculate initial position for the given screen
local function getPositionForScreen(screen)
    local frame = screen:frame()
    local x = config.position.x + offsetPosition.x
    local y = config.position.y

    -- If y is nil, position at bottom of screen
    if y == nil then
        y = frame.h - config.screenEdgeMargin - config.fontSize
    end

    return {
        x = x,
        y = y + offsetPosition.y
    }
end

-- clear all drawings
local function clearAllDrawings()
    for _, item in ipairs(keystrokeDrawings) do
        item.canvas:delete()
    end
    keystrokeDrawings = {}
    continuousText = ""
end

-- Draw a single keystroke/event
local function drawEvent(text, eventType, isModifier)
    if not config.enabled then return end

    local now = hs.timer.secondsSinceEpoch()
    local screen = hs.screen.mainScreen()
    local frame = screen:frame()

    -- handle continuous input (only handle normal characters, not modifiers and mouse clicks)
    if config.continuousInput.enabled and eventType == "keyboard" and not isModifier and 
       text:len() == 1 and not text:match("[%c%z%s]") then -- exclude control characters and whitespace

        -- if the timeout is reached or the max chars is reached, start a new line
        if now - lastInputTime > config.continuousInput.timeout or 
           continuousText:len() >= config.continuousInput.maxChars then
            continuousText = text
        else
            continuousText = continuousText .. text
        end

        lastInputTime = now
        text = continuousText

        -- if there is a old continuous input display, delete it
        if #keystrokeDrawings > 0 and keystrokeDrawings[1].isContinuous then
            keystrokeDrawings[1].canvas:delete()
            table.remove(keystrokeDrawings, 1)
        end
    else
        -- if the event is not a keyboard event or a modifier, reset the continuous input
        if eventType ~= "keyboard" or isModifier then
            continuousText = ""
        end
    end

    -- Calculate text dimensions
    local textWidth = hs.drawing.getTextDrawingSize(text, {size = config.fontSize}).w
    local boxWidth = textWidth + (config.padding * 2)
    local boxHeight = config.fontSize + (config.padding * 2)

    -- Get position for current screen
    local position = getPositionForScreen(screen)

    -- Calculate Y position based on existing keystrokes
    -- ensure no overlap
    local yOffset = 0
    for i, item in ipairs(keystrokeDrawings) do
        yOffset = yOffset + item.canvas:frame().h + config.margin
    end

    local x = position.x
    local y = position.y - yOffset

    -- Create drawing canvas for keystroke
    local drawing = hs.canvas.new({x = x, y = y, w = boxWidth, h = boxHeight})

    -- unified background style - keyboard or mouse
    drawing:appendElements({
        type = "rectangle",
        action = "fill",
        roundedRectRadii = {xRadius = 5, yRadius = 5},
        fillColor = config.colors.background
    })

    -- Add text
    drawing:appendElements({
        type = "text",
        text = text,
        textSize = config.fontSize,
        textColor = config.colors.text,
        textAlignment = "center",
        frame = {x = config.padding, y = config.padding/2, w = textWidth, h = config.fontSize}
    })

    -- Make it appear on all spaces
    drawing:behavior({"canJoinAllSpaces", "stationary"})
    drawing:show()

    -- Add to active drawings
    table.insert(keystrokeDrawings, 1, {
        canvas = drawing, 
        time = now,
        screen = screen:id(),
        isContinuous = (eventType == "keyboard" and not isModifier and text:len() > 1)
    })

    -- Remove oldest if exceed max
    while #keystrokeDrawings > config.maxDisplayed do
        local old = table.remove(keystrokeDrawings)
        old.canvas:delete()
    end
end

-- Format keystroke text
local function formatKeystroke(event)
    local modifiers = event:getFlags()
    local keyCode = event:getKeyCode()
    local key = hs.keycodes.map[keyCode]
    local isModifier = false

    if not key then return nil end

    -- Check display mode filtering
    local hasCommand = modifiers.cmd
    local hasAnyModifier = modifiers.cmd or modifiers.alt or modifiers.shift or modifiers.ctrl

    -- Skip based on display mode
    if config.displayMode == "command_only" and not hasCommand then
        return nil
    elseif config.displayMode == "all_modifiers" and not hasAnyModifier then
        return nil
    end

    -- Check if this is a lone modifier key press
    if modifierSymbols[key] then
        isModifier = true
        return modifierSymbols[key], isModifier
    end

    -- Build modifier prefix
    local modText = ""
    if modifiers.ctrl then modText = modText .. modifierSymbols.ctrl end
    if modifiers.alt then modText = modText .. modifierSymbols.alt end
    if modifiers.cmd then modText = modText .. modifierSymbols.cmd end

    -- handle Shift: for letter keys, keep case; for other keys, display shift symbol
    local keyText = ""
    if modifiers.shift then
        if key:len() == 1 and key:match("[a-zA-Z]") then
            -- letter key, use uppercase
            keyText = key:upper()
        else
            -- non-letter key, display shift symbol and special key
            modText = modText .. modifierSymbols.shift
            keyText = specialKeys[key] or key
        end
    else
        -- no shift, keep original case
        keyText = specialKeys[key] or key
    end

    -- if there is a modifier, then this is not a simple character input
    if modText ~= "" then
        isModifier = true
    end

    return modText .. keyText, isModifier
end

-- Format mouse click text
local function formatMouseClick(event)
    local type = event:getType()
    local buttonString = nil

    -- Determine which mouse button was clicked
    if type == hs.eventtap.event.types.leftMouseDown then
        buttonString = mouseButtonSymbols.left
    elseif type == hs.eventtap.event.types.rightMouseDown then
        buttonString = mouseButtonSymbols.right
    elseif type == hs.eventtap.event.types.otherMouseDown then
        local button = event:getProperty(hs.eventtap.event.properties.mouseEventButtonNumber)
        if button == 2 then
            buttonString = mouseButtonSymbols.middle
        elseif button == 3 then
            buttonString = mouseButtonSymbols.button4
        elseif button == 4 then
            buttonString = mouseButtonSymbols.button5
        else
            buttonString = "🖱️" .. button
        end
    else
        return nil
    end

    -- Get modifiers
    local modifiers = event:getFlags()
    local modText = ""
    if modifiers.ctrl then modText = modText .. modifierSymbols.ctrl end
    if modifiers.alt then modText = modText .. modifierSymbols.alt end
    if modifiers.shift then modText = modText .. modifierSymbols.shift end
    if modifiers.cmd then modText = modText .. modifierSymbols.cmd end

    return modText .. buttonString
end

-- Clean up expired keystrokes
local function cleanupExpiredKeystrokes()
    local now = hs.timer.secondsSinceEpoch()
    local i = #keystrokeDrawings

    while i > 0 do
        local item = keystrokeDrawings[i]
        if now - item.time >= config.duration then
            -- Fade out animation
            item.canvas:delete(config.fadeOutDuration)
            table.remove(keystrokeDrawings, i)
        end
        i = i - 1
    end
end

-- Enable dragging
function setupDragging()
    -- Mouse event handling for dragging
    dragEventTap = hs.eventtap.new({hs.eventtap.event.types.leftMouseDown, 
                                    hs.eventtap.event.types.leftMouseDragged,
                                    hs.eventtap.event.types.leftMouseUp}, function(event)
        if not config.enabled or not config.draggable or #keystrokeDrawings == 0 then 
            return false 
        end

        local type = event:getType()
        local point = hs.mouse.getAbsolutePosition()

        -- Check if click is in our visualization area
        local topDrawing = keystrokeDrawings[1].canvas
        local frame = topDrawing:frame()

        if type == hs.eventtap.event.types.leftMouseDown then
            if point.x >= frame.x and point.x <= frame.x + frame.w and
               point.y >= frame.y and point.y <= frame.y + frame.h then
                dragInitial = {
                    mouse = point,
                    offset = offsetPosition
                }
                return true -- Consume the event
            end
        elseif type == hs.eventtap.event.types.leftMouseDragged then
            if dragInitial then
                offsetPosition = {
                    x = dragInitial.offset.x + (point.x - dragInitial.mouse.x),
                    y = dragInitial.offset.y + (point.y - dragInitial.mouse.y)
                }

                -- Update all drawings positions
                for i, item in ipairs(keystrokeDrawings) do
                    local yOffset = (i - 1) * (config.fontSize + config.margin)
                    local newFrame = item.canvas:frame()
                    local position = getPositionForScreen(hs.screen.find(item.screen))
                    newFrame.x = position.x
                    newFrame.y = position.y - yOffset
                    item.canvas:frame(newFrame)
                end
                return true -- Consume the event
            end
        elseif type == hs.eventtap.event.types.leftMouseUp then
            dragInitial = nil
        end

        return false
    end)
    dragEventTap:start()
end

-- Show circle at mouse click location
local function showClickCircle(event)
    if not config.enabled or not config.showClickCircle then return end
    
    -- Get mouse position
    local point = hs.mouse.getAbsolutePosition()
    -- local screen = hs.mouse.getCurrentScreen()
    
    -- Create a circle centered at the click position
    local circleSize = config.clickCircle.size
    local circle = hs.canvas.new({
        x = point.x - circleSize/2, 
        y = point.y - circleSize/2, 
        w = circleSize, 
        h = circleSize
    })
    
    -- add outer and inner circle
    circle:appendElements({
        type = "circle",
        action = "fill",
        fillColor = {hex = "#000000", alpha = 0.2},
        strokeColor = {hex = "#000000", alpha = 0.3},
        strokeWidth = 2
    })
    
    -- inner circle
    circle:appendElements({
        type = "circle",
        action = "fill",
        fillColor = config.clickCircle.color,
        frame = {
            x = circleSize/4, 
            y = circleSize/4, 
            w = circleSize/2, 
            h = circleSize/2
        }
    })
    
    -- add circle
    -- reuse formatMouseClick function to get mouse button type
    local buttonText = formatMouseClick(event)
    
    circle:appendElements({
        type = "text",
        text = buttonText,
        textSize = circleSize/3,
        textColor = {hex = "#FFFFFF"},
        textAlignment = "center",
        frame = {
            x = 0,
            y = circleSize/3,
            w = circleSize,
            h = circleSize/3
        }
    })
    
    -- Make it appear on all spaces and show it
    circle:behavior({"canJoinAllSpaces", "stationary"})
    circle:show()
    
    -- animation effect: first expand then shrink then fade out
    hs.timer.doAfter(0.1, function()
        circle:size({
            w = circleSize * 1.2,
            h = circleSize * 1.2
        })
        
        hs.timer.doAfter(0.1, function()
            circle:size({
                w = circleSize,
                h = circleSize
            })
            
            hs.timer.doAfter(config.clickCircle.duration - 0.2, function()
                circle:delete(config.clickCircle.fadeOut)
            end)
        end)
    end)
end

-- Toggle keystroke visualization
local function toggleKeystrokes()
    config.enabled = not config.enabled
    
    -- If turning off, clean up all drawings
    if not config.enabled then
        clearAllDrawings()
    end
    
    hs.alert.show("KeyCastr: " .. (config.enabled and "Enabled" or "Disabled"))
end

-- Toggle mouse click circle visualization
local function toggleClickCircle()
    config.showClickCircle = not config.showClickCircle

    -- Restart mouse event tracking if needed
    if mouseEventTap then
        mouseEventTap:stop()
        mouseEventTap = nil
    end

    if config.showMouseClicks or config.showClickCircle then
        mouseEventTap = hs.eventtap.new({hs.eventtap.event.types.leftMouseDown,
                                         hs.eventtap.event.types.rightMouseDown,
                                         hs.eventtap.event.types.otherMouseDown}, function(event)
            if not config.enabled then return false end

            -- Show click circle at mouse position if enabled
            if config.showClickCircle then
                showClickCircle(event)
            end

            -- Show mouse click in keystroke display if enabled
            if config.showMouseClicks then
                local text = formatMouseClick(event)
                if text then drawEvent(text, "mouse", true) end
            end

            return false -- Don't consume the event
        end)
        mouseEventTap:start()
    end

    hs.alert.show("Click Circle: " .. (config.showClickCircle and "Enabled" or "Disabled"))
end

-- Toggle continuous input mode
local function toggleContinuousInput()
    config.continuousInput.enabled = not config.continuousInput.enabled
    
    -- Reset when toggling
    continuousText = ""
    
    hs.alert.show("Continuous Input: " .. (config.continuousInput.enabled and "Enabled" or "Disabled"))
end

-- Register toggle hotkeys
hs.hotkey.bind({"ctrl", "cmd", "alt"}, "k", toggleKeystrokes)
hs.hotkey.bind({"ctrl", "cmd", "alt"}, "c", toggleClickCircle)
hs.hotkey.bind({"ctrl", "cmd", "alt"}, "i", toggleContinuousInput)

-- Setup key event tracking
function setupKeytracking()
    -- Track key presses
    keyEventTap = hs.eventtap.new({hs.eventtap.event.types.keyDown, 
                                   hs.eventtap.event.types.flagsChanged}, function(event)
        if not config.enabled then return false end
        
        local text, isModifier = formatKeystroke(event)
        if text then drawEvent(text, "keyboard", isModifier) end
        
        return false -- Don't consume the event
    end)
    keyEventTap:start()
    
    -- Track mouse clicks if enabled (for keystroke display or click circles)
    if config.showMouseClicks or config.showClickCircle then
        mouseEventTap = hs.eventtap.new({hs.eventtap.event.types.leftMouseDown,
                                        hs.eventtap.event.types.rightMouseDown,
                                        hs.eventtap.event.types.otherMouseDown}, function(event)
            if not config.enabled then return false end
            
            -- Show click circle at mouse position if enabled
            if config.showClickCircle then
                showClickCircle(event)
            end
            
            -- Show mouse click in keystroke display if enabled
            if config.showMouseClicks then
                local text = formatMouseClick(event)
                if text then drawEvent(text, "mouse", true) end
            end

            return false -- Don't consume the event
        end)
        mouseEventTap:start()
    end

    -- Timer for cleanup
    cleanupTimer = hs.timer.doEvery(0.5, cleanupExpiredKeystrokes)
end

-- Initialize
setupKeytracking()
setupDragging()