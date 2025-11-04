-- Window Switcher module (Alt-Tab style) implemented with hs.window.filter and hs.canvas

local logger = require("core.logger")
local config = require("core.config_loader")

local log = logger.getLogger("window_switcher")

local M = {}

local session = {
    active = false,
    windows = {},
    index = 1,
    baseMods = {},
    modifierWatcher = nil,
    canvas = nil,
    hotkeys = {},
    elementIndices = {},
    assets = {}
}

local initialized = false

local windowFilter = hs.window.filter.new():setDefaultFilter({})
windowFilter:setCurrentSpace(true)
windowFilter:setSortOrder(hs.window.filter.sortByFocusedLast)

local function getHotkeyConfig(path)
    return config.get("hotkeys." .. path)
end

local function cloneTable(tbl)
    local copy = {}
    for i, value in ipairs(tbl) do
        copy[i] = value
    end
    return copy
end

local function isModifierActive(flags, mod)
    if not flags then
        return false
    end

    if mod == "option" or mod == "alt" then
        return flags.option == true or flags.alt == true
    end

    return flags[mod] == true
end

local function allBaseModifiersActive(flags)
    for _, mod in ipairs(session.baseMods) do
        if not isModifierActive(flags, mod) then
            return false
        end
    end
    return true
end

local function normalizeModifier(mod)
    if type(mod) ~= "string" then
        return nil
    end

    local lowered = string.lower(mod)
    local map = {
        cmd = "cmd",
        command = "cmd",
        ["⌘"] = "cmd",
        alt = "alt",
        option = "alt",
        opt = "alt",
        ["⌥"] = "alt",
        ctrl = "ctrl",
        control = "ctrl",
        ["⌃"] = "ctrl",
        shift = "shift",
        ["⇧"] = "shift",
        fn = "fn"
    }

    return map[lowered] or map[mod] or lowered
end

local function rgba(r, g, b, a)
    return {
        red = r / 255,
        green = g / 255,
        blue = b / 255,
        alpha = a or 1.0
    }
end

local STYLE = {
    background = rgba(8, 10, 17, 0.55),
    panel = {
        fill = rgba(18, 21, 30, 0.92),
        stroke = rgba(142, 150, 170, 0.12),
        shadow = {
            blurRadius = 40,
            offset = {h = 0, w = 0},
            color = rgba(7, 10, 18, 0.7)
        }
    },
    tile = {
        fill = rgba(33, 37, 52, 0.88),
        selectedFill = rgba(60, 92, 160, 0.90),
        stroke = rgba(142, 161, 200, 0.14),
        selectedStroke = rgba(138, 180, 255, 0.75),
        shadow = {
            blurRadius = 18,
            offset = {h = 0, w = 0},
            color = rgba(7, 9, 16, 0.55)
        },
        selectedShadow = {
            blurRadius = 32,
            offset = {h = 0, w = 0},
            color = rgba(58, 96, 180, 0.65)
        }
    },
    text = {
        primary = rgba(234, 240, 255, 0.92),
        primarySelected = rgba(255, 255, 255, 1.0),
        secondary = rgba(189, 199, 226, 0.78),
        secondarySelected = rgba(217, 227, 255, 0.95),
        hint = rgba(140, 152, 180, 0.75),
        hintSelected = rgba(223, 229, 255, 0.9)
    },
    overlay = {
        idle = rgba(12, 15, 24, 0.28),
        selected = rgba(10, 15, 28, 0.14)
    },
    indicator = {
        idle = rgba(138, 180, 255, 0.16),
        selected = rgba(138, 180, 255, 0.88)
    }
}

local LAYOUT = {
    panelPadding = 40,
    tileWidth = 280,
    tileHeight = 220,
    tileSpacing = 28,
    imageHeight = 130,
    perRowMax = 5,
    maxWindows = 12
}


local function buildAppAllowList()
    local filterConfig = config.get("applications.expose_app_filter.allowed", {})
    if type(filterConfig) ~= "table" then
        return nil
    end

    if next(filterConfig) == nil then
        return nil
    end

    local allow = {}
    for _, name in ipairs(filterConfig) do
        allow[name] = true
    end
    return allow
