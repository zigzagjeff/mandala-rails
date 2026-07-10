# Watch list — single-occurrence bug shapes

The antechamber to "Common bug patterns" in `SKILL.md`. C8.8 records
*families* — patterns that keep producing bugs — never individual fixes.
But a family is invisible until you notice the second instance resembles
the first, and a lone instance otherwise scatters into a test and a commit
message where nothing connects it to the next one. This log is where the
first sighting waits so the second is recognizable.

## How it works

- **Reproducing a bug?** Scan this list first (it is a step in CLASSIFY).
  If the new bug matches an entry, that is the **second sighting** — it is
  now a family. Move it to "Common bug patterns" in `SKILL.md`, write the
  durable guard there, and delete the entry here.
- **Novel shape, no match?** After the fix lands and the suite is green,
  add a one-line entry below.
- Cheap and read-only-at-classify-time. Prune an entry that is clearly a
  one-off (a typo, a vendor bug fixed upstream) rather than a shape this
  codebase could produce again.

## Entries

### form/controller param-shape mismatch
- **Shape:** a form and its controller disagree on param nesting — e.g.
  `form_with model: @user` (nests fields under `user[...]`) against a
  top-level `params.permit(:email_address, …)`, or the reverse. The
  attributes never arrive; the record fails validation or saves blank.
- **Seen once:** #75 registration signup — 422 on every submit (fixed in
  PR #111 by matching the sibling `sessions/new` bare-`url:` form).
- **Why the suite missed it:** the controller test hand-built params in
  the shape `create` wanted, so it never exercised what the form emits.
- **Guard for the next one:** reproduce form-contract bugs by asserting
  against the *rendered* form (`assert_select "input[name=?]"`) or by
  posting the params the form actually emits — never a hand-built hash
  that assumes the controller's side of the contract.
- **Second sighting → promote to a family.**
