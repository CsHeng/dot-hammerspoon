-- Logging configuration
-- Override global and per-module log levels

return {
    logging = {
        -- Global default log level for all modules
        -- Valid levels: 'debug', 'info', 'warning', 'error'
        global_level = "warning",

        -- Per-module log level overrides
        modules = {
            -- display_layout = "debug",
        }
    }
}
