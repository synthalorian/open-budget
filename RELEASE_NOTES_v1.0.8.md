# Open Budget v1.0.8 - The Grid Refresh

Clean slate. Four fixes, one APK.

## Root cause

Three issues surfaced across sessions: transactions saved via `DatabaseService.box.put` didn't immediately reflect in `transactionsProvider` (the UI lagged until some other action forced a rebuild), there was no way to remove unwanted transactions from the list, and the theme picker offered no non-neon option. On the build side, Amazon Corretto had drifted to jdk21.0.10_7 and needed pinning to the latest patch.

## Fixes

- **Add-transaction delay** — `AddTransactionPage` now routes through `transactionNotifierProvider.addTransaction()` instead of direct `DatabaseService().transactions.put()`, so the provider cache stays in sync and the new transaction appears immediately. Added a saving spinner and input validation (empty, non-numeric, zero/negative guard).
- **Purge UX** — Transaction list cards are now `Dismissible` (swipe right-to-left to purge) with a long-press fallback and an `IconButton` delete button. Confirmation dialog with explicit "PURGE" / "CANCEL" choice. Message: "INFLOW PURGED" or "OUTFLOW PURGED".
- **Normal Dark + Normal Light themes** — Added `normalDark` (standard dark, indigo accent, no neon vibes) and `normalLight` (Material light, white backdrop, indigo accent) as `NEW_USER`-unlock themes alongside the existing neon palette. `NeonTheme` now carries `brightness`, `background`, `surface`, `surfaceLight`, `card`, `textPrimary`, `textSecondary`, `textMuted` fields so light themes work without leaking neon defaults.
- **JDK pin** — `android/gradle.properties` updated from `jdk21.0.10_7` to `jdk21.0.11_10` (Amazon Corretto).

## Artifact

`dist/OpenBudget-v1.0.8.apk` - 56.3 MB

SHA-256: `60789636817774dda540e76d54aaed840914237334ee74e6367c977fbef8cebe`

---

synth + synthclaw
