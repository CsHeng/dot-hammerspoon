# Configuration System

## Role
- Defines how defaults, user overrides, and live mutations combine to drive module behaviour.
- Keeps configuration declarative so feature modules remain stateless and easy to reload.

## Building Blocks
- **Core loader**: `core/config_loader.lua` seeds defaults and merges `config/*.lua` overrides.
- **Module wiring**: `core/init_system.lua` asks the loader which modules to register (e.g., `mouse.management_module`).
- **Runtime updates**: modules call `config.set` to persist toggles (such as KeyCastr enablement) back into the shared store.

## Data Flow
1. Defaults are cloned into memory during loader initialisation.
2. Each file listed in the loader (`hotkeys`, `applications`, `keycastr`, `wifi`, `visual`, `mouse`) is required and merged in.
3. Validation runs once to flag structural issues without aborting startup.
4. Modules consume values via `config.get("section.key")`, optionally supplying fallbacks for optional settings.

## Extending Configuration
- Add a new config file under `config/` and register it in the loader’s `config_files` list.
- Document new keys alongside the module that consumes them; prefer nested tables to keep namespaces clear.
- When exposing booleans or enumerations, default them in `core/config_loader.lua` so hot reload works even before user overrides exist.

## Observability
- Loader logs every file it successfully merges, and issues warnings when modules or keys are missing.
- Modules should log the configuration they depend on during initialisation, mirroring the behaviour in window, mouse, and media modules.
- Use `hs.inspect(config_loader.getAll())` from the console for ad-hoc debugging; the result is a deep clone and safe to inspect.

## Maintenance Notes
- Keep configuration focused on behaviour, not implementation details—code should remain the source of truth for algorithms.
- Avoid storing secrets or machine-specific paths; rely on environment variables or macOS services for sensitive data.
- The configuration store is mutable in memory; treat it as stateful and isolate write-backs to user-facing toggles.
