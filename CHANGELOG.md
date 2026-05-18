# Changelog

All notable changes to mandala-rails will be documented here.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

---

## [Unreleased]

### Added
- `CHANGELOG.md` — this file

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