end

local function allowWindow(win, allowList)
    if not win or not win:isStandard() then
        return false
    end

    local app = win:application()
    if not app then
        return false
    end

    if allowList and not allowList[app:name()] then
        return false
    end

    local title = win:title() or ""
    if title == "" then
        return false
    end

    return true
end

local function buildWindowList()
    local allowList = buildAppAllowList()
    local windows = windowFilter:getWindows(hs.window.filter.sortByFocusedLast)
    local seen = {}
    local ordered = {}

    for _, win in ipairs(windows) do
        local id = win:id()
        if id and not seen[id] and allowWindow(win, allowList) then
            table.insert(ordered, win)
            seen[id] = true
        end
    end

    if #ordered > LAYOUT.maxWindows then
        while #ordered > LAYOUT.maxWindows do
            table.remove(ordered)
        end
    end

    return ordered
end

local function truncate(text, maxLen)
    if #text <= maxLen then
        return text
    end
    return text:sub(1, maxLen - 1) .. "…"
end

local function safeSnapshot(win)
    if not win or not win.snapshot then
        return nil
    end

    local ok, image = pcall(function()
        return win:snapshot()
    end)

    if ok and image then
        return image
    end

    local id = win:id()
    if id and hs.window.snapshotForID then
        local okAlt, altImage = pcall(function()
            return hs.window.snapshotForID(id)
        end)

        if okAlt and altImage then
            return altImage
        end
    end

    return nil
end

local function fallbackInitials(text)
    if not text or text == "" then
        return "?"
    end
    local initials = text:match("^%s*(%S)") or "?"
    return initials:upper()
end

local function buildHint(idx)
    if idx >= 1 and idx <= 9 then
        return string.format("⌥ %d", idx)
    elseif idx == 10 then
        return "⌥ 0"
    elseif idx == 11 then
        return "⌥ -"
    else
        return ""
    end
end

local function buildWindowAssets(windows)
    local assets = {}

    for idx, win in ipairs(windows) do
        local app = win:application()
        local appName = app and app:name() or "Application"
        local windowTitle = win:title()
        if not windowTitle or windowTitle == "" then
            windowTitle = appName
        end

        local entry = {
            appName = appName,
            title = windowTitle,
            hint = buildHint(idx)
        }

        local snapshot = safeSnapshot(win)
        if snapshot then
            entry.primaryImage = snapshot
            entry.imageScaling = "scaleProportionally"
        elseif app and app:bundleID() then
            entry.primaryImage = hs.image.imageFromAppBundle(app:bundleID())
            entry.imageScaling = "scaleProportionally"
        end

        if not entry.primaryImage and app and app:bundleID() then
            entry.icon = hs.image.imageFromAppBundle(app:bundleID())
        end

        entry.fallbackLabel = fallbackInitials(appName)
        assets[idx] = entry
    end

    return assets
end

local function destroyCanvas()
    if session.canvas then
        session.canvas:hide(0.05)
        session.canvas:delete()
        session.canvas = nil
    end
end

