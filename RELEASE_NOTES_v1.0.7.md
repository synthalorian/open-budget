# Open Budget v1.0.7 - The Real Fix

Actually fixes the budget `+` grey screen. v1.0.6 was already taken on GitHub by an earlier scroll-wrapper attempt that didn't solve the underlying bug; this is the proper fix.

## Root cause

Thanks to the global error catcher we wired in v1.0.4, the crash trace was captured as:

```
type '(dynamic) => DropdownMenuItem<Object>' is not a subtype of
type '(Category) => DropdownMenuItem<Category>' of 'f'
```

`_showAddBudgetSheet` received its `db` parameter typed as `dynamic`. That made `categories = db.categories.values.where(...).toList()` also dynamic at compile time. Inside `.map<DropdownMenuItem<Category>>((c) => DropdownMenuItem(value: c, ...))`, `c` was `dynamic`, so Dart couldn't narrow the `DropdownMenuItem` generic from `value: c` and compiled the callback as `(dynamic) -> DropdownMenuItem<Object>`. At runtime, `List<Category>.map<DropdownMenuItem<Category>>` demands `(Category) -> DropdownMenuItem<Category>`, and since `DropdownMenuItem<Object>` is NOT a subtype of `DropdownMenuItem<Category>` (Dart generics are invariant), a TypeError was thrown every frame - 379 copies in the log, each rendering the grey `ErrorWidget`.

## Fixes

- `_showAddBudgetSheet` - typed `db` as `DatabaseService` (not `dynamic`) and `categories` as `List<Category>` explicitly. Also added explicit generic args on the inner `DropdownMenuItem` constructors, belt-and-suspenders.
- `_showAddRecurringSheet` - same latent bug, preventatively fixed by casting `.values` as `Iterable<Category>` up front.
- Removed v1.0.4/v1.0.5/v1.0.6 diagnostic scaffolding (colored A/B/C/D/E strips, red background, inline scroll wrappers). Sheet is back to real production UI.
- Global `FlutterError.onError` catcher and CORE CONFIG -> VIEW_LAST_ERROR row **remain** - they earned their place.

## Artifact

`dist/OpenBudget-v1.0.7.apk` - 56.1 MB

SHA-256: `fce1df3d7f08094cba17967b06c3fabb3701591547e371941de51c623bc1e5df`

---

synth + synthclaw
