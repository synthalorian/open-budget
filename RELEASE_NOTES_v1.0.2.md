# Open Budget v1.0.2 — Grid Reboot

Follow-up patch. Fixes a grey-screen crash on the budget "+" sheet that only manifested after a CLEAR_MAIN_FRAME wipe.

## Fixes

- **Budget `+` grey screen** — `CLEAR_MAIN_FRAME` was wiping the category box without re-seeding defaults, so the budget-creation sheet tried to render a `DropdownButtonFormField<Category>` with zero items and grey-screened in release builds. `clearAllData()` now re-seeds default categories and education progress immediately, and the clear dialog now invalidates the `transactions` / `budgets` / `categories` / `recurring` / `goals` providers so the UI repaints without requiring an app restart.
- **Budget sheet defensive render** — if no expense categories exist (e.g. a user deleted them all via the Categories page), the sheet now shows `NO_CATEGORIES_DETECTED` with an `OPEN_CATEGORIES` shortcut instead of silently failing. Sheet content is wrapped in `SingleChildScrollView` to prevent overflow on short screens.

## Artifact

`dist/OpenBudget-v1.0.2.apk` — 56.2 MB

SHA-256: `3b42633e8a981d50dd5995fdedb3542aef2da648451d7e6984339f5100897455`

---

🎹🦞 synth + synthclaw