local function layoutCanvas()
    destroyCanvas()

    local count = #session.windows
    if count == 0 then
        return
    end

    session.elementIndices = {}

    local screen = hs.screen.mainScreen()
    local frame = screen:frame()
    local perRow = math.min(count, LAYOUT.perRowMax)
    local rows = math.ceil(count / perRow)

    local panelWidth = LAYOUT.panelPadding * 2 + perRow * LAYOUT.tileWidth + math.max(0, perRow - 1) * LAYOUT.tileSpacing
    local panelHeight = LAYOUT.panelPadding * 2 + rows * LAYOUT.tileHeight + math.max(0, rows - 1) * LAYOUT.tileSpacing

    local panelOriginX = (frame.w - panelWidth) / 2
    local panelOriginY = (frame.h - panelHeight) / 2

    local canvas = hs.canvas.new({
        x = frame.x,
        y = frame.y,
        w = frame.w,
        h = frame.h
    })
    canvas:level(hs.canvas.windowLevels.screenSaver)

    canvas[1] = {
        type = "rectangle",
        frame = {x = 0, y = 0, w = frame.w, h = frame.h},
        fillColor = STYLE.background
    }

    canvas[2] = {
        type = "rectangle",
        frame = {
            x = panelOriginX,
            y = panelOriginY,
            w = panelWidth,
            h = panelHeight
        },
        fillColor = STYLE.panel.fill,
        strokeColor = STYLE.panel.stroke,
        roundedRectRadii = {xRadius = 28, yRadius = 28},
        shadow = STYLE.panel.shadow
    }

    local nextIndex = 3

    for idx, _ in ipairs(session.windows) do
        local col = (idx - 1) % perRow
        local row = math.floor((idx - 1) / perRow)
        local originX = panelOriginX + LAYOUT.panelPadding + col * (LAYOUT.tileWidth + LAYOUT.tileSpacing)
        local originY = panelOriginY + LAYOUT.panelPadding + row * (LAYOUT.tileHeight + LAYOUT.tileSpacing)

        local tileFrame = {
            x = originX,
            y = originY,
            w = LAYOUT.tileWidth,
            h = LAYOUT.tileHeight
        }

        session.elementIndices[idx] = {}

        canvas[nextIndex] = {
            type = "rectangle",
            frame = tileFrame,
            fillColor = STYLE.tile.fill,
            strokeColor = STYLE.tile.stroke,
            roundedRectRadii = {xRadius = 22, yRadius = 22},
            shadow = STYLE.tile.shadow
        }
        session.elementIndices[idx].tile = nextIndex
        nextIndex = nextIndex + 1

        local thumbFrame = {
            x = tileFrame.x + 20,
            y = tileFrame.y + 20,
            w = tileFrame.w - 40,
            h = LAYOUT.imageHeight
        }

        canvas[nextIndex] = {
            type = "rectangle",
            frame = thumbFrame,
            roundedRectRadii = {xRadius = 16, yRadius = 16},
            fillColor = rgba(38, 42, 58, 0.92),
            strokeColor = rgba(90, 100, 128, 0.20)
        }
        session.elementIndices[idx].thumbBackground = nextIndex
        nextIndex = nextIndex + 1

        local asset = session.assets[idx] or {}
        if asset.primaryImage then
            canvas[nextIndex] = {
                type = "image",
                image = asset.primaryImage,
                frame = thumbFrame,
                imageScaling = asset.imageScaling or "scaleProportionally",
                roundedRectRadii = {xRadius = 16, yRadius = 16},
                clipToPath = true
            }
            session.elementIndices[idx].thumbImage = nextIndex
            nextIndex = nextIndex + 1
        elseif asset.icon then
            canvas[nextIndex] = {
                type = "image",
                image = asset.icon,
                frame = thumbFrame,
                imageScaling = "scaleToFit",
                roundedRectRadii = {xRadius = 16, yRadius = 16},
                clipToPath = true,
                alpha = 0.88
            }
            session.elementIndices[idx].thumbImage = nextIndex
            nextIndex = nextIndex + 1
        else
            canvas[nextIndex] = {
                type = "text",
                frame = thumbFrame,
                text = asset.fallbackLabel or "?",
                textAlignment = "center",
                textSize = 56,
                textColor = STYLE.text.primary,
                textFont = ".AppleSystemUIFontBold"
            }
            session.elementIndices[idx].thumbFallback = nextIndex
            nextIndex = nextIndex + 1
        end

        if asset.primaryImage or asset.icon then
            canvas[nextIndex] = {
                type = "rectangle",
                frame = thumbFrame,
                roundedRectRadii = {xRadius = 16, yRadius = 16},
                fillColor = STYLE.overlay.idle
            }
            session.elementIndices[idx].thumbOverlay = nextIndex
            nextIndex = nextIndex + 1
        end

        local textTop = thumbFrame.y + thumbFrame.h + 14
        local textWidth = tileFrame.w - 40

        canvas[nextIndex] = {
            type = "text",
            frame = {
                x = tileFrame.x + 20,
                y = textTop,
                w = textWidth,
                h = 26
            },
            text = truncate((asset.appName or "Application"), 28),
            textColor = STYLE.text.primary,
            textSize = 20,
            textFont = ".AppleSystemUIFontBold"
        }
        session.elementIndices[idx].appText = nextIndex
        nextIndex = nextIndex + 1

        canvas[nextIndex] = {
            type = "text",
            frame = {
                x = tileFrame.x + 20,
                y = textTop + 26,
                w = textWidth,
                h = 22
            },
            text = truncate((asset.title or ""), 40),
            textColor = STYLE.text.secondary,
            textSize = 14,
            textFont = ".AppleSystemUIFont"
        }
        session.elementIndices[idx].titleText = nextIndex
        nextIndex = nextIndex + 1

        if asset.hint and asset.hint ~= "" then
            canvas[nextIndex] = {
                type = "text",
                frame = {
                    x = tileFrame.x + tileFrame.w - 76,
                    y = tileFrame.y + tileFrame.h - 32,
                    w = 64,
                    h = 18
                },
                text = asset.hint,
                textColor = STYLE.text.hint,
                textSize = 12,
                textAlignment = "right"
            }
            session.elementIndices[idx].hintText = nextIndex
            nextIndex = nextIndex + 1
        end

        canvas[nextIndex] = {
            type = "rectangle",
            frame = {
                x = tileFrame.x + 20,
                y = tileFrame.y + tileFrame.h - 10,
                w = tileFrame.w - 40,
                h = 4
            },
            fillColor = STYLE.indicator.idle,
            roundedRectRadii = {xRadius = 2, yRadius = 2}
        }
        session.elementIndices[idx].indicator = nextIndex
        nextIndex = nextIndex + 1
    end

    session.canvas = canvas
    canvas:show(0.08)
