# Changelog

All notable changes to mandala-rails will be documented here.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

---

## [Unreleased]

### Fixed
- `db/seeds.rb` is guarded to development and test (`unless Rails.env.local?`, warn-and-no-op otherwise, per canon ruling R13). The file opens with four `destroy_all` calls and had no environment check, so `bin/rails db:seed` on the production box would have destroyed every live record — and Litestream would have replicated that destruction to the off-site copy within seconds (a replica is not a backup). Normal deploys were never at risk: `db:prepare` only seeds a *freshly created* database. The exposure was a human at a production console, and a disaster-recovery path where the volume is wiped and no Litestream replica is found. Found while resolving #115 item 4
- The file's opening comment claimed "Seeds are idempotent — safe to re-run", which conflated *converges on the same end state* with *safe* — it converges by destroying everything first. Rewritten to say what idempotence actually buys and why the file is local-only
- `.rubocop.yml` now excludes Rails-generated schemas and migrations (`db/*schema*.rb`, `db/migrate/**/*`), matching `fizzy-main/.rubocop.yml` and widened to the Solid schemas Rails 8 ships (canon ruling R14). `bin/check` was failing on a clean tree — 40 offenses, all of them the schema dumper's `["user_id"]` against omakase's `[ "user_id" ]` — which blocked every change in the repo from going green

