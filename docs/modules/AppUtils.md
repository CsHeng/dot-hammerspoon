# App Utils

## Role
- Thin abstraction around `hs.application` for launching, focusing, hiding, and restarting macOS applications.
- Supplies shared predicates (browser detection, bundle lookups) for modules that need consistent application awareness.

## Capabilities
- Toggle between launch, focus, and hide states through `toggleApp`, returning structured status for callers.
- Restart or kill applications with optional bundle identifiers and safety checks.
- Enumerate running apps, resolve frontmost app metadata, and perform fuzzy searches across name or bundle fields.
- Provide convenience detectors (`isBrowser`, `isInstalled`, etc.) so feature modules can adapt behaviour based on the frontmost app.

## Entry Points
- Implementation: `utils/app_utils.lua`.
- Consumers: `modules/app_launcher.lua`, `modules/mouse_management.lua`, `modules/mouse_management_spaces.lua`, and any module that needs process insight.

## Behaviour Guarantees
- All operations log through the `app_utils` logger, including reasons for early exits (e.g., app not found).
- Functions return rich tables instead of bare booleans, enabling callers to branch on `success`, `running`, or `launched` flags without re-inspecting the system state.
- Browser detection is conservative and intended for features like mouse button remapping where browser tabs should retain native behaviour.

## Maintenance Notes
- Keep bundle identifier lists up to date; prefer configuration hooks when adding new per-app rules.
- When introducing new helpers, follow the existing pattern of returning structured results (`success`, `reason`) to simplify error handling upstream.
