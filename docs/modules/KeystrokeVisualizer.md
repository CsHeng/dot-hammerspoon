# Keystroke Visualizer

## Role
- Implements a configurable KeyCastr-style overlay with toggleable features for demonstrations and live streams.

## Capabilities
- Toggle keystroke display, click-circle drawing, and continuous text mode via dedicated hotkeys.
- Render events using `hs.canvas`, respecting configurable font sizes, colours, margins, and fade durations.
- Track mouse clicks and drag gestures when enabled, updating the overlay position or showing click indicators.
- Maintain configurable history length, ensuring on-screen items expire gracefully.

## Configuration
- `config/keycastr.lua` defines enablement, visuals, behaviour flags, and click-circle parameters.
- Hotkeys sourced from `config/hotkeys.keycastr.*`; bindings are registered through `hotkey_utils` with module context.
- Runtime toggles call `config.set` so preferences persist within the session and across reloads.

## Entry Points
- Implementation: `modules/keystroke_visualizer.lua`.
- Related utilities: `utils/notification_utils.lua` for on/off alerts, `utils/display_utils.lua` for positioning helpers.

## Observability
- Logs every toggle, event drawing, and cleanup action through the `keystroke_visualizer` logger.
- Alerts when features are toggled to give immediate feedback without cluttering logs.
- Debug helpers (`M.debug`) summarise enablement state and display metrics.

## Maintenance Notes
- Keep drawing code resilient to missing configuration keys by falling back to defaults supplied by the config loader.
- Prefer incremental additions (new modes, new visuals) rather than rewriting the overlay pipeline to preserve stability.