### Changed
- Tile interaction re-cut around three zones, each meaning exactly one thing at every depth (product-canon ruling R6). The title moves from the top of the tile to its **centre**; the **centre area** around it opens the rich-text editor in one click (unchanged in cost — R6(a) prices writing as the frequent act and rename as the rare one); and a **drill ring** around the tile's edge replaces the small `▶` corner button, which is gone. The three are absolutely positioned siblings rather than nested, because an anchor cannot contain another anchor. A proposal to invert this — body-click drills, editor demoted to a three-dot menu — was cut at Shape: it made one gesture mean different things on root vs. leaf tiles, which the corpus never does (fizzy's `card__link` navigates identically in every card state)
- A tile is drillable only once it has a title (`Tile#drillable?` gains `title.present?`). `create_child_grid_once` seeds the child grid's centre tile from its parent's title, so drilling an unnamed tile dropped the user into a nameless sub-grid with no cue where they were — reachable before via `▶`, but a full peripheral ring would hit it far more often. Naming a tile now reveals its ring, which also recovers the blank → titled → deeper progression without a state-dependent click. This gates **all three surfaces** — the view, `Tiles::DrillsController`, and `POST /api/v1/tiles/:id/drill` — because ruling R2 forbids splitting behaviour between internal and external surfaces; agents and `bin/mandala` are refused the same drill a person is
- Renamed `Chart` → `Mandala` end-to-end (issue #138, product-canon ruling R2) — model and table (`charts` → `mandalas`), routes and `MandalasController`, the `api/v1` surface (`GET/POST /api/v1/mandalas`, grid `mandala_id`), the `bin/mandala` CLI (`list` / `show <id>` subcommands, replacing the stuttering `bin/mandala mandala <id>`), the MCP tools (`list_mandalas` / `get_mandala`), the `lib/mandala` module (now `MandalaClient`, freeing the bare `Mandala` constant for the model), and the docs. The titled user-created document *is* the Mandala; `Grid` and `Tile` are unchanged. This is a breaking change to the (pre-public, no external consumers) v1 API and MCP tool names — no deprecation aliases
- The root grid's center tile is now seeded from the Mandala's title at creation (previously blank), mirroring how a drilled child grid's center is seeded from its parent tile — independent and user-editable afterward
- Tile placeholder copy is now center-vs-surrounding, self-similar at every depth: a center tile reads "Name the center", every surrounding tile reads "Add a tile" (was "Set your goal" / "Add a theme" / "Add a task")

### Removed
- Subtitle and body preview no longer render on the tile face — a centred title is worth more than the two lines of secondary text competing with it at 109px. The `subtitle` column, its editor field, its `subtitle_changed` events, the data export, and the API field all stay; only the tile-face rendering goes. `Tile#body_preview` and `BODY_PREVIEW_LENGTH` are deleted with it, and the `with_previews` scope along with them — its `with_rich_text_body` half existed solely to feed that preview, so the two grid views now inline `includes(:child_grid)` (the #97 N+1 fix, preserved) and `api/v1/grids/show.json.jbuilder` preloads nothing, having never emitted `body` at all
- `Chart#mode` — the required planning/brainstorm field and its new-mandala selector are gone; no shipped 37signals product gates container creation behind a mode selector (#138). The `mandalas` table drops the `mode` column
- `Tile#tile_type` — collapsed from three roles (goal/theme/task) to the self-similar center/surrounding distinction; its only caller was `title_placeholder`, and it was never API-serialized

### Added
- `bin/check` gate gains a bundler-audit stage (fizzy `bin/ci` parity) — activated by the existing `bin/bundler-audit` binstub; first run surfaced three advisories (crass GHSA-wwpr-jff3-395c, json CVE-2026-54696, msgpack CVE-2026-54522), patched with conservative updates to crass 1.0.7, json 2.20.0, msgpack 1.8.3
- Enforce 9-chart limit per user (Miller's Law) — model validation on create, controller guard in `ChartsController#new`, UI replaces "New Mandala" button with limit notice at cap; `Chart::LIMIT = 9` constant; model tests cover valid 9th chart, rejection of 10th, and constant value (closes #17)
- Removed dead PWA scaffolding — `app/views/pwa/manifest.json.erb`, `app/views/pwa/service-worker.js`, commented-out routes, and commented-out manifest link tag in layout; no PWA intent exists and the files were never activated (closes #53)
- Breadcrumb N+1 fixed — `GridsController#build_breadcrumb` now preloads all grids and their parent tiles for the chart in 2 queries, then walks the parent chain in memory using an id-keyed hash; was 2 queries per depth level (closes #54)
- Character counter extracted from inline `<script>` in `tiles/edit.html.erb` into `app/javascript/character_counter.js` ES module — `initCharacterCounters(root)` initializes all `[data-counter-target]` fields in scope; wired in `application.js` on `turbo:load` and `turbo:frame-render`; pinned in importmap; view is now script-free (closes #22)
- `Tile#tile_type` justified as a computed method (no stored column) — adds one-line intent comment; tested in #52; used by agent pipeline and future UI classification (closes #23)
- Content Security Policy enabled in report-only mode — `config/initializers/content_security_policy.rb` configured for this app's actual sources: `self` for default/font/connect/media, `data blob` for images, `unsafe-eval` for Lexical (Lexxy Function constructor), `unsafe-inline` for style (Trix inline styles), `blob` workers; nonce generator wired for importmap inline scripts; `report_only = true` logs violations without blocking — remove that line to enforce (closes #46)
- Test coverage for core domain — Chart (validations, `root_grid`, 9-chart limit), Grid (`root?`, parent tile association), Tile (position/length validations, `display_title`, `has_children?`, `find_or_create_child_grid!` idempotency and seeding, `tile_type`), `ChartsController` (create seeds 9 tiles, new guard at limit), `TilesController` (drill idempotency, update Turbo Stream, cross-user scoping); fixtures updated with valid mode and user associations (closes #52)

### Changed
- Drill speaks the domain and stops mutating on GET — `Tile#find_or_create_child_grid!` renamed to `Tile#drill` (the domain word, canon C4.5; bang dropped per C4.7 — raise semantics still propagate from `create!` inside); web route `get :drill, on: :member` replaced with `resource :drill, only: :create` → new `Tiles::DrillsController#create` (canon C2.13, fizzy closures pattern — also fixes grid creation on a GET, which prefetchers could trigger); tile arrow is now a `button_to` POST; API v1 `POST /tiles/:id/drill` route unchanged pending #65; drill controller tests moved to `test/controllers/tiles/drills_controller_test.rb` mirroring the new controller, plus a cross-user scoping test the old action lacked
- Database switched from PostgreSQL to SQLite — `gem "pg"` replaced with `gem "sqlite3", "~> 2.1"`; `config/database.yml` rewritten for file-based adapter (`storage/*.sqlite3`); `grids.parent_tile_id` column type changed from `uuid` to `string`; `tiles.metadata` column type changed from `jsonb` to `text`; `serialize :metadata, coder: JSON` added to `Tile` model

### Fixed
- Live broadcasts now reach the browser — a live/broadcast feature (#68) shipped without its client-side cable wiring, invisible because it was only ever eyeball-verified in a single session. The app imported bare `@hotwired/turbo`, which does not register `<turbo-cable-stream-source>` or create an ActionCable consumer, so `turbo_stream_from`'s element was inert and every `broadcast_refresh_later_to` was pushed to a channel no browser subscribed to — a change was only visible on a manual reload. Now imports `@hotwired/turbo-rails` and pins `@rails/actioncable` (the 37signals wiring); a system test asserts an out-of-band write (as an agent makes) arrives live in the browser (part of #91)

### Added
- First system test (`test/system/`) — `ApplicationSystemTestCase` (headless Chrome via selenium) with `sign_in_as` / `wait_for_cable_connection`; a live-update test that an out-of-band write surfaces in the browser via the #68 broadcast (the behavior that genuinely needs a real browser + cable). CI installs Chrome and runs `test:system`, uploading screenshots from failures (part of #91)
- Regression test that the drill arrow survives a tile rename — the CHANGELOG 0.2.0 fix had none; a `TilesController` test asserts the arrow stays inside the `turbo-frame` Turbo extracts from the update redirect (i.e. remains in the shared tile partial), at the controller level rather than a browser (part of #91)

### Issues filed
- [#56](https://github.com/zigzagjeff/mandala-rails/issues/56) — Infra: switch database from PostgreSQL to SQLite ✅ closed
- [#57](https://github.com/zigzagjeff/mandala-rails/issues/57) — Infra: configure SQLite for production — backup strategy + Neon data migration
- [#58](https://github.com/zigzagjeff/mandala-rails/issues/58) — Decision: iterate on existing codebase, not rewrite ✅ closed
- [#46](https://github.com/zigzagjeff/mandala-rails/issues/46) — Security: enable Content Security Policy
- [#47](https://github.com/zigzagjeff/mandala-rails/issues/47) — UX: body content indicator on tile cards
- [#48](https://github.com/zigzagjeff/mandala-rails/issues/48) — UX: show chart mode (planning/brainstorm) during use
- [#49](https://github.com/zigzagjeff/mandala-rails/issues/49) — UX: empty state copy for blank tiles
- [#50](https://github.com/zigzagjeff/mandala-rails/issues/50) — UX: chart index should preview center tile goal
- [#51](https://github.com/zigzagjeff/mandala-rails/issues/51) — UX: mobile layout pass for the mandala grid
- [#52](https://github.com/zigzagjeff/mandala-rails/issues/52) — Test: core domain coverage — Chart, Grid, Tile, drill-down
- [#53](https://github.com/zigzagjeff/mandala-rails/issues/53) — Tidy: remove commented-out PWA manifest and service worker
- [#54](https://github.com/zigzagjeff/mandala-rails/issues/54) — Perf: preload parent_tile chain in breadcrumb to avoid N+1
- [#55](https://github.com/zigzagjeff/mandala-rails/issues/55) — Sprint: v0.4 engineering cleanup + design pass (tracking issue)
- [#25](https://github.com/zigzagjeff/mandala-rails/issues/25) — API: build `api/v1/` namespace — foundation for agent access

---

## [Unreleased — prior]

### Added
- `README.md` — full project README replacing Rails boilerplate; covers purpose, architecture, data model, local dev setup, environment variables, design decisions table, and open issues index
- `AGENTS.md` — AI agent orientation document; covers architecture map, agentic design intent, `agentic_summary` XML format spec, working conventions, and explicit do-not-do list
- Tile body preview on tile card — `to_plain_text` truncated to 80 chars, checklist markup stripped, rendered in `.tile-body-preview` (italic, muted)
- Character counter on tile edit form — live count on title (max 60) and subtitle (max 120); soft warning at 80%, danger at limit
- `line-clamp` on tile card — title clamped to 2 lines, subtitle to 1 line; overflow hidden with ellipsis
- Local Postgres as development and test database — eliminates Neon cold start latency in dev
- Neon URL moved to Rails encrypted credentials — removed from `.env`
- Issue labels: `waitingfor`, `notnow`, `ux`, `agentic`

### Changed
- `database.yml` — dev/test environments use local Postgres credentials; production reads `Rails.application.credentials.database_url`
- `.tile-title` and `.tile-subtitle` now use `-webkit-line-clamp` for overflow control

### Fixed
- Checklist markup (`[ ]`, `[x]`) stripped from tile body preview via regex before display

### Issues filed
- [#13](https://github.com/zigzagjeff/mandala-rails/issues/13) — UX: drag and drop to reorder tiles within a grid
- [#14](https://github.com/zigzagjeff/mandala-rails/issues/14) — Dev experience: switch development database to local Postgres ✅ closed
- [#15](https://github.com/zigzagjeff/mandala-rails/issues/15) — Docs: write a proper README ✅ closed
- [#16](https://github.com/zigzagjeff/mandala-rails/issues/16) — Docs: create AGENTS.md for AI collaborator orientation ✅ closed
- [#17](https://github.com/zigzagjeff/mandala-rails/issues/17) — Feature: enforce 9-chart limit per user (Miller's Law) — `notnow`
- [#18](https://github.com/zigzagjeff/mandala-rails/issues/18) — Decision: tiles are documents, not containers ✅ closed
- [#20](https://github.com/zigzagjeff/mandala-rails/issues/20) — UX: tile interaction model — rename, write, and drill as distinct intents
- [#21](https://github.com/zigzagjeff/mandala-rails/issues/21) — UX: opening a tile for full editing should show only that document
- [#22](https://github.com/zigzagjeff/mandala-rails/issues/22) — Refactor: extract character counter into a Stimulus controller
- [#23](https://github.com/zigzagjeff/mandala-rails/issues/23) — Tidy: remove or justify `Tile#tile_type` — defined but never used — `notnow`
- [#24](https://github.com/zigzagjeff/mandala-rails/issues/24) — Agentic: populate `agentic_summary` via contextual tile compression

### External
- Filed [basecamp/lexxy#1057](https://github.com/basecamp/lexxy/issues/1057) — feature request to expose `CheckListPlugin` for importmap + Propshaft setups

---

## [0.3.0] — 2026-05-18

### Added
- Lexxy rich text editor for tile body field — built on Meta's Lexical framework, shipped by 37signals
- `importmap-rails` gem — full JS pipeline via import maps and Propshaft
- `has_rich_text :body` on `Tile` — body now stored in `action_text_rich_texts` table
- Action Text and Active Storage infrastructure (`action_text:install`)
- Lexxy stylesheet via `stylesheet_link_tag "lexxy"` in application layout
- Action Text content template updated to use `lexxy-content` class for consistent rendering
- Tile edit form expands inline as a full-width panel with title, subtitle, and Lexxy body editor
- `.tile-edit-frame`, `.tile-edit-form`, `.tile-edit-body` CSS — edit panel breaks out of grid cell constraints
- `.tile-title` and `.tile-subtitle` CSS — subtitle renders stacked below title on tile card
- CI workflow: bumped `actions/checkout` to v4, `actions/cache` to v5

### Changed
- `tile_params` updated to permit `body:` as rich text (Action Text format)
- `_tile.html.erb` partial updated with `tile-title` and `tile-subtitle` span classes
- `app/views/layouts/action_text/contents/_content.html.erb` — renders with `lexxy-content` class

### Removed
- `body` (text) column from `tiles` — superseded by Action Text `has_rich_text :body`
- Hardcoded CDN `<script>` tag for Turbo — now loaded via importmap

---

## [0.2.0] — 2026-05-18

### Added
- `title` (string, max 60 chars), `subtitle` (string, max 120 chars), and `body` (text) columns on `tiles` — replaces single `content` field
- `agentic_summary` (text, nullable) column on `tiles` — schema placeholder for future AI agent population
- `Tile#display_title` helper — returns `title` or `"+"` when blank
- `Tile::TITLE_MAX_LENGTH` and `Tile::SUBTITLE_MAX_LENGTH` constants for shared validation and form enforcement
- `app/views/tiles/_tile.html.erb` partial — single source of truth for tile card markup, used by `charts/show`, `grids/show`, and `update.turbo_stream`
- Tile card renders `title` and `subtitle` on the grid surface

### Changed
- `tiles#edit` form now presents three fields: `title`, `subtitle`, `body`
- `find_or_create_child_grid!` seeds center tile of child grid with `title` (previously `content`)
- `GridsController#build_breadcrumb` uses `display_title` (previously `content`)
- `db/seeds.rb` updated to reflect new schema; second seed chart (Brainstorm) added with realistic tile data

### Fixed
- `TilesController#set_tile` — replaced `flat_map` memory scan with a single JOIN query scoped to the current user's chart (resolves N+1 as mandala depth grows)
- Drill arrow (`▶`) now persists after Turbo Stream tile update — previously dropped from the replaced frame

### Removed
- `content` (text) column from `tiles` — values migrated to `title`

---

## [0.1.0] — 2026-05-13

### Added
- Initial Rails 8.1 application scaffold
- Authentication via Rails built-in `has_secure_password` — sessions, passwords, password reset mailer
- `Chart` model — belongs to user, has many grids; modes: `planning`, `brainstorm`
- `Grid` model — belongs to chart; optional `parent_tile_id` for fractal drill-down
- `Tile` model — belongs to grid; positions 0–8; `has_one :child_grid` for sub-grid expansion
- `Tile#find_or_create_child_grid!` — creates child grid on drill, seeds center tile with parent content
- `Tile#tile_type` — returns `:goal`, `:theme`, or `:task` based on grid depth and position
- `charts#index` — lists user's mandalas; create and delete
- `charts#show` — renders 3×3 grid with inline Turbo Frame tile editing
- `grids#show` — renders sub-grid with recursive breadcrumb navigation
- `tiles#edit` / `tiles#update` — inline tile editing via Turbo Frames and Turbo Streams
- `tiles#drill` — navigates into (or creates) a tile's child grid
- Neon Serverless Postgres as database backend
- Dependabot configured for GitHub Actions dependency updates
- CI workflow via GitHub Actions
- Kamal deployment configuration
