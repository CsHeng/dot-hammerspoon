# Display Utils

## Role
- Encapsulates screen and frame calculations used by window and visualisation modules.
- Provides cross-display awareness without replicating geometry logic across modules.

## Capabilities
- Retrieve the main screen, currently focused screen, or screen under the mouse pointer.
- Normalise frames with configurable margins and tolerances for edge-aware window placement.
- Offer helpers for aligning windows to halves/quarters and for determining whether a point resides within a screen.
- Translate rectangles between absolute coordinates and per-screen coordinates, easing multi-monitor support.

## Entry Points
- Implementation: `utils/display_utils.lua`.
- Primary consumers: `modules/window_management.lua`, `modules/window_expose.lua`, `utils/window_utils.lua`, and visual modules such as the KeyCastr overlay.

## Configuration Touchpoints
- `config/window` defaults (tolerance, quarter tolerance, edge margins) shape how window utilities snap and align.
- Margin values are consumed by downstream modules; adjust them in configuration rather than hardcoding new constants.

## Observability
- Logs significant calculations when debug logging is enabled, helping diagnose edge cases like mismatched screen IDs.
- Functions return descriptive errors or `nil` when inputs are invalid, encouraging caller-side validation.

## Maintenance Notes
- Keep geometry helpers pure; avoid side effects so they remain safe for reuse across modules.
- When macOS introduces new coordinate behaviours (e.g., display scaling changes), update this utility first so all modules benefit.
