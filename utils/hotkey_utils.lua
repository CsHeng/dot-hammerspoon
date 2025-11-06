-- Hotkey utilities to standardize binding behavior across the config.
-- Provides parsing helpers and centralizes whether Hammerspoon shows its
-- built-in alert when a hotkey fires.

local hotkey = require("hs.hotkey")
local logger = require("core.logger")
local notification_utils = require("utils.notification_utils")

local log = logger.getLogger("hotkey_utils")

local M = {}

-- Normalize a hotkey specification into modifiers and key.
-- Accepts either an array-like table ({"ctrl","alt","k"}) or a table with
-- explicit keys ({modifiers = {...}, key = "k"}).
function M.parseHotkey(spec)
    if type(spec) ~= "table" then
        return {}, spec
    end

    if spec.key ~= nil then
        local modifiers = spec.modifiers or spec.mods or spec.modifier or {}
        return modifiers, spec.key
    end

    local count = #spec
    if count == 0 then
        return {}, nil
    end

    local modifiers = {}
    for i = 1, count - 1 do
        modifiers[i] = spec[i]
    end

    return modifiers, spec[count]
end

-- Internal helper to guard against nil callbacks.
local function ensureHandler(fn, allowNil)
    if type(fn) == "function" then
        return fn
    end
    if allowNil then
        return nil
    end
    return function() end
end

local modifierSymbols = {
    cmd = "⌘",
    command = "⌘",
    alt = "⌥",
    option = "⌥",
    ctrl = "⌃",
    control = "⌃",
    shift = "⇧",
    fn = "Fn",
    super = "⌘",
    meta = "⌃"
}

local function formatModifiers(modifiers)
    if type(modifiers) ~= "table" or #modifiers == 0 then
        return ""
    end

    local parts = {}
    for i = 1, #modifiers do
        local mod = tostring(modifiers[i])
        local symbol = modifierSymbols[string.lower(mod)]
        parts[i] = symbol or string.upper(mod)
    end
    return table.concat(parts)
end

local function formatKey(key)
    if type(key) ~= "string" then
        return tostring(key)
    end

    local lower = string.lower(key)
    local special = {
        space = "SPACE",
        ["return"] = "RETURN",
        enter = "ENTER",
        tab = "TAB",
        left = "LEFT",
        right = "RIGHT",
        up = "UP",
        down = "DOWN",
        esc = "ESC",
        escape = "ESC",
        backspace = "BACKSPACE",
        delete = "DELETE",
        home = "HOME",
        ["end"] = "END",
        pageup = "PAGEUP",
        pagedown = "PAGEDOWN"
    }

    if special[lower] then
        return special[lower]
    end

    if #key == 1 then
        return string.upper(key)
    end

    return string.upper(key)
end

local function buildMessage(modifiers, key, description)
    local modifierString = formatModifiers(modifiers)
    local keyString = formatKey(key)
    local base = modifierString .. keyString
    if base == "" then
        base = tostring(key)
    end
    if type(description) == "string" and description ~= "" then
        return string.format("%s: %s", base, description)
    end
    return base
end

local function buildAnnouncementContext(options, modifiers, key, description)
    local announceOpt = options.announce
    if announceOpt == false then
        return nil
    end

    local context = {
        module = options.module,
        id = options.id,
        default_message = buildMessage(modifiers, key, description),
        call_before = false
    }

    if announceOpt == nil then
        if not notification_utils.shouldAnnounce(context.module, context.id, nil) then
            return nil
        end
        return context
    end

    if announceOpt == true then
        context.override = true
        return context
    end

    local optType = type(announceOpt)
    if optType == "function" then
        context.message_fn = announceOpt
        return context
    elseif optType ~= "table" then
        context.override = announceOpt
        return context
    end

    if announceOpt.enabled == false then
        return nil
    elseif announceOpt.enabled == true and announceOpt.override == nil and announceOpt.config == nil and announceOpt.channel == nil then
        context.override = true
    end

    if type(announceOpt.id) == "string" and announceOpt.id ~= "" then
        context.id = announceOpt.id
    end

    if announceOpt.call_before == true then
        context.call_before = true
    end

    if type(announceOpt.message_fn) == "function" then
        context.message_fn = announceOpt.message_fn
    elseif type(announceOpt.message) == "function" then
        context.message_fn = announceOpt.message
    elseif type(announceOpt.message) == "string" then
        context.message = announceOpt.message
    end

    if type(announceOpt.message_args) == "table" then
        context.message_args = announceOpt.message_args
    end

    if announceOpt.duration then
        context.preferred_duration = announceOpt.duration
    end

    if announceOpt.title then
        context.preferred_title = announceOpt.title
    end

    if announceOpt.alert_style then
        context.preferred_alert_style = announceOpt.alert_style
    end

    if announceOpt.channel then
        context.preferred_channel = announceOpt.channel
    end

    local overrideTable = nil

    if type(announceOpt.config) == "table" then
        overrideTable = overrideTable or {}
        for k, v in pairs(announceOpt.config) do
            overrideTable[k] = v
        end
    end

    if announceOpt.override ~= nil then
        if type(announceOpt.override) == "table" then
            overrideTable = overrideTable or {}
            for k, v in pairs(announceOpt.override) do
                overrideTable[k] = v
            end
        else
            context.override = announceOpt.override
        end
    end

    if overrideTable then
        if type(context.override) == "table" then
            for k, v in pairs(overrideTable) do
                context.override[k] = v
            end
        elseif context.override == nil then
            context.override = overrideTable
        end
    end

    return context
