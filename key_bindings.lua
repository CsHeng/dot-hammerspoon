local utils = require("utils")
local log = hs.logger.new("config", "info")

local launcherModifier = {'cmd', 'alt'}
local mediaModifier = {'ctrl', 'cmd', 'alt'}
local fuckModifier = {'ctrl', 'cmd', 'alt'}

local launcherAppList = {
    {modifier = launcherModifier, key = 'C', appname = 'Cursor', bundleid = 'com.todesktop.230313mzl4w4u92'},
    {modifier = launcherModifier, key = 'Q', appname = 'QQ', bundleid = 'com.tencent.qq'},
    {modifier = launcherModifier, key = 'W', appname = 'WeChat', bundleid = 'com.tencent.xinWeChat'},
    {modifier = launcherModifier, key = 'D', appname = 'DingTalk', bundleid = 'com.alibaba.DingTalk'},
    {modifier = launcherModifier, key = 'G', appname = 'Google Chrome', bundleid = 'com.google.Chrome'},
    {modifier = launcherModifier, key = 'F', appname = 'Finder', bundleid = 'com.apple.Finder'},
    {modifier = launcherModifier, key = 'H', appname = 'Hammerspoon', bundleid = 'org.hammerspoon.Hammerspoon'},
    -- {modifier = {}, key = 'F10', appname = 'WezTerm', bundleid = 'com.github.wez.wezterm'},
    {modifier = {}, key = 'F10', appname = 'Ghostty', bundleid = 'com.mitchellh.ghostty'},
}

local mediaControlList = {
    {modifier = mediaModifier, key = 'left', action = 'PREVIOUS'},
    {modifier = mediaModifier, key = 'right', action = 'NEXT'},
    {modifier = mediaModifier, key = 'space', action = 'PLAY'},
    {modifier = mediaModifier, key = 'up', action = 'SOUND_UP'},
    {modifier = mediaModifier, key = 'down', action = 'SOUND_DOWN'},
}

local fuckAppList = {
    {modifier = fuckModifier, key = 'D', appname = 'DisplayLink Manager', bundleid = 'com.displaylink.DisplayLinkUserAgent'},
}

-- register toggle app
hs.fnutils.each(launcherAppList, function(entry)
    -- don't show app name in hotkey hint
    -- hs.hotkey.bind(entry.modifier, entry.key, entry.appname, function()
    hs.hotkey.bind(entry.modifier, entry.key, function()
        utils.toggleApp(entry.appname, entry.bundleid)
    end)
end)

-- register media control
hs.fnutils.each(mediaControlList, function(entry)
    hs.hotkey.bind(entry.modifier, entry.key, entry.action, function()
        log.i("mediaControl: " .. tostring(entry.action))
        hs.eventtap.event.newSystemKeyEvent(entry.action, true):post()
        hs.eventtap.event.newSystemKeyEvent(entry.action, false):post()
    end)
end)

-- register app that sucks, may need restart
hs.fnutils.each(fuckAppList, function(entry)
    hs.hotkey.bind(entry.modifier, entry.key, entry.appname, function()
        log.i("restartApp: " .. tostring(entry.appname) .. " " .. tostring(entry.bundleid))
        utils.restartApp(entry.appname, entry.bundleid)
    end)
end)

-- Double-press Cmd + Q to Quit
local cmdQState = {
    pressed = false,
    timer = nil
}

hs.hotkey.bind({"cmd"}, "q", function()
    if cmdQState.pressed then
        -- Second press: Quit the frontmost app
        local app = hs.application.frontmostApplication()
        if app then
            app:kill()
        end
        cmdQState.pressed = false
        if cmdQState.timer then 
            cmdQState.timer:stop() 
        end
    else
        -- First press: Set state and start timer
        cmdQState.pressed = true
        cmdQState.timer = hs.timer.doAfter(0.5, function()
            cmdQState.pressed = false
        end)
        hs.alert.show("Press Cmd+Q again to quit")
    end
end)

-- add stupid fn trick: https://github.com/Hammerspoon/hammerspoon/issues/1946
local mouseModifier = {"fn", "ctrl"}

-- Logitech G603/GPW Mouse Button Bindings
mouseTap = hs.eventtap.new({
    hs.eventtap.event.types.otherMouseDown,
    -- hs.eventtap.event.types.otherMouseUp
}, function(event)
    local button = event:getProperty(hs.eventtap.event.properties.mouseEventButtonNumber)

    if button == 2 and not utils.isBrowser() then
        -- hs.spaces.toggleMissionControl()
        hs.eventtap.keyStroke(mouseModifier, "up", 0)
        return true
    elseif button == 3 then
        hs.eventtap.keyStroke(mouseModifier, "right", 0)
        return true
    elseif button == 4 then
        hs.eventtap.keyStroke(mouseModifier, "left", 0)
        return true
    end
    return false
end):start()

-- Defeating paste-blocking
hs.hotkey.bind({"cmd", "alt"}, "V", function()
    hs.eventtap.keyStrokes(hs.pasteboard.getContents())
end)
