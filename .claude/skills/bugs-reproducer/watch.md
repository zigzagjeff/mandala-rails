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

### model rename leaves its old name stored as data, not just as schema
- **Shape:** renaming a model that `include`s `Eventable` (or any concern
  storing `self.class.name` into a column) renames the table, the columns,
  and the code — but not the class name already persisted as *data*.
  `Event belongs_to :eventable, polymorphic: true` stores the class name in
  `eventable_type`; `Eventable#eventable_prefix` bakes it into every
  `action` string (`"chart_created"`). A rename migration that only does
  `rename_table` / `rename_column` leaves existing rows pointing at a class
  that no longer exists.
- **Seen once:** #138 Chart→Mandala rename (PR #141) shipped clean —
  `bin/check` passed — while leaving 8 production `events` rows with
  `eventable_type = "Chart"` and `action = "chart_created"`. Caught in
  review before deploy, fixed by a follow-up data migration (PR #143,
  `db/migrate/20260716205632_rename_chart_events_to_mandala.rb`).
- **Why the suite missed it:** nothing in the app dereferences
  `event.eventable` — the API jbuilder serializes `eventable_type` as a raw
  string and `User::Export` reads only `action` — so the gate's own tests
  never load the association on old data and never fail. The rename
  migration itself also has nothing to be wrong about schema-wise; the bug
  is purely in data the migration doesn't touch.
- **Also caught here:** a first draft of the fix handled only the one
  action the *current* snapshot showed (`chart_created`), not the full set
  the old model's `Eventable` concern could emit (`created`,
  `title_changed`, `mode_changed`). A snapshot taken before deploy proves
  nothing about what the *deploy window* writes, since the old code keeps
  running until the new image boots — handle the whole action family the
  concern defines, not just what today's data happens to contain (C8.8).
- **Guard for the next one:** whenever a model is renamed, grep the whole
  codebase for `eventable_prefix`, `self.class.name`, `demodulize`, or any
  other place a class name gets serialized into a column — not just the
  model file being renamed — and write a data migration alongside the
  schema migration. Enumerate every action the concern's callbacks can
  produce (not just the ones seen in a pre-deploy data snapshot) before
  calling the backfill complete.
- **Second sighting → promote to a family.**
