# AGENTS.md — Guide for Agents Working on StandReminder

Scope: This file applies to the entire repository.

## Project Overview
- Platform: macOS 13+; Swift 5 + SwiftUI.
- App type: Menu bar app (`LSUIElement=1`). Main UI is provided via `MenuBarExtra(.window)` with an optional main window (`WindowGroup(id: "main")`).
- Core state lives in `ReminderManager` (timers, scheduling, notifications, i18n state, history).

## How To Run / Build
- Open in Xcode: `open StandReminder.xcodeproj` and run on “My Mac”.
- CLI build: `xcodebuild -project StandReminder.xcodeproj -scheme StandReminder -configuration Debug build`.
- Quick run: `./run.sh` (builds and opens app from DerivedData).
- Debug run: `./debug.sh` (launches the binary and tails output).

## Code Organization (key files)
- `StandReminder/StandReminderApp.swift` — App entry, menu bar scene, window groups, permissions.
- `StandReminder/ReminderManager.swift` — Single source of truth; scheduling, countdown, snooze, notifications, persistence, i18n.
- `StandReminder/ContentView.swift` — Main UI (header/timer/controls/stats/quick actions).
- `StandReminder/MenuBarView.swift` — Menu bar window UI & actions.
- `StandReminder/SettingsView.swift` — Settings (intervals, active hours, message, sound, language, shortcuts).
- `StandReminder/HistoryView.swift` — Stats and history list.
- `StandReminder/FullscreenReminderView.swift` — Fullscreen overlay for reminders.
- `StandReminder/LocalizationKeys.swift` — Centralized localization keys/utilities.
- `StandReminder/*.lproj/Localizable.strings` — Translations (en, zh-Hans, zh-Hant).

## Internationalization Rules
- Use `LocalizationKeys` for all static UI strings (`.localized` or `Text(LocalizationKeys...)`).
- To add a new string, add a case in `LocalizationKeys` and update all `.lproj/Localizable.strings` files.
- Important: Reminder content (`customMessage`) is NOT internationalized. It is stored and displayed exactly as the user enters. The fixed default is `"站立一下"` across all languages. Migration normalizes older saved values.
- Language selection is persisted in `UserDefaults("selectedLanguage")`. Views that must refresh on language change should depend on `reminderManager.selectedLanguage` (e.g., use `.id(reminderManager.selectedLanguage)`).

## State, Timers, and Notifications
- Only `ReminderManager` should own the countdown `Timer` and schedule notifications.
- Use `startReminder()`, `stopReminder()`, `snoozeReminder(minutes:)` to change behavior.
- `scheduleNotification(at:)` composes notifications; message uses `customMessage` (or the fixed default when empty).
- History is encoded/decoded to `UserDefaults` (JSON) via `ReminderRecord`.

## UI Guidelines
- Prefer SwiftUI components defined in this repo (e.g., `glassBackground`, glass-style sections) for visual consistency.
- Menu bar interactions live in `MenuBarView`. To open windows, use `@Environment(\.openWindow)` with a matching `WindowGroup(id:)`.
- If adding a new window (e.g., tools), define a `WindowGroup(id: ...)` in `StandReminderApp` and open it via `openWindow(id:)`.

## Entitlements and Permissions
- Keep `StandReminder.entitlements` sandboxed; do not add global keyboard capture permissions.
- Notification permission is requested on first launch.
- HealthKit integration is optional; check availability before use.

## Coding Conventions
- Swift style: readable names, avoid force unwraps; prefer `guard` and early returns.
- Keep changes minimal and focused; follow existing patterns (ObservableObject + SwiftUI bindings).
- No one-letter variables; avoid adding global state.
- When persisting new settings, add symmetric load/save in `ReminderManager`.

## Adding Localization
- Keys: extend `LocalizationKeys`.
- Strings: update all `.lproj/Localizable.strings` files.
- Fallbacks: `LocalizationKeys.localized` already handles zh-Hans/zh-Hant variants and hyphen/underscore forms.

## Known Pitfalls
- If a view doesn’t update after language change, ensure it depends on `selectedLanguage` (e.g., via `.id(...)`).
- For fullscreen overlay, keep `NSPanel` as `.nonactivatingPanel` and `.floating` to avoid stealing focus.
- `openWindow(id:)` requires a declared `WindowGroup(id:)`; otherwise it does nothing.

## Agent Workflow Tips
- Use `rg` to search and `apply_patch` to edit files. Keep edits small and targeted.
- Prefer modifying existing components over adding new frameworks.
- Validate by building with Xcode or `./run.sh`. If you cannot run locally, reason about changes and keep them isolated.

## Change Verification (No Errors Allowed)
After any code or content change, always validate and clear errors before handoff:
- Clean + build:
  - `xcodebuild clean -project StandReminder.xcodeproj -scheme StandReminder`
  - `xcodebuild -project StandReminder.xcodeproj -scheme StandReminder -configuration Debug build`
- Quick launch to sanity‑check runtime: `./run.sh` or use Xcode (⌘R).
- Watch console (use `./debug.sh`) for crashes, fatal errors, missing bundle resources, or localization lookup warnings.
- Functional smoke checks (manual):
  - Status bar menu opens (no window title/traffic‑lights), actions work (Start/Stop, Snooze, Open Main, Quit).
  - Settings opens; language switch updates visible strings; reminder content remains as user text.
  - Fullscreen reminder appears and dismisses; no stuck activation policy; notification schedules without errors.
- If any error occurs, fix it or revert the change; do not leave broken builds.
