-- Hotkey utilities to standardize binding behavior across the config.
-- Provides consistent logging and pluggable toast/notification behaviour.

local hotkey = require("hs.hotkey")
local logger = require("core.logger")
local notification_utils = require("utils.notification_utils")

-- Suppress hs.hotkey's own info-level logs; keep warnings/errors.
pcall(function()
    if type(hotkey.setLogLevel) == "function" then
        hotkey.setLogLevel("warning")
    end
end)

local log = logger.getLogger("hotkey_utils")

local M = {}

-- ---------------------------------------------------------------------------
-- Helpers
-- ---------------------------------------------------------------------------

local function ensureHandler(fn, allowNil)
    if type(fn) == "function" then
        return fn
    end
    if allowNil then
        return nil
    end
    return function() end
end

local function clone(value)
    if type(value) ~= "table" then
        return value
    end
    local copy = {}
    for k, v in pairs(value) do
        copy[k] = clone(v)
    end
    return copy
end

local function shallowCopy(tbl)
    if type(tbl) ~= "table" then
        return nil
    end
    local copy = {}
    for k, v in pairs(tbl) do
        copy[k] = v
    end
    return copy
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

local function buildCombo(modifiers, key)
    local mods = formatModifiers(modifiers)
    local base = mods .. formatKey(key)
    return base ~= "" and base or tostring(key)
end

local function buildMessage(modifiers, key, description)
    local combo = buildCombo(modifiers, key)
    if type(description) == "string" and description ~= "" then
        return string.format("%s: %s", combo, description)
    end
    return combo
end

local function normalizeToastSpec(spec)
    if spec == nil then
        return nil
    end
    if spec == false then
        return false
    end
    if spec == true then
        return {}
    end

    local specType = type(spec)
    if specType == "table" then
        return shallowCopy(spec)
    elseif specType == "string" then
        return {message = spec}
    elseif specType == "number" then
        return {duration = spec}
    elseif specType == "function" then
        return {message_fn = spec}
    end

    return {}
end

local function buildBindingId(options, combo)
    if type(options.id) == "string" and options.id ~= "" then
        return options.id
    end
    if type(options.description) == "string" and options.description ~= "" then
        return (options.description:gsub("%s+", "_"):gsub("[^%w_%-]", "")):lower()
    end
    local sanitized = combo:gsub("[^%w]+", "_"):gsub("_+", "_"):gsub("^_", ""):gsub("_$", "")
    if sanitized == "" then
        sanitized = "hotkey"
    end
    return sanitized:lower()
end

local function buildLogLabel(moduleName, combo, description, label)
    local target = label or description
    if type(target) ~= "string" or target == "" then
        target = combo
    end
    if moduleName then
        return string.format("[%s] %s -> %s", moduleName, combo, target)
    end
    return string.format("%s -> %s", combo, target)
end

local function computeToastPayload(baseMessage, toastSpec)
    local payload = {}
    if type(toastSpec) == "table" then
        for k, v in pairs(toastSpec) do
            payload[k] = v
        end
    elseif toastSpec == nil or toastSpec == true then
        -- rely entirely on configuration defaults
    elseif type(toastSpec) == "string" then
        payload.message = toastSpec
    elseif type(toastSpec) == "number" then
        payload.duration = toastSpec
    elseif type(toastSpec) == "function" then
        payload.message_fn = toastSpec
    end

    payload.default_message = payload.default_message or baseMessage

    return payload
end

local function wrapPressedHandler(moduleName, bindingId, baseMessage, toastSpec, pressedHandler)
    pressedHandler = ensureHandler(pressedHandler, false)

    if toastSpec == false then
        return pressedHandler
    end

    local normalizedSpec = normalizeToastSpec(toastSpec)
    local shouldAnnounce = false

    if normalizedSpec and normalizedSpec.force == true then
        shouldAnnounce = true
    elseif moduleName or bindingId then
        shouldAnnounce = notification_utils.shouldAnnounce(moduleName, bindingId, normalizedSpec)
    elseif normalizedSpec then
        shouldAnnounce = true
    end

    if not shouldAnnounce then
        return pressedHandler
    end

    local payload = computeToastPayload(baseMessage, normalizedSpec)
    local callBefore = payload.call_before and true or false
    payload.call_before = nil

    payload.metadata = payload.metadata or {}
    payload.metadata.hotkey = payload.metadata.hotkey or baseMessage
    payload.metadata.id = payload.metadata.id or bindingId
    payload.metadata.module = payload.metadata.module or moduleName

    local function dispatch()
        local ok, err = pcall(notification_utils.announce, moduleName, bindingId, clone(payload))
        if not ok then
            log.w(string.format("Announcement failed for hotkey '%s': %s", tostring(bindingId), tostring(err)))
        end
    end

    if callBefore then
        return function(...)
            dispatch()
            return pressedHandler(...)
        end
    end

    return function(...)
        local results = table.pack(pressedHandler(...))
        dispatch()
        return table.unpack(results, 1, results.n)
    end
end

-- ---------------------------------------------------------------------------
-- Public API
-- ---------------------------------------------------------------------------

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

    local moduleName = options.module
    local description = options.description
    local logLabel = options.log_label

    local pressed = options.pressed or options.handler
    local released = options.released
    local repeatFn = options.repeatFn or options.repeat_handler or options.repeated
    local toastSpec = options.toast
    if toastSpec == nil then
        toastSpec = options.announce
    end

    local combo = buildCombo(modifiers, key)
    local bindingId = buildBindingId(options, combo)
    local message = buildMessage(modifiers, key, description)

    if type(pressed) ~= "function" then
        log.w(string.format("Hotkey '%s' has no pressed handler; binding noop handler.", tostring(combo)))
    end

    pressed = wrapPressedHandler(moduleName, bindingId, message, toastSpec, pressed)
    released = ensureHandler(released, true)
    repeatFn = ensureHandler(repeatFn, true)

    local useHsAlert = options.use_hs_alert and (type(description) == "string" and description ~= "")
    local binding

    if useHsAlert then
        binding = hotkey.bind(modifiers, key, description, pressed, released, repeatFn)
    else
        binding = hotkey.bind(modifiers, key, pressed, released, repeatFn)
    end

    if type(options.on_bind) == "function" then
        local ok, err = pcall(options.on_bind, binding)
        if not ok then
            log.w(string.format("on_bind callback failed for hotkey '%s': %s", tostring(combo), tostring(err)))
        end
    end

    local entry = buildLogLabel(moduleName, combo, description, logLabel)
    if type(options.logger) == "table" and type(options.logger.i) == "function" then
        options.logger.i(entry)
    else
        hs.printf("[hotkeys] %s", entry)
    end

    return binding
end

return M
