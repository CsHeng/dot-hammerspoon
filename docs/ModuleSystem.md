# Module System

## Role
- Establishes conventions for building modular Hammerspoon features that can load independently yet share infrastructure.

## Conventions
- Each feature lives inside `modules/` and returns a table with lifecycle functions (`init`, `stop`, `restart`, etc.).
- Modules register themselves with `core.init_system` to participate in startup and debugging workflows.
- Shared utilities belong under `utils/` and avoid direct side effects during require-time to keep load order flexible.

## Dependency Management
- Modules declare dependencies during registration; the init system loads utilities first before invoking feature initialisers.
- Lazy modules (e.g., window expose) may defer heavy setup until triggered, but should still register with the init system for visibility.

## Integration
- Boot sequence: `init.lua` → `core.init_system` → registered modules.
- Configuration toggles (e.g., selecting a mouse management variant) determine which module implementations are registered at runtime.

## Maintenance Notes
- Follow existing patterns when adding new modules: isolate configuration access, use the shared logger, and expose debug helpers.
- Keep modules self-contained; cross-module communication should occur through utilities or explicit function calls rather than global state.