end

local function updateHighlight()
    if not session.canvas then
        return
    end

    for idx = 1, #session.windows do
        local indices = session.elementIndices[idx]
        if indices then
            local selected = idx == session.index

            if indices.tile then
                session.canvas:elementAttribute(indices.tile, "fillColor", selected and STYLE.tile.selectedFill or STYLE.tile.fill)
                session.canvas:elementAttribute(indices.tile, "strokeColor", selected and STYLE.tile.selectedStroke or STYLE.tile.stroke)
                session.canvas:elementAttribute(indices.tile, "shadow", selected and STYLE.tile.selectedShadow or STYLE.tile.shadow)
            end

            if indices.thumbOverlay then
                session.canvas:elementAttribute(indices.thumbOverlay, "fillColor", selected and STYLE.overlay.selected or STYLE.overlay.idle)
            end

            if indices.appText then
                session.canvas:elementAttribute(indices.appText, "textColor", selected and STYLE.text.primarySelected or STYLE.text.primary)
            end

            if indices.titleText then
                session.canvas:elementAttribute(indices.titleText, "textColor", selected and STYLE.text.secondarySelected or STYLE.text.secondary)
            end

            if indices.hintText then
                session.canvas:elementAttribute(indices.hintText, "textColor", selected and STYLE.text.hintSelected or STYLE.text.hint)
            end

            if indices.indicator then
                session.canvas:elementAttribute(indices.indicator, "fillColor", selected and STYLE.indicator.selected or STYLE.indicator.idle)
            end
        end
    end
end

local function setSelection(index)
    if index < 1 or index > #session.windows then
        return
    end

    session.index = index
    updateHighlight()
end

local function stopModifierWatcher()
    if session.modifierWatcher then
        session.modifierWatcher:stop()
        session.modifierWatcher = nil
    end
end

local function resetSession()
    stopModifierWatcher()
    destroyCanvas()
    session.active = false
    session.windows = {}
    session.index = 1
    session.elementIndices = {}
    session.assets = {}
end

