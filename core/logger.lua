-- Centralized logging system for Hammerspoon configuration
-- Provides consistent logging across all modules

local M = {}

-- Use Hammerspoon's built-in log levels
-- Valid levels: 'debug', 'info', 'warning', 'error'
local DEFAULT_LOG_LEVEL = "warning"

-- Set global log level
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
    return hs.logger.new(moduleName, DEFAULT_LOG_LEVEL)
end

-- Helper functions for common logging patterns
function M.logFunctionCall(moduleName, funcName, ...)
    local logger = M.getLogger(moduleName)
    local args = {...}
    local argsStr = {}

    for i, arg in ipairs(args) do
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