# Init System

## Role
- Coordinates module discovery, registration, and lazy loading for the configuration.
- Ensures modules initialise in a deterministic order while respecting dependencies.

## Mechanics
- Modules call `core.init_system.registerModule(name, hooks)` to register their lifecycle functions.
- During startup, `init_system` loads required utilities, initialises modules in registration order, and tracks module counts for diagnostics.
- Lazy-loaded features (e.g., window switcher) register their own hotkeys and defer heavy setup until the user triggers them.

## Responsibilities
- Maintain a registry of module descriptors containing `init`, `stop`, `restart`, and dependency metadata.
- Provide helper methods to start, stop, or reload individual modules, primarily for debugging from the Hammerspoon console.
- Expose module information for status reporting (`hs.debugHammerspoon.status()`).

## Integration
- Implementation: `core/init_system.lua`.
- Consumers: each module file calls `registerModule` near the end of its definition.
- Lazy bootstrap hooks in `init.lua` rely on this system to load modules on demand.

## Observability
- Prints module registration events at startup, including the total number of modules loaded.
- Errors during module initialisation are surfaced through module-specific loggers to keep troubleshooting targeted.

## Maintenance Notes
- Register new modules in their respective files; avoid modifying the init system directly unless adding new lifecycle phases.
- Keep dependency lists accurate so modules load in the correct order (e.g., utilities before consumers).
