-- Hotkey utilities to standardize binding behavior across the config.
-- Provides parsing helpers and centralizes whether Hammerspoon shows its
-- built-in alert when a hotkey fires.

local hotkey = require("hs.hotkey")
local logger = require("core.logger")

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

    if hasDescription and not useHsAlert then
        local newBinding = hotkey.new(modifiers, key, nil, pressed, released, repeatFn)
        if not newBinding then
            log.e(string.format("Failed to allocate hotkey '%s'", tostring(key)))
            return nil
        end

        local originalMsg = newBinding.msg or ""
        if originalMsg ~= "" then
            newBinding.msg = string.format("%s: %s", originalMsg, description)
        else
            newBinding.msg = description
        end

        local enabled = newBinding:enable()
        if not enabled then
            log.e(string.format("Failed to enable hotkey '%s'", tostring(key)))
            return nil
        end
        binding = enabled
    elseif hasDescription then
        binding = hotkey.bind(modifiers, key, description, pressed, released, repeatFn)
    else
        binding = hotkey.bind(modifiers, key, pressed, released, repeatFn)
    end

    if type(options.on_bind) == "function" then
        local ok, err = pcall(options.on_bind, binding)
        if not ok then
            log.w(string.format("on_bind callback failed for hotkey '%s': %s", tostring(key), tostring(err)))
        end
    end

    return binding
end

return M
