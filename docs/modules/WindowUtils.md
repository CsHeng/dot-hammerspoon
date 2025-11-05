# Window Utils

## Role
- Supplies reusable helpers for querying, filtering, and manipulating windows independent of specific feature modules.

## Capabilities
- Enumerate windows per screen, by app, or by visibility state.
- Determine window eligibility (standard, visible) to keep automation focused on user-facing windows.
- Store and retrieve original frames to support restore operations.
- Offer alignment helpers (centre, maximise) reused by window management and expose modules.

## Entry Points
- Implementation: `utils/window_utils.lua`.
- Primary consumers: `modules/window_management.lua`, `modules/window_expose.lua`, and diagnostic helpers.

## Maintenance Notes
- Keep the API stateless; callers provide the window objects and receive computed data without side effects.
- When macOS window APIs change, update this utility first so higher-level modules continue to work unchanged.
