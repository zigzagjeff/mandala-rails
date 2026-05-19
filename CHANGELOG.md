# Changelog

All notable changes to mandala-rails will be documented here.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

---

## [Unreleased]

### Added
- `README.md` — full project README replacing Rails boilerplate; covers purpose, architecture, data model, local dev setup, environment variables, design decisions table, and open issues index
- `AGENTS.md` — AI agent orientation document; covers architecture map, agentic design intent, `agentic_summary` XML format spec, working conventions, and explicit do-not-do list

### Issues filed
- [#13](https://github.com/zigzagjeff/mandala-rails/issues/13) — Feature: drag and drop to reorder tiles within a grid
- [#14](https://github.com/zigzagjeff/mandala-rails/issues/14) — Dev experience: switch development database to local Postgres
- [#15](https://github.com/zigzagjeff/mandala-rails/issues/15) — Docs: write a proper README
- [#16](https://github.com/zigzagjeff/mandala-rails/issues/16) — Docs: create AGENTS.md for AI collaborator orientation
- [#17](https://github.com/zigzagjeff/mandala-rails/issues/17) — Feature: enforce 9-chart limit per user (Miller's Law)
- [#18](https://github.com/zigzagjeff/mandala-rails/issues/18) — Decision: tiles are documents, not containers — external launchers and image tiles out of scope

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
