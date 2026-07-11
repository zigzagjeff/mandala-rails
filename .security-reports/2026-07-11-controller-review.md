# Security Review — mandala-rails controllers

**Date:** 2026-07-11
**Reviewer:** Claude (judgment-driven analysis, not a diff-scoped skill run)
**Scope:** Authorization / IDOR / auth-surface review of the existing controller layer (all 18 controllers + the `Authentication` concern). This is an existing-code audit, distinct from the `security-review` skill, which only reviews branch diffs and had no diff to operate on.
**Corroboration:** Independently confirmed by Brakeman during `bin/check` — 18 controllers / 10 models scanned, 0 security warnings.

## Result: No HIGH or MEDIUM findings

Nothing clears the >80%-confidence exploitability bar. The authorization model is consistent and correct.

## Why there are no findings — the ownership pattern is consistent

Every authenticated data path scopes the lookup through the current user's association, so cross-tenant access (IDOR) fails as a 404 at query time rather than leaking another user's record:

- **Charts** (web + API): `Current.user.charts.find(params[:id])` — `charts_controller.rb:24`, `api/v1/charts_controller.rb:7`
- **Grids**: `@chart.grids.find` (web) and `Current.user.grids.find` (API) — `grids_controller.rb:5`, `api/v1/grids_controller.rb:3`
- **Tiles**: `Tile.joins(:grid).find_by!(grids: { chart_id: @chart.id }, id: …)` — the join enforces chart ownership before the tile is reachable — `tiles_controller.rb:28`, `api/v1/tiles_controller.rb:27`
- **Events**: `Current.user.charts.find(params[:chart_id]).events` — `api/v1/events_controller.rb:7`
- **Data export / account closure**: operate only on `Current.user`, never a param-supplied id — `data_exports_controller.rb:3`, `account_closures_controller.rb:6`

The classic Rails IDOR — an unscoped `Model.find(params[:id])` relying on an unguessable URL — does not appear in any controller. Not one escapes the ownership scope.

## Auth surfaces handled with above-average care

- **Mass assignment**: every write uses `params.require/permit` — no `permit!`, no raw `params` into a model.
- **User enumeration defense** (`passwords_controller.rb:11-17`): password reset enqueues the mailer unconditionally and looks the user up in the job, with an in-code comment explaining that a controller-side lookup would leak which emails exist via both timing and the queue-insert row.
- **Session invalidation on password reset** (`passwords_controller.rb:24`): `@user.sessions.destroy_all`.
- **Signed tokens** for password reset and email verification, with `InvalidSignature` rescued to a generic message (`passwords_controller.rb:34`, `email_verifications_controller.rb:23`).
- **Rate limiting** on every unauthenticated write path — registration, login, reset (dual IP + per-account buckets), verification.
- **API auth** (`api/v1/base_controller.rb`): Bearer-token; `skip_forgery_protection` correct because there is no cookie-session surface; token + IP rate limits; 401 on miss.

## One awareness note (NOT a vulnerability)

`EmailVerificationsController#update` verifies email via a signed token with `allow_unauthenticated_access` (`email_verifications_controller.rb:2,9`). If that link is reachable by GET, an email scanner/preloader could auto-verify. Standard Rails 8 generated behavior, token is signed, verification is low-stakes here — noted, not flagged.

## Related artifacts

- `.security-reports/2026-07-11.json` — full-tier `/security-check` run (secrets, deps, CI/CD, OS posture)
- Deployed to production (Hetzner via Kamal) at commit `8d52755` on 2026-07-11 after `bin/check` passed clean.
