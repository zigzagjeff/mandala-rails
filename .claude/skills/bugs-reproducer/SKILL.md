---
name: bugs-reproducer
description: Reproduce a reported mandala-rails bug as a failing test before any fix is attempted. Invoke when a bug is reported or suspected — before investigating fixes. Classifies the bug (model/controller, UI/Turbo, or upstream Lexxy), picks the right suite, and produces the failing test that proves the bug is real (canon C8.6).
---

# Bugs Reproducer

Reproduction only. This skill ends with a test that fails for the
reported reason — it never investigates fixes or touches `app/` code
(C8.6: reproduction and fixing are separate acts). The fix happens
afterward, under the `dhh-coder` skill, and must see this test pass.

```
BUG REPORT → CLASSIFY → REPRODUCE (failing test) → hand off to dhh-coder
```

## Classify first

The layer that owns the root cause decides the suite — and the repo.
Getting this wrong wastes all subsequent work.

| The bug lives in… | Then | Suite |
|---|---|---|
| Data, models, derivations (depth, heading_level, seeding, positions) | reproduce here | `test/models/` |
| Requests, auth, API v1, Turbo Stream responses | reproduce here | `test/controllers/` — full request cycle, follow redirects (C5.5) |
| CLI / MCP sidecar (`lib/mandala/`) | reproduce here | `test/mandala/` — WebMock socket-level stubs are the blessed pattern (ruling R1) |
| JavaScript behavior: Stimulus controllers, Turbo Frame interactions in the browser | reproduce here | `test/system/` — browsers are for JavaScript only (C5.5) |
| The editor itself: typing, cursor, formatting, paste, attachments inside the Lexxy editor | **upstream** — file or link a `basecamp/lexxy` issue; do not paper over it here | (precedent: #61/#12 blocked on lexxy#1057) |

If an editor-adjacent bug might be mandala's integration rather than
Lexxy core (wiring, form params, Action Text persistence), reproduce the
integration side in `test/system/` first — where the reproduction fails
tells you whose bug it is.

Then scan `watch.md` for the shape you are about to reproduce. A match is
the second sighting — the bug is now a family: promote it per C8.8 (see
"Common bug patterns" below).

## Reproduce

1. Start from existing fixtures (`charts`, `grids`, `tiles`, `users`) —
   tweak inline for a variation; add a fixture only for a recurring
   shape (C5.6, C5.7).
2. Write the test that a correct implementation would pass and this bug
   makes fail. Plain `assert`/`assert_equal` (C5.8).
3. **Run it and confirm it fails, for the reported reason.** A test
   never seen failing proves nothing — it could be passing for the
   wrong reason. Paste the failure output into the handoff.
4. If reproduction is genuinely impossible (purely visual, needs
   production data), say so explicitly and state the justification
   before anyone proceeds to a fix — silence is not a waiver.

## Hand off

Give the fixer: the failing test path, the failure output, the
classification, and any upstream issue link. After the fix lands and
the suite is green, validation is two-sided (C8.7): confirm the bug
reproduces on `main` and is gone on the branch, through the real app
(`bin/dev`), not just the test.

## Common bug patterns

Families only — a pattern or subsystem that keeps producing bugs, never
an individual fix (C8.8; instances belong to tests and commit messages).
A single occurrence is not a family yet — stage it in `watch.md` and
promote it here on the second sighting.

*(none recorded yet)*
