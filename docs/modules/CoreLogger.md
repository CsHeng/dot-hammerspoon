# Core Logger

## Role
- Wraps `hs.logger` to provide consistent logging ergonomics across modules.
- Offers helper utilities for common logging patterns without expanding module complexity.

## Capabilities
- `getLogger(moduleName)` returns an `hs.logger` instance with the shared default level.
- `setLogLevel(level)` allows global override of verbosity (`debug`, `info`, `warning`, `error`).
- Helper methods (`logFunctionCall`, `logHotkeyEvent`, `logError`) standardise structured log messages.

## Usage Guidelines
- Every module should request its own logger at load time to maintain clear prefixes.
- Use helper utilities for repetitive log shapes (function calls, hotkey triggers) to keep message formats uniform.
- Respect the user’s preferred log level; avoid resetting the default from inside feature modules.

## Observability
- Log level changes are global and persist for the lifetime of the Hammerspoon session.
- Modules inherit the logger automatically; no additional configuration is required beyond supplying a module name.
- Logging is the preferred mechanism for diagnostics instead of console prints, aligning with the project’s structured logging standard.

## Maintenance Notes
- If new logging patterns emerge, add helper functions here rather than duplicating string formatting across modules.
- Keep log messages actionable; each should describe the context and intended behaviour, not just state that something happened.
