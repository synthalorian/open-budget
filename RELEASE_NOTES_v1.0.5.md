# Open Budget v1.0.5 — Budget Sheet Diagnostic #2

Still diagnostic. The v1.0.4 red-box test proved the bottom-sheet mechanism works fine and no exception is thrown — so whatever was causing the grey screen was *invisible* content, not a crash.

This build puts the real budget-creation sheet BACK, with:

- **Red sheet background** — if content is zero-height, you see red. If the sheet renders grey again, something else is covering it.
- **Five colored diagnostic strips** (A-E) between every major widget. They say things like "A: start", "B: after title", etc. in black text on bright bg colors (yellow / cyan / lime / orange / pink).

## What to test

1. Install v1.0.5. Confirm CORE CONFIG footer reads `v1.0.5`.
2. Budget tab → tap `+`. Tell me EVERYTHING you see:
   - Which strips (A/B/C/D/E) are visible?
   - Is the background red or grey?
   - Do you see "INITIALIZE_BUDGET" title text?
   - Do you see the AMOUNT field?
   - Do you see the two dropdowns in a row?
   - Do you see COMMIT_BUDGET button?
3. If anything went wrong, check CORE CONFIG → VIEW_LAST_ERROR for a trace.

The color strips will tell me exactly which widget in the tree is failing. Once I know, v1.0.6 fixes it for real.

## Artifact

`dist/OpenBudget-v1.0.5.apk` — 56.2 MB

SHA-256: `e250e3df08d9debd33220684aceb1957a713904a0665906843d4987eaff9d15f`

---

🎹🦞 synth + synthclaw
