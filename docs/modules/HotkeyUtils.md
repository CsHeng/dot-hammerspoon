# Hotkey Utils

## Role
- Central binding helper that keeps shortcut registration consistent across modules.
- Encapsulates parsing, lifecycle management, and notification policy so individual modules stay focused on behaviour.

## Capabilities
- Accepts both array-style and structured hotkey specifications, normalising them into modifier/key pairs.
- Guards against missing handlers and surfaces configuration mistakes through module-aware logging.
- Provides optional repeat and release handlers without requiring every caller to reference `hs.hotkey` directly.
- Applies the new announcement policy so modules opt into toast overlays through configuration instead of hardcoding behaviour.

## Announcement Control
- Module-specific overlays are governed by `hotkeys.announcements` and `hotkeys.announcements.modules` in `config/hotkeys.lua`.
- Descriptions remain available for logs even when overlays are disabled; the helper records a module-tagged info log on every bind.
- Use `options.module = "<module_name>"` when binding so the helper can honour the per-module toggle.

## Integration Points
- Implementation: `utils/hotkey_utils.lua`.
- Consumers: every feature module (`modules/app_launcher.lua`, `modules/media_controls.lua`, `modules/keystroke_visualizer.lua`, `modules/mouse_management*.lua`, etc.).
- Configuration source: `config/hotkeys.lua`.

## Observability
- Binding outcomes emit `hotkey_utils` info logs in the form `[module] Bound hotkey ctrl+alt+X : Description`.
- Modules can pass `options.on_bind` for additional instrumentation or to retain the binding reference.
- Default behaviour suppresses Hammerspoon toast overlays unless explicitly enabled for a module or binding.

## Maintenance Notes
- Keep new modules using this helper; direct calls to `hs.hotkey.bind` should be limited to bootstrap code that lazy-loads modules.
- When adding new configuration flags, extend the helper rather than duplicating parsing logic inside feature modules.
