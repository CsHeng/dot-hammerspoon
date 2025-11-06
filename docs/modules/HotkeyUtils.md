# Hotkey Utils

## Role
- Central binding helper that keeps shortcut registration consistent across modules.
- Encapsulates parsing, lifecycle management, and notification policy so individual modules stay focused on behaviour.

## Capabilities
- Accepts both array-style and structured hotkey specifications, normalising them into modifier/key pairs.
- Guards against missing handlers and surfaces configuration mistakes through module-aware logging.
- Provides optional repeat and release handlers without requiring every caller to reference `hs.hotkey` directly.
- Decouples notifications from descriptions; modules opt into toast overlays through the `options.toast` table while logging stays consistent.

## Announcement Control
- Module-level defaults come from `hotkeys.announcements` in `config/hotkeys.lua`; binding-level overrides merge in when `options.toast` supplies `id`, `enabled`, or `override` fields.
- Logging is independent from toast policy—the helper emits a module-tagged info log on every bind so bindings stay observable even when overlays are disabled.
- Always supply `options.module = "<module_name>"` and, when useful, `options.id` so configuration can reference the binding precisely.

## Integration Points
- Implementation: `utils/hotkey_utils.lua`.
- Consumers: every feature module (`modules/app_launcher.lua`, `modules/media_controls.lua`, `modules/keystroke_visualizer.lua`, `modules/mouse_management*.lua`, etc.).
- Configuration source: `config/hotkeys.lua`.

## Observability
- Binding outcomes emit console lines in the form `[hotkeys] [module] ⌃⌥X -> Action Label`, keeping registration transparent even without toasts.
- Modules can pass `options.on_bind` for additional instrumentation or to retain the binding reference.
- Default behaviour suppresses Hammerspoon toast overlays unless `options.toast` (or configuration) explicitly enables them.

## Maintenance Notes
- Keep new modules using this helper; direct calls to `hs.hotkey.bind` should be limited to bootstrap code that lazy-loads modules.
- When adding new configuration flags, extend the helper rather than duplicating parsing logic inside feature modules.
