# Open Budget v1.0.3 — Actually Fix The Budget Sheet

Budget `+` FAB grey-screen — take two. v1.0.2 addressed a real-but-different bug (clearAllData not re-seeding categories) but the grey screen persisted. This release rewrites the budget-creation sheet to mirror the known-working recurring-transaction sheet pattern exactly.

## Fixes

- **Budget `+` grey screen** — rewrote `_showAddBudgetSheet` to match the structure of `_showAddRecurringSheet` (which is confirmed working). Changes: nullable `selectedCategory` declared at outer scope (not inside `builder`), dropdowns moved into a `Row(Expanded/Expanded)` layout, removed `SingleChildScrollView` and inline empty-state branch, added early-return with SnackBar if no expense categories exist.
- **Version string in CORE CONFIG** — was hardcoded to `v1.0.0` forever. Bumped to `v1.0.3` so you can tell at a glance which APK is installed. (Needs a proper `package_info_plus` fix eventually, but not today.)

## Carryover from v1.0.2

v1.0.2 fixes are still here (clearAllData re-seeds default categories + education; clear dialog invalidates Riverpod providers so the UI repaints without restart).

## Artifact

`dist/OpenBudget-v1.0.3.apk` — 56.2 MB

SHA-256: `7084d8e211b7f77ad8a7146dcc19bd32f71654f74e4acdfe5306aff6d66e20df`

---

🎹🦞 synth + synthclaw
