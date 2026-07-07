# CLAUDE.md — DHH Environment (Planner + Pipeline)

This project is built in the coding spirit of DHH and 37signals. The
philosophy lives in one place: the canon at `/Users/dev/DHH/canon/`.
This file is deliberately thin — it defines the pipeline and the
planning-time rules, and it cites the canon by rule ID rather than
restating it. If anything here conflicts with the canon, the canon wins
and this file is the bug.

@/Users/dev/DHH/canon/00-overview.md

Full canon files (read on demand, cite by ID):
- `/Users/dev/DHH/canon/01-code-clarity.md` — comments, constants, aesthetics
- `/Users/dev/DHH/canon/02-callbacks-concerns.md` — concerns, jobs, POROs
- `/Users/dev/DHH/canon/03-sharp-knives.md` — Current, globals, priced rule-bends
- `/Users/dev/DHH/canon/04-domain-language.md` — naming as design
- `/Users/dev/DHH/canon/05-testing.md` — testing without test damage
- `/Users/dev/DHH/canon/06-lifecycle-patterns.md` — destruction, grace periods
- `/Users/dev/DHH/canon/07-evolution-review.md` — the Reviewer's charter
- `/Users/dev/DHH/canon/deviations.md` — where the canon overrides the linter

Living exemplars (read before inventing a structure — the answer usually
already exists in one of these):
- `/Users/dev/DHH/corpus/37signals_code/writebook-main/`
- `/Users/dev/DHH/corpus/37signals_code/once-campfire-main/`

## The pipeline

Every coding task flows: **Plan → Code → Gate → Review.**

1. **Plan** (this file, always loaded): shape the change per the planning
   rules below before writing anything.
2. **Code**: invoke the `dhh-coder` skill when it is time to write. Do not
   write application code without it.
3. **Gate**: run `bin/check` after writing or modifying code. Deterministic,
   binary, no judgment.
   - **exit 1** — a stage failed. Fix and re-run. Do not proceed, do not
     invoke the Reviewer, do not philosophize.
   - **exit 2** — passed, but test-integrity flags were raised. Invoke the
     `dhh-reviewer` sub-agent with the `FLAG:` lines from the gate output as
     the primary object of review (C7.10).
   - **exit 0** — clean pass. Invoke the `dhh-reviewer` sub-agent for
     philosophy review.
4. **Review**: the Reviewer approves, or returns specific canon-cited
   objections. Objections route back to Code. An objection that cites no
   rule ID is an opinion and defers to the Coder (C0.2).

The task is done when the gate passes AND the Reviewer approves. Neither
alone is done.

## Planning rules (cite IDs; full text in canon)

**Separate generic from specific before writing.** Decide which parts of
the change are generic machinery and which are type-specific behavior.
Specifics get pushed to the most concrete class that can own them (C7.3);
a plan that edits a generic class to accommodate one concrete type is
wrong before any code exists (C7.4).

**Plan auxiliary complexity off the main path.** Side effects —
notifications, tracking, indexing — are planned as concerns with callbacks
(C2.1, C2.2), deferring non-blocking work to jobs (C2.3), layered
concern-decides / job-dispatches / object-works (C2.4), with an opt-out
for flows that must bypass them (C2.5). The main path's code should not
mention them.

**Name the concepts first.** Before writing, name the domain objects —
invented words welcome (C4.1), unambiguous words reserved for precise
operations (C4.2), concepts as objects rather than booleans (C4.4),
casual register over fancy adequacy (C4.3).

**Not everything is ActiveRecord.** Plan POROs in `app/models` freely
(C2.7); pair a slim API-face concern with composed worker objects (C2.9).
Choose the data store by criticality tier and say which tier (C2.11).

**Irreversible operations get the full treatment.** Command pattern with
`possible?` re-verification (C6.2), a grace period proportional to the
loss (C6.3), far-future work as jobs that own their wait (C6.4).

**Sharp knives are priced at plan time.** Using `Current`, bending
privacy, or any other deliberate rule-bend must be stated in the plan with
the trade-off named (C3.6, C0.3). An unstated bend is reviewed as a
mistake.

## Non-negotiables

**Never weaken a test to make it pass (C5.15).** A failing test is changed
only when the tested behavior was wrong, and the change must say so.
Deleting, skipping, or loosening an assertion to turn the gate green is
prohibited — fix the code instead. The gate detects this (exit 2) and the
Reviewer is charged with catching what the gate misses (C7.10).

**Never silence the gate by config.** Editing `.rubocop.yml` requires a
cited entry in `/Users/dev/DHH/canon/deviations.md` first. A config change
without one is a canon violation.

**Leave the code a little better, never worse (C7.1).**

## Project specifics

<!-- Per-project conventions go below this line: schema notes, domain
     vocabulary already reserved (C4.2), app-specific fixtures, etc.
     Keep philosophy OUT of this section — philosophy belongs in canon. -->
