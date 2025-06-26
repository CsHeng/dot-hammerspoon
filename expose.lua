-- local wf = hs.window.filter

-- Performance optimization: disable background fitting
-- hs.expose.ui.fitWindowsInBackground = false

-- -- Create a strict windowfilter that only allows specified apps
-- local wfAllowed = wf.new(false) -- Start with empty filter (rejects all)

-- -- Explicitly allow only these apps with less restrictive settings
-- wfAllowed:setAppFilter('WezTerm', {})  -- Allow all windows from these apps
-- wfAllowed:setAppFilter('Finder', {})
-- wfAllowed:setAppFilter('Google Chrome', {})
-- wfAllowed:setAppFilter('Cursor', {})
-- wfAllowed:setAppFilter('WeChat', {})
-- wfAllowed:setAppFilter('QQ', {})
-- wfAllowed:setAppFilter('DingTalk', {})

-- local expose = hs.expose.new(wfAllowed, {
local expose = hs.expose.new(nil, {
    onlyActiveApplication=false,
    showThumbnails=true,
    includeOtherSpaces=true,      -- Show windows from other spaces
    includeNonVisible=true,       -- Include hidden/minimized windows
}) -- default windowfilter, with thumbnails
-- local expose_app = hs.expose.new(nil, {onlyActiveApplication=true, showThumbnails=true}) -- show windows for the current application, with thumbnails
-- expose_space = hs.expose.new(nil, {includeOtherSpaces=false, showThumbnails=true}) -- only windows in the current Mission Control Space, with thumbnails
-- expose_browsers = hs.expose.new({'Safari', 'Google Chrome'}, {showThumbnails=true}) -- specialized expose using a custom windowfilter, with thumbnails
-- for your dozens of browser windows :)

-- then bind to a hotkey
hs.hotkey.bind({"ctrl", "cmd"}, "tab", "Expose", function()
    expose:toggleShow()
end)

-- hs.hotkey.bind({"ctrl", "cmd", "shift"}, "e", "App Expose", function()
--     hs.alert.show("App Expose")
--     expose_app:toggleShow()
-- end)