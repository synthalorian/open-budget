# Open Budget v1.0.6 — The Real Fix

The budget `+` sheet grey screen is finally actually fixed. Thanks to v1.0.4's captured error trace:

```
type '(dynamic) => DropdownMenuItem<Object>' is not a subtype of
type '(Category) => DropdownMenuItem<Category>' of 'f'
```

Full explanation for posterity:

`_showAddBudgetSheet` received its `db` parameter typed as `dynamic`. That made `categories = db.categories.values.where(...).toList()` also dynamic at compile time. Inside the `.map<DropdownMenuItem<Category>>((c) => DropdownMenuItem(value: c, ...))` callback, `c` was `dynamic`, so Dart couldn't narrow the `DropdownMenuItem` generic from `value: c` and compiled the callback as `(dynamic) -> DropdownMenuItem<Object>`. At runtime, `List<Category>.map<DropdownMenuItem<Category>>` demands `(Category) -> DropdownMenuItem<Category>`, and since `DropdownMenuItem<Object>` is NOT a subtype of `DropdownMenuItem<Category>` (Dart generics are invariant), a TypeError was thrown every frame. 379 errors + a grey ErrorWidget.

## Fixes

- `_showAddBudgetSheet` - typed `db` as `DatabaseService` (not `dynamic`) and `categories` as `List<Category>` explicitly. Also added explicit generic args on the inner `DropdownMenuItem` constructor calls, belt-and-suspenders.
- `_showAddRecurringSheet` - same latent bug, same fix (cast `.values` as `Iterable<Category>` up-front). Recurring apparently dodged the crash only because synth never triggered the exact code path.
- Removed all v1.0.4/v1.0.5 diagnostic scaffolding: red background, colored A/B/C/D/E strips, SnackBar. Sheet is back to real production UI.
- Global error catcher and CORE CONFIG -> VIEW_LAST_ERROR row remain - they are a keeper.

## Artifact

`dist/OpenBudget-v1.0.6.apk` - 56.1 MB

SHA-256: `20e32f18444914b438f126109ec53cafa339cf75413442c3074b2235d6c13bf4`

---

synth + synthclaw
