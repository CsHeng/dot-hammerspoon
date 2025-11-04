-- Module initialization system for Hammerspoon
-- Handles module loading, dependency management, and initialization order

local logger = require("core.logger")
local config = require("core.config_loader")

local log = logger.getLogger("init_system")

local M = {}

-- Module registry
local modules = {}
local loaded_modules = {}
local loading_order = {}

-- Define module dependencies
local mouse_module_name = config.get("mouse.management_module", "modules.mouse_management")

local module_dependencies = {
    -- Core modules (no dependencies)
    "utils.app_utils",
    "utils.display_utils",
    "utils.notification_utils",
    "utils.window_utils",

    -- Feature modules (depend on utils)
    "modules.window_management",
    "modules.app_launcher",
    "modules.media_controls",
    mouse_module_name,
    "modules.wifi_automation",
    "modules.keystroke_visualizer",
    "modules.notch_hider"
}

-- Register a module
function M.registerModule(name, module_def)
    modules[name] = {
        init = module_def.init or function() end,
        dependencies = module_def.dependencies or {},
        loaded = false,
        config = module_def.config or {}
    }
    log:d(string.format("Registered module: %s", name))
end

-- Check if module dependencies are satisfied
local function checkDependencies(module_name)
    local module = modules[module_name]
    if not module then
        return false, string.format("Module %s not found", module_name)
    end

    for _, dep in ipairs(module.dependencies) do
        if not loaded_modules[dep] then
            return false, string.format("Missing dependency: %s (required by %s)", dep, module_name)
        end
    end

    return true
end

-- Load a single module
local function loadModule(module_name)
    if loaded_modules[module_name] then
        log:d(string.format("Module %s already loaded", module_name))
        return true
    end

    local module = modules[module_name]
    if not module then
        log:e(string.format("Module %s not registered", module_name))
        return false
    end

    -- Check dependencies
    local deps_ok, deps_error = checkDependencies(module_name)
    if not deps_ok then
        log:e(deps_error)
        return false
    end

    -- Load the module
    log:i(string.format("Loading module: %s", module_name))

    local success, err = pcall(function()
        -- Initialize module configuration
        if module.config and type(module.config) == "function" then
            module.config()
        end

        -- Initialize module
        module.init()
    end)

    if success then
        loaded_modules[module_name] = true
        table.insert(loading_order, module_name)
        log:i(string.format("Successfully loaded module: %s", module_name))
        return true
    else
        log:e(string.format("Failed to load module %s: %s", module_name, err))
        return false
    end
end

-- Load all modules in dependency order
function M.loadAllModules()
    log:i("Starting module loading process")

    -- First pass: load modules that have no dependencies
    for _, module_name in ipairs(module_dependencies) do
        local module = modules[module_name]
        if module and #module.dependencies == 0 then
            loadModule(module_name)
        end
    end

    -- Second pass: load remaining modules
    local attempts = 0
    local max_attempts = 10

    while attempts < max_attempts do
        local loaded_something = false

        for _, module_name in ipairs(module_dependencies) do
            if not loaded_modules[module_name] then
                if loadModule(module_name) then
                    loaded_something = true
                end
            end
        end

        if loaded_something then
            attempts = 0
        else
            attempts = attempts + 1
        end
    end

    -- Report loading results
    local total_modules = #module_dependencies
    local loaded_count = 0
    for _, module_name in ipairs(module_dependencies) do
        if loaded_modules[module_name] then
            loaded_count = loaded_count + 1
        end
    end

    log:i(string.format("Module loading complete: %d/%d modules loaded", loaded_count, total_modules))

    -- Log loading order
    log:i("Module loading order: " .. table.concat(loading_order, " -> "))

    return loaded_count == total_modules
end

-- Reload a specific module
function M.reloadModule(module_name)
    log:i(string.format("Reloading module: %s", module_name))

    -- Clear loaded state
    loaded_modules[module_name] = nil

    -- Remove from loading order
    for i, name in ipairs(loading_order) do
        if name == module_name then
            table.remove(loading_order, i)
            break
        end
    end

    -- Attempt to reload
    return loadModule(module_name)
end

-- Get module status
function M.getModuleStatus()
    local status = {}

    for _, module_name in ipairs(module_dependencies) do
        local module = modules[module_name]
        status[module_name] = {
            loaded = loaded_modules[module_name] or false,
            dependencies = module and module.dependencies or {},
            dependencies_satisfied = module and checkDependencies(module_name)
        }
    end

    return status
end

-- Get loading order
function M.getLoadingOrder()
    return M.cloneTable(loading_order)
end

-- Check if all modules are loaded
function M.allModulesLoaded()
    for _, module_name in ipairs(module_dependencies) do
        if not loaded_modules[module_name] then
            return false
        end
    end
    return true
end

-- Initialize the module system
function M.init()
    log:i("Initializing module system")

    -- Register configuration modules first
    M.registerModule("utils.app_utils", {
        init = function()
            -- Will be loaded when utils/app_utils.lua is required
        end,
        dependencies = {}
    })

    M.registerModule("utils.display_utils", {
        init = function()
            -- Will be loaded when utils/display_utils.lua is required
        end,
        dependencies = {}
    })

    M.registerModule("utils.notification_utils", {
        init = function()
            -- Will be loaded when utils/notification_utils.lua is required
        end,
        dependencies = {}
    })

    M.registerModule("utils.window_utils", {
        init = function()
            -- Will be loaded when utils/window_utils.lua is required
        end,
        dependencies = {}
    })

    -- Register modules that are lazy-loaded or have special loading
    M.registerModule("modules.notch_hider", {
        init = function()
            -- Will be loaded when modules/notch_hider.lua is required
        end,
        dependencies = {
            "utils.display_utils"
        }
    })

    log:i("Module system initialized")
end

-- Initialize on load
M.init()

return M
