# AI Instructions

For project overview, hotkey reference, and setup instructions, see [README.md](./README.md).

## Stable Display Boundaries

- `displayplacer` is the layout tool. Use it for profile detection, screen arrangement, origin placement, resolution, and primary-display repair.
- `m1ddc` is the monitor-control tool. Use it for DDC features such as input source, brightness, contrast, and volume.
- Do not treat `m1ddc` as a replacement for `displayplacer`; it does not manage macOS display topology.
- Do not rely on `displayplacer enabled:false/enabled:true` as a reversible second-monitor toggle. On this setup it is not a stable restore path.
- `⌃⌘⌥D` mirrors/unmirrors the second external display and runs a best-effort `m1ddc` input command for `home`, `home_open`, `office`, `office_open`, `office_typec`, and `office_typec_open`.
- Home second external `DQ27F165L` (`D0627D9C-EEDB-417D-88ED-C5FE3663710D`): Mac `DisplayPort 1` -> `15`; alternate `HDMI 1` -> `17`. The home chain currently goes through a Dell Thunderbolt dock and hardware KVM, so `m1ddc` may return success without physically switching display input; accepted workflow is mirror first, switch away with the hardware KVM, use the second machine, then switch the KVM back.
- Office second external `DELL P2422H` (`E5AD9F0D-0529-4234-ABF2-4053381A7C58`): Mac `DisplayPort 1` -> `15`; alternate `HDMI 1` -> `17`.
- Switching away first applies mirror mode via `displayplacer`, saves non-Mac-input state to suppress auto-repair, then sends the alternate-input command via `m1ddc`; switching back restores extended layout from stored `profile_key` before sending the Mac-input command.
- `⌃⌘⌥L` repairs layout and, when needed, restores the supported second external to Mac input.

## Hotkey Management

- All hotkeys use `utils/hotkey_utils.lua` for standardized binding
- User-editable hotkey combinations live in `config/hotkeys.lua`
- Feature modules keep local fallback defaults for their own bindings
- Configurable toast notifications for hotkey triggers
- Module-specific announcement preferences via `hotkeys_announcements.modules`

## Mouse Button Boundary

- Browser middle-click fallback to Mission Control is an accepted no-fix boundary.
- Preserve native Chrome, Edge, and Safari middle-click behavior for tab close and background-link-open workflows.
- Do not reopen this as a bug or implement page-background fallback unless explicitly requested; `hs.eventtap` cannot reliably detect that a browser did not consume a propagated middle-click.

## Architecture Boundaries

- `init.lua` registers modules and lazy-loads heavy behavior.
- `core/config_loader.lua` owns defaults, config-file merges, validation, and hot reload.
- `core/init_system.lua` owns module registration, dependency resolution, initialization order, and status tracking.
- Feature modules depend on core services and utilities; avoid feature-module dependencies.
- Use `utils/hotkey_utils.lua` for hotkey binding, with binding logs, KeyCastr visibility, and toast or notification announcements treated as independent outputs.
- Utility modules in `utils/` provide reusable helper functions with minimal dependencies and return a module table.
- Detailed runtime checks, module edit patterns, and mined failure boundaries live in the repo-local Hammerspoon Runtime Verify guide.

## Working with This Codebase

- Hotkey combinations: only edit `config/hotkeys.lua`
- Applications: edit `config/applications.lua`
- Defaults and checks: edit `core/config_loader.lua`
- Lua formatting: use `.stylua.toml`; keep repo-wide formatting-only changes separate from behavior changes unless explicitly requested.
- Hotkey bindings: use expanded `hotkey_utils.bind(spec, { ... })` option-table blocks. Do not hide binding metadata behind positional wrapper helpers.
- Module status: use `require("core.init_system").getModuleStatus()`
- Debug console: use `hs.debugHammerspoon.status()`
- For behavior, hotkey, notification, mouse, display, or docs/code-drift changes, use the repo-local Hammerspoon Runtime Verify guide before editing.

## Checks

- Check PlantUML diagrams: `plantuml --check-syntax <diagram-path>`
- Test modules: Use `hs.reload()` after changes, check console for loading messages
- No automated tests; relies on configuration checks, module loading status, hotkey binding logging, and manual testing

## Documentation

- Keep human-oriented overview and hotkey reference in `README.md`.
- Keep AI-specific operating rules and constraints in `AGENTS.md`.
- Keep `CLAUDE.md` as a symlink to `AGENTS.md`.
- Treat root `README.md`, root `AGENTS.md`, and `docs/modules/*.md` as stable truth roots.
- Treat `docs/plans/` as stage artifacts retained for history; it is excluded from default docs search by `docs/.ignore`.
- Update module docs in `docs/modules/`.
- Add/update PlantUML diagrams in `docs/diagrams/`.
- Keep `docs/SystemArchitecture.md` in sync with architectural changes
- Check PlantUML syntax before finalizing
