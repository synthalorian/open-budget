# Open Budget v1.0.1 — Neon Patchwork

Bug-fix release. UI elements that looked interactive but did nothing now actually do things. Plus a latent async-gap crash fix and a build-toolchain bump.

## Fixes

- **Grid / THE GRID** — AppBar bolt icon now routes to Insights. SYNC quick-action tile now routes to Cloud Sync.
- **Budget / MAIN FRAME** — `+` FAB now opens an "INITIALIZE_BUDGET" sheet (amount + category + period, writes a `Budget` via `budgetNotifierProvider`). AppBar icon now routes to the Chronos module.
- **Core Config** — USER PROFILE row now opens a bottom-sheet editor and persists the handle; CLEAR_MAIN_FRAME now triggers a themed confirm dialog that wipes all transactions/budgets/goals/recurring.
- **Chronos module** — `/recurring` route registered. No more `GoException: no routes for location: /recurring`.
- **Theme persistence** — fixed bug where `themeName` was written to Hive but never read back, so the theme reset to `synthwave` on every app restart.
- **Async-gap bug** — `AddTransactionPage._save()` was guarding `context.pop()` with an unrelated `context.mounted` check; swapped to the State's `mounted` property.

## Cleanup

- Removed dead `exportData()` / `importData()` TODO stubs from `DatabaseService`.
- Consolidated duplicated clear-data dialog into a shared `showClearDataDialog()` helper.
- Project-wide sweep: `withOpacity(x)` → `withValues(alpha: x)` (52 occurrences), `activeColor:` → `activeThumbColor:` (3 occurrences).

## Build-toolchain

- Bumped Android Gradle Plugin 8.2.0 → 8.3.0 (fixes jlink bug under Java 21+).
- Pinned `org.gradle.java.home` to Corretto JDK 21 so Gradle 8.5 can parse the Java version string.

## Artifact

`dist/OpenBudget-v1.0.1.apk` — 56.2 MB

SHA-256: `81a6090331f7130ec5e2937f6121104bed20199033e28d7c1eb4c79ed93091f7`

---

🎹🦞 synth + synthclaw
