# Config Loader

## Role
- Centralises configuration loading, default management, and validation for the entire Hammerspoon configuration.
- Exposes a stable API for modules to query settings without worrying about file layout or merge behaviour.

## Capabilities
- Seeds configuration with baked-in defaults defined inside `core/config_loader.lua`.
- Loads user overrides from `config/*.lua` (`hotkeys`, `applications`, `keycastr`, `wifi`, `visual`, `mouse`) and recursively merges them with defaults.
- Offers `get`, `set`, `cloneTable`, and `mergeTables` helpers so modules can fetch or mutate settings safely.
- Runs validation after load to flag malformed hotkeys or application entries, logging warnings while keeping the configuration usable.

## Lifecycle
- Initialisation occurs immediately when the module is required; repeated calls to `M.init()` refresh the merged configuration.
- Validation issues are logged under `config_loader` but do not crash startup, favouring resilience over strict failure.
- New configuration files can be added by extending the `config_files` list within the loader.

## Entry Points
- Implementation: `core/config_loader.lua`.
- Primary consumers: all modules and utilities that call `config.get`/`config.set`.

## Observability
- Info logs indicate which configuration files were successfully loaded.
- Warnings enumerate validation issues (e.g., invalid hotkey definitions) with actionable context.
- `config_loader.getAll()` provides a cloned snapshot for debugging without exposing mutable state.

## Maintenance Notes
- Keep defaults exhaustive: new configuration surfaces should ship with sensible defaults to preserve deterministic startup.
- When introducing nested configuration, prefer tables over custom parsing logic so `mergeTables` can handle overrides automatically.
- Avoid placing secrets inside configuration files; rely on environment variables or external vaults as documented in security guidelines.
