---
name: hammerspoon-runtime-verify
description: Use when working in /Users/csheng/.hammerspoon on Hammerspoon behavior, hotkeys, notifications, mouse handling, display layout, displayplacer, m1ddc, hs APIs, runtime logs, or docs/code drift before changing Lua modules or docs.
---

# Hammerspoon Runtime Verify

## Overview

Use runtime evidence and source checks before changing this Hammerspoon config. Keep built-in `hs.*` behavior, external CLI adapters, feature modules, and documentation sync as separate boundaries.

## Start Here

- If the user says analysis-only, discussion-only, or asks to confirm feasibility, stay read-only.
- Read `/Users/csheng/.hammerspoon/AGENTS.md` for stable local boundaries, then verify behavior against source.
- Check working-tree state before edits:

```bash
git -C /Users/csheng/.hammerspoon status --short
```

## Boundary Decision

Classify the task before proposing a fix:

| Boundary | Examples | Preferred evidence |
|---|---|---|
| Hammerspoon built-ins | `hs.hotkey`, `hs.eventtap`, `hs.notify`, `hs.screen`, `hs.spaces`, `hs.window` | Lua source, Hammerspoon docs/API behavior, console logs |
| External CLI adapters | `displayplacer`, `m1ddc`, command construction, output parsing, exit codes | `command -v`, real command output, parsed command contract |
| Feature modules | app launcher, display layout, mouse, media, window management, wifi automation | module source, config path, hotkey binding logs |
| Docs and diagrams | `README.md`, `AGENTS.md`, `docs/*.md`, `docs/*.puml`, module diagrams | source-backed facts plus validators |

Do not collapse a CLI failure into an `hs.*` API conclusion. Do not treat a documented behavior as current until the corresponding Lua source has been checked.

## Mined Interaction Rules

- Prefer native `hs.*` APIs over AppleScript when a reliable Hammerspoon path exists.
- If a replacement path is uncertain, isolate it in a new module or config switch instead of rewriting a working module broadly.
- Before changing notification utilities, compare against prior visible behavior. Preserve banner and Notification Center semantics unless the user asks to change them.
- Treat hotkey binding logs, KeyCastr display, and toast or notification announcements as independent outputs. Do not bind all three to one shared switch.
- Verify `hs.spaces` latency and API behavior with docs, community reports, and local runtime evidence before replacing synthesized Mission Control shortcuts.
- Before porting terminal app behavior, identify whether hide/show/activate lives in the terminal app itself or in Hammerspoon. Kitty may need Hammerspoon-managed hide/show/activate even if WezTerm did not.
- Preserve native Chrome, Edge, and Safari middle-click tab close and background-link-open behavior before considering mouse fallbacks.

## External CLI Rule

For display behavior, keep CLI usage split from feature logic:

- Use `displayplacer` for display topology, arrangement, origin placement, primary display, mirror/extend layout, and profile restore.
- Use `m1ddc` for DDC features such as monitor input source, brightness, contrast, and volume.
- Prefer a small `utils/` adapter for external command resolution, command building, execution, and output parsing when editing CLI-heavy behavior.
- Keep feature modules focused on state transitions, user-facing notifications, hotkey binding, and config selection.
- Avoid assuming CLI subcommands exist. Historical failures include `displayplacer version`; prefer `displayplacer list` for topology evidence.

Use this preflight when a CLI is part of the issue:

```bash
command -v displayplacer || true
command -v m1ddc || true
displayplacer list
m1ddc display list
```

Treat nonzero `m1ddc` output as runtime evidence first; connected monitor state can affect it.

## Source Checks

Use targeted source checks before editing:

```bash
rg -n "displayplacer|m1ddc|hs\\.execute|hs\\.hotkey|hs\\.eventtap|hs\\.notify|hs\\.screen|hs\\.spaces" /Users/csheng/.hammerspoon
sed -n '1,220p' /Users/csheng/.hammerspoon/init.lua
sed -n '1,260p' /Users/csheng/.hammerspoon/core/config_loader.lua
```

For hotkey, notification, mouse, and module-loading issues, include these files in the check set as relevant:

- `/Users/csheng/.hammerspoon/utils/hotkey_utils.lua`
- `/Users/csheng/.hammerspoon/utils/notification_utils.lua`
- `/Users/csheng/.hammerspoon/config/hotkeys.lua`
- `/Users/csheng/.hammerspoon/config/mouse.lua`
- `/Users/csheng/.hammerspoon/modules/mouse_management.lua`
- `/Users/csheng/.hammerspoon/modules/mouse_management_spaces.lua`

## Module Edit Pattern

- Feature modules may depend on `core.logger`, `core.config_loader`, and `utils/*`; avoid feature-module to feature-module dependencies.
- Bind new hotkeys through `utils.hotkey_utils.bind` with option-table style, a human-readable `description`, and the owning `module`.
- Put configurable behavior in `core/config_loader.lua` defaults and the relevant `config/*.lua` override file.
- Keep utility modules in `utils/` dependency-light, returning a module table with reusable functions.
- After adding a module, register it through the existing `init.lua` and `core.init_system` pattern, then verify reload logs or console status.

## Validation

Run syntax validation after Lua edits:

```bash
find /Users/csheng/.hammerspoon -path /Users/csheng/.hammerspoon/.git -prune -o -name '*.lua' -type f -print0 | xargs -0 -n 1 luac -p
```

Run diagram validation after PlantUML edits:

```bash
find /Users/csheng/.hammerspoon/docs -name '*.puml' -type f -print0 | xargs -0 plantuml --check-syntax
```

If behavior depends on live Hammerspoon state, ask for or use console output instead of inferring from static code alone.

## Common Mistakes

- Reopening accepted boundaries from `AGENTS.md`, such as browser middle-click fallback behavior.
- Replacing `displayplacer` with `m1ddc` for macOS display topology.
- Using `displayplacer enabled:false/enabled:true` as a reversible second-monitor toggle.
- Editing docs from intention instead of source-backed behavior.
- Implementing broad refactors when the user asked only for analysis or a narrow runtime fix.