local function focusWindow(win)
    if not win then
        return
    end

    local app = win:application()
    if app and app:isHidden() then
        app:unhide()
    end

    if win:isMinimized() then
        win:unminimize()
    end

    if app then
        app:activate(true)
    end

    win:focus()
    win:raise()
end

local function finalizeSelection()
    if not session.active then
        return
    end

    local target = session.windows[session.index]
    resetSession()
    focusWindow(target)
end

local function startModifierWatcher()
    stopModifierWatcher()

    session.modifierWatcher = hs.eventtap.new({hs.eventtap.event.types.flagsChanged}, function(event)
        local flags = event:getFlags()
        if not allBaseModifiersActive(flags) then
            finalizeSelection()
        end

        return false
    end)

    session.modifierWatcher:start()
end

local function stepSelection(delta)
    if #session.windows == 0 then
        return
    end

    local newIndex = ((session.index - 1 + delta) % #session.windows) + 1
    setSelection(newIndex)
end

local function handleHotkeyRelease()
    if not session.active then
        return
    end

    local currentFlags = hs.eventtap.checkKeyboardModifiers()
    if not allBaseModifiersActive(currentFlags) then
        finalizeSelection()
    else
        hs.timer.doAfter(0.05, function()
            if session.active then
                local refreshedFlags = hs.eventtap.checkKeyboardModifiers()
                if not allBaseModifiersActive(refreshedFlags) then
                    finalizeSelection()
                end
            end
        end)
    end
end

local function beginSession(step)
    if session.active then
        stepSelection(step)
        return
    end

    session.windows = buildWindowList()
    if #session.windows == 0 then
        log.w("No windows available for switcher")
        return
    end

    session.active = true
    session.index = 1
    session.assets = buildWindowAssets(session.windows)

    layoutCanvas()
    startModifierWatcher()
    stepSelection(step)
end

local function registerHotkey(mods, key, step)
    local desc = step > 0 and "Window Switcher (Forward)" or "Window Switcher (Backward)"
    local binding = hs.hotkey.bind(mods, key, desc, function()
        beginSession(step)
    end, handleHotkeyRelease, function()
        beginSession(step)
    end)

    table.insert(session.hotkeys, binding)
end

local function configureHotkeys()
    for _, hk in ipairs(session.hotkeys) do
        hk:delete()
    end
    session.hotkeys = {}

    local exposeHotkey = getHotkeyConfig("system.expose") or {"alt", "tab"}

    if #exposeHotkey < 1 then
        log.e("Invalid hotkey configuration for system.expose")
        return
    end

    local key = exposeHotkey[#exposeHotkey]
    local mods = {}
    for i = 1, #exposeHotkey - 1 do
        local normalized = normalizeModifier(exposeHotkey[i])
        if normalized then
            table.insert(mods, normalized)
        end
    end

    if #mods == 0 then
        log.e("No modifiers configured for window switcher")
        return
    end

    session.baseMods = cloneTable(mods)

    registerHotkey(mods, key, 1)

    local shiftMods = cloneTable(mods)
    table.insert(shiftMods, "shift")
    registerHotkey(shiftMods, key, -1)

    log.i(string.format("Window switcher hotkeys registered for %s + %s", table.concat(mods, "+"), key))
end

function M.init()
    if not initialized then
        log.i("Initializing window switcher module")
        configureHotkeys()
        initialized = true
        log.i("Window switcher module initialized")
    else
        log.i("Re-initializing window switcher module")
        configureHotkeys()
    end
end

function M.reload()
    configureHotkeys()
end

function M.ensureInitialized()
    if not initialized then
        M.init()
    end
end

function M.trigger(step)
    M.ensureInitialized()
    beginSession(step or 1)
end

function M.cancel()
    resetSession()
end

function M.debug()
    log.i("Window switcher debug:")
    log.i(string.format("  Active: %s", tostring(session.active)))
    log.i(string.format("  Window count: %d", #session.windows))
    log.i(string.format("  Current index: %d", session.index))
end

local init_system = require("core.init_system")
init_system.registerModule("modules.window_expose", {
    init = M.init
})

return M