end

local function attachAnnouncementHandler(originalHandler, key, context)
    if not context then
        return originalHandler
    end

    local handler = ensureHandler(originalHandler, false)

    local function performAnnouncement()
        local ok, err = pcall(notification_utils.announce, context.module, context.id, {
            message = context.message,
            message_fn = context.message_fn,
            message_args = context.message_args,
            preferred_channel = context.preferred_channel,
            preferred_duration = context.preferred_duration,
            preferred_title = context.preferred_title,
            preferred_alert_style = context.preferred_alert_style,
            override = context.override,
            default_message = context.default_message,
            metadata = {
                hotkey = context.default_message,
                key = key
            }
        })

        if not ok then
            log.w(string.format("Announcement failed for hotkey '%s': %s", tostring(key), tostring(err)))
        end
    end

    if context.call_before then
        return function(...)
            performAnnouncement()
            return handler(...)
        end
    end

    return function(...)
        local results = table.pack(handler(...))
        performAnnouncement()
        return table.unpack(results, 1, results.n)
    end
end

-- Bind a hotkey while controlling whether Hammerspoon displays its default alert.
-- Usage patterns:
--   bind({"ctrl","alt"}, "K", {pressed = handler})
--   bind({"ctrl","alt","K"}, {pressed = handler})
--   bind({"ctrl","alt"}, "K", handler)
function M.bind(modifiersOrSpec, keyOrOptions, maybeOptions)
    local modifiers
    local key
    local options

    if keyOrOptions == nil or type(keyOrOptions) == "table" and (
        keyOrOptions.pressed or
        keyOrOptions.handler or
        keyOrOptions.released or
        keyOrOptions.repeatFn or
        keyOrOptions.repeat_handler or
        keyOrOptions.description or
        keyOrOptions.use_hs_alert ~= nil
    ) then
        modifiers, key = M.parseHotkey(modifiersOrSpec)
        options = keyOrOptions or {}
    else
        modifiers = modifiersOrSpec or {}
        key = keyOrOptions
        if type(maybeOptions) == "table" then
            options = maybeOptions
        else
            options = {handler = maybeOptions}
        end
    end

    options = options or {}
    modifiers = modifiers or {}

    if not key then
        log.e("Unable to bind hotkey: key is missing")
        return nil
    end

    if type(modifiers) ~= "table" then
        log.e(string.format("Unable to bind hotkey '%s': modifiers must be a table", tostring(key)))
        return nil
    end

    local pressed = options.pressed or options.handler
    local released = options.released
    local repeatFn = options.repeatFn or options.repeat_handler or options.repeated
    local description = options.description
    local useHsAlert = options.use_hs_alert and description ~= nil

    if type(pressed) ~= "function" then
        log.w(string.format("Hotkey '%s' has no pressed handler; binding noop handler.", tostring(key)))
    end

    pressed = ensureHandler(pressed, false)
    released = ensureHandler(released, true)
    repeatFn = ensureHandler(repeatFn, true)

    local binding
    local hasDescription = type(description) == "string" and description ~= ""

    if useHsAlert and not hasDescription then
        log.w(string.format("Hotkey '%s' requested default alert but no description provided; disabling alert.", tostring(key)))
        useHsAlert = false
    end

    local announcementContext = buildAnnouncementContext(options, modifiers, key, description)
    local wrappedPressed = attachAnnouncementHandler(pressed, key, announcementContext)

    if hasDescription and not useHsAlert then
        local newBinding = hotkey.new(modifiers, key, nil, wrappedPressed, released, repeatFn)
        if not newBinding then
            log.e(string.format("Failed to allocate hotkey '%s'", tostring(key)))
            return nil
        end

        newBinding.msg = buildMessage(modifiers, key, description)

        local enabled = newBinding:enable()
        if not enabled then
            log.e(string.format("Failed to enable hotkey '%s'", tostring(key)))
            return nil
        end
        binding = enabled
    elseif hasDescription then
        binding = hotkey.bind(modifiers, key, description, wrappedPressed, released, repeatFn)
    else
        binding = hotkey.bind(modifiers, key, wrappedPressed, released, repeatFn)
    end

    if type(options.on_bind) == "function" then
        local ok, err = pcall(options.on_bind, binding)
        if not ok then
            log.w(string.format("on_bind callback failed for hotkey '%s': %s", tostring(key), tostring(err)))
        end
    end

    if binding then
        local modulePrefix = options.module and string.format("[%s] ", tostring(options.module)) or ""
        local base = buildMessage(modifiers, key, nil)
        local descriptionPart = hasDescription and string.format(" : %s", description) or ""
        log.i(string.format("%sBound hotkey %s%s", modulePrefix, base, descriptionPart))
    end

    return binding
end

return M
