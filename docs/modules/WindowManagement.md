# Window Management

## Role
- Provides keyboard-driven window positioning inspired by tools like Magnet, supporting halves, quarters, maximise, centre, and restore.

## Capabilities
- Move windows to halves/quadrants with configurable tolerances so repeated commands snap predictably.
- Store and restore original frames, enabling round-trip moves without manual adjustments.
- Handle multi-monitor setups by factoring in screen frames and safe margins.
- Offer helper functions for chaining movements and handling edge cases (e.g., menu bar offsets).

## Configuration
- `config/hotkeys.window.*` defines the shortcut layout (hyper keys, arrow combinations).
- `config/window` (defaults in `core/config_loader.lua`) adjust tolerance, quarter tolerance, and edge margins.

## Entry Points
- Implementation: `modules/window_management.lua`.
- Supporting utilities: `utils/window_utils.lua` and `utils/display_utils.lua`.

## Observability
- Logs each window move, including the target region and resulting frame when debug logging is enabled.
- Debug helpers summarise stored frames and tolerance values for diagnosing layout issues.

## Maintenance Notes
- Keep tolerance configuration in the loader to enable dynamic adjustments without code changes.
- When adding new layout patterns, build them using window utility helpers to avoid duplicating geometry logic.
