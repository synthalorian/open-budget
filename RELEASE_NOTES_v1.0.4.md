# Open Budget v1.0.4 — Grey Screen Diagnostic Build

Not a feature release. This build swaps the budget `+` sheet for a **minimal red test sheet** so we can tell where the failure actually is. Also wires a global Flutter error catcher and a `VIEW_LAST_ERROR` row in CORE CONFIG so any thrown exception is viewable in-app.

## What to test

1. Install v1.0.4.
2. Confirm CORE CONFIG footer reads `v1.0.4`.
3. Go to the Budget tab. Tap the `+` FAB. Tell me what you see:
   - **Red box with "DIAG v1.0.4: IF YOU SEE THIS RED BOX, THE SHEET WORKS."** → the bottom-sheet mechanism is fine; the previous grey was from content in `_showAddBudgetSheet`. I can rebuild from there.
   - **Still grey** → something deeper (FAB wiring, navigator context, or release-mode behavior specific to opening bottom sheets from BudgetPage). I'll dig differently.
   - **Nothing appears at all, just the snackbar** → sheet isn't being scheduled.
4. Regardless of outcome, go back to CORE CONFIG and tap `VIEW_LAST_ERROR`. If any exception was thrown on the budget path, it'll be shown there with a stack trace. Share the text.

## Artifact

`dist/OpenBudget-v1.0.4.apk` — 56.2 MB

SHA-256: `d4b71b42ccd6e183398cb08086f2ec3b6bfca32e805c80cb0bbce4c2f27368c8`

---

🎹🦞 synth + synthclaw
