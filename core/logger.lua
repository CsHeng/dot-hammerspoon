-- Centralized logging system for Hammerspoon configuration
-- Provides consistent logging across all modules with hierarchical configuration

local M = {}

-- Use Hammerspoon's built-in log levels
-- Valid levels: 'debug', 'info', 'warning', 'error'
local DEFAULT_LOG_LEVEL = "warning"

-- Cached config module reference (nil until config_loader is fully loaded)
local configModule = nil

-- Get effective log level for a module
-- Priority: module-specific > global > hardcoded default
local function getEffectiveLevel(moduleName)
    -- Try to get config module if not cached
    if not configModule then
        -- Check if config_loader is fully loaded (not in the middle of loading)
        local loaded = package.loaded["core.config_loader"]
        if loaded and type(loaded.get) == "function" then
            configModule = loaded
        else
            return DEFAULT_LOG_LEVEL
        end
    end

    -- Check module-specific override in modules table
    local modules = configModule.get("logging.modules", {})
    if modules and modules[moduleName] then
        return modules[moduleName]
    end

    -- Global level from config
    return configModule.get("logging.global_level", DEFAULT_LOG_LEVEL)
end

-- Set global log level (legacy API, kept for compatibility)
function M.setLogLevel(level)
    local validLevels = {'debug', 'info', 'warning', 'error'}
    local isValid = false

    for _, validLevel in ipairs(validLevels) do
        if level == validLevel then
            isValid = true
            break
        end
    end

    if isValid then
        DEFAULT_LOG_LEVEL = level
    else
        error(string.format("Invalid log level: %s. Valid levels: %s",
              level, table.concat(validLevels, ", ")))
    end
end

-- Get or create a logger for a specific module
function M.getLogger(moduleName)
    local level = getEffectiveLevel(moduleName)
    return hs.logger.new(moduleName, level)
end

-- Helper functions for common logging patterns
function M.logFunctionCall(moduleName, funcName, ...)
    local logger = M.getLogger(moduleName)
    local args = {...}
    local argsStr = {}

    for _, arg in ipairs(args) do
        table.insert(argsStr, tostring(arg))
    end

    logger:d(string.format("%s called with args: %s", funcName, table.concat(argsStr, ", ")))
end

function M.logHotkeyEvent(moduleName, hotkeyDesc, action)
    local logger = M.getLogger(moduleName)
    logger:i(string.format("Hotkey triggered: %s -> %s", hotkeyDesc, action))
end

function M.logError(moduleName, error, context)
    local logger = M.getLogger(moduleName)
    local contextStr = context and " (" .. context .. ")" or ""
    logger:e(string.format("Error%s: %s", contextStr, tostring(error)))
end

return M
