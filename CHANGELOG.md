# Changelog

All notable changes to mandala-rails will be documented here.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

---

## [Unreleased]

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
