# System Architecture

## High-Level View
- **Bootstrap**: `init.lua` configures lazy bindings, initialises the config loader, and delegates to `core.init_system`.
- **Core Services**: `core/config_loader.lua`, `core/init_system.lua`, and `core/logger.lua` provide configuration, lifecycle, and logging foundations.
- **Utilities**: `utils/` houses reusable helpers (hotkeys, apps, displays, notifications, window math).
- **Feature Modules**: `modules/` implements user-facing automation (window management, app launcher, media controls, mouse automation, etc.).
- **Documentation & Diagrams**: conceptual notes live in `docs/`; PlantUML diagrams now reside in `docs/diagrams/`.

## Execution Flow
1. Configuration defaults load and merge with user overrides.
2. Core utilities initialise; modules register themselves with the init system.
3. Feature modules run `init`, setting up hotkeys, event taps, or watchers.
4. Lazy modules wait for user-triggered hotkeys before performing heavy initialisation.
5. Debug helpers (e.g., `hs.debugHammerspoon.status()`) summarise active modules and services.

## Design Principles
- **Modularity**: Each feature encapsulates its responsibilities and interacts with shared utilities through well-defined interfaces.
- **Fail-Fast**: Modules log and exit early on invalid configuration or unavailable APIs to avoid silent failures.
- **Single Source of Truth**: Behavioural details live in code and inline comments; documentation focuses on capabilities and integration points.
- **Observability**: Consistent logging via `core.logger` and deliberate alerts keep automation transparent.

## Extending the System
- Add new modules under `modules/` and register them with `core.init_system`.
- Extend configuration through `config/*.lua` and document new keys alongside module summaries.
- Use `utils/hotkey_utils.lua` for all hotkey bindings to maintain announcement policy cohesion.
- Update diagrams in `docs/diagrams/` as architecture evolves; validate using `plantuml --check-syntax`.
