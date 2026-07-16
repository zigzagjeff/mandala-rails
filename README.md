# mandala-rails

A web-based Mandala Chart tool built with Ruby on Rails. Active development — not yet production-ready for general use.

---

## What this is

The [Mandala Chart](https://en.wikipedia.org/wiki/Mandala_chart) is a 9-square planning framework rooted in Miller's Law (7 ± 2). A center tile holds the primary goal or theme. Eight surrounding tiles hold supporting themes. Each surrounding tile can drill down into its own 9-square sub-grid — creating a fractal structure that can hold an entire project, a brainstorm, or a writing workflow.

This app is opinionated software. Tiles are documents — not containers, not launchers. Each tile has a `title`, `subtitle`, and `body`. The title and subtitle render on the tile card surface; the body opens in a full document view. The discipline is the point: if the meaning doesn't fit in a title and subtitle, the tile is doing too much.

The character limits on `title` (60 chars) and `subtitle` (120 chars) are not arbitrary — they mirror Substack post and Notes card discipline. A tile is a post that hasn't been published yet.

Users are limited to 9 mandalas. That's Miller's Law too.

---

## Architecture

- **Rails 8.1** — Hotwire (Turbo Frames + Turbo Streams) for inline editing without page reloads
- **SQLite** — file-based, every environment; the Rails 8 Solid stack (Solid Queue, Solid Cache, Solid Cable) runs on it, so there is no Redis and no external database
- **Propshaft** — asset pipeline
- **Import maps** — JavaScript without a bundler
- **Lexxy** — rich text editor for tile body (built on Meta's Lexical framework, shipped by 37signals)
- **Kamal** — deployment

---

## Data model

A Mandala has a title and holds up to 81 tiles, organized into a root grid (always present) and up to 8 child grids (created lazily, one per drilled surrounding tile). The hierarchy is three concrete nouns — **Mandala > Grid > Tile** — with the recursion living inside `Grid`.

```
User
└── Mandala (max 9 per user)
    └── Grid (root grid + one per drilled tile)
        └── Tile (9 per grid, positions 0–8)
            ├── title (string, max 60 chars)
            ├── subtitle (string, max 120 chars)
            ├── body (rich text via Action Text)
            ├── agentic_summary (text, nullable — written by AI agent)
            ├── metadata (text, JSON-serialized — reserved)
            └── child_grid → Grid (fractal drill-down)
```

The center tile is position 4. Every tile is either the **center** of its grid or one of the eight **surrounding** tiles — the same distinction at every depth. The root center is seeded from the Mandala's title on creation, then edited freely.

### AI-first schema design

`agentic_summary` is a first-class field, not an afterthought. When the agent pipeline is ready (see issue [#10](https://github.com/zigzagjeff/mandala-rails/issues/10)), agents will write summaries here. Summaries are intended to be nested in XML tags reflecting the Mandala → Grid → Tile hierarchy, enabling efficient context traversal without loading full body content.

---

## Getting started (local development)

### Prerequisites

- Ruby (see `Gemfile` — Rails `~> 8.1.3`)
- Bundler
- **libvips** — the system image library used by Active Storage for image variants (via the `ruby-vips` and `image_processing` gems). Install it with `brew install vips` (macOS) or `apt-get install libvips` (Debian/Ubuntu). Without it, `bundle install` and image uploads will fail.

SQLite needs no separate install — the `sqlite3` gem bundles it. `libjemalloc` is optional locally (production wires it in via the Dockerfile).

### Setup

```bash
git clone https://github.com/zigzagjeff/mandala-rails.git
cd mandala-rails
bundle install
```

Copy `.env.example` to `.env` and adjust as needed — see **Environment variables** below. Most local setups need nothing beyond `config/master.key`.

```bash
rails db:create db:migrate db:seed
bin/dev
```

App runs at `http://localhost:3000`.

---

## Environment variables

| Variable | Purpose |
|---|---|
| `RAILS_MASTER_KEY` | Credentials decryption key — get from project owner |

The database is file-based SQLite (`storage/*.sqlite3`), configured in `config/database.yml`. No `DATABASE_URL` or external database in any environment.

---

## Deployment

Kamal. See `config/deploy.yml` for configuration. The production database is SQLite on a Kamal-mounted volume (`storage/`).

```bash
kamal deploy
```

---

## Design decisions (notable)

| Decision | Rationale |
|---|---|
| 9-mandala limit per user | Miller's Law — the mind works best with 7 ± 2 chunks |
| Title: 60 chars, subtitle: 120 chars | Substack post discipline; forces clarity on the card surface |
| Tiles are documents, not containers | External service launchers and image tiles are explicitly out of scope (see issue [#18](https://github.com/zigzagjeff/mandala-rails/issues/18)) |
| Rails over alternatives | 37signals-adjacent methodology (Shape Up); Hotwire is the right tool for this interaction model |
| AI-first schema | `agentic_summary` is a schema-level commitment, not a retrofit |

---

## Open issues

See [GitHub Issues](https://github.com/zigzagjeff/mandala-rails/issues) for the full list. Key open items:

- [#7](https://github.com/zigzagjeff/mandala-rails/issues/7) — Tile card partial (single source of truth for tile markup)
- [#10](https://github.com/zigzagjeff/mandala-rails/issues/10) — MCP server for AI agent access
- [#13](https://github.com/zigzagjeff/mandala-rails/issues/13) — Drag and drop tile reordering
- [#17](https://github.com/zigzagjeff/mandala-rails/issues/17) — Enforce 9-chart limit

---

## See also

- [AGENTS.md](./AGENTS.md) — orientation for AI agent collaborators
- [CHANGELOG.md](./CHANGELOG.md) — version history
