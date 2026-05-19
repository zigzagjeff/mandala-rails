# AGENTS.md

Orientation for AI agents working in this codebase. Read this before touching anything.

---

## Who built this and how

Jeff Long built mandala-rails with AI assistance as a first-class part of the workflow. The arrangement is explicit: Jeff shapes the work, sets constraints, and makes judgment calls. Agents execute, suggest, and flag decisions they can't resolve confidently.

This is not a repo where AI quietly generated everything and a human rubber-stamped it. The human orchestration layer is intentional and visible — in the commit messages, the issue bodies, and this file. If you're an agent reading this: operate accordingly.

---

## What this is

A web-based Mandala Chart tool. The Mandala Chart is a 9-square planning framework rooted in Miller's Law (7 ± 2). Users create charts, fill tiles, and drill down into sub-grids — creating a fractal structure for planning, brainstorming, or writing.

Tiles are documents. Each has a `title`, `subtitle`, and `body`. The tile card surface shows title and subtitle. The body opens in a full document view with a Lexxy rich text editor. This is the product. Do not expand it into something else without an issue and a decision.

Current version: **0.3.0** (see [CHANGELOG.md](./CHANGELOG.md)).

---

## Architecture orientation

### Stack

- Rails 8.1, PostgreSQL, Propshaft, Import maps
- Hotwire: Turbo Frames for inline edit, Turbo Streams for partial page updates
- Lexxy for rich text (Action Text under the hood)
- Kamal for deployment
- Neon Serverless Postgres in production; local Postgres in development (see issue [#14](https://github.com/zigzagjeff/mandala-rails/issues/14))

### Data model

```
User
└── Chart (max 9 per user — Miller's Law)
    └── Grid (root + one per drilled tile)
        └── Tile (9 per grid, positions 0–8)
```

Key files:

| Path | Purpose |
|---|---|
| `app/models/chart.rb` | Chart model — belongs to user, has many grids, mode: planning/brainstorm |
| `app/models/grid.rb` | Grid model — root? when parent_tile_id is nil |
| `app/models/tile.rb` | Tile model — position 0–8, TITLE_MAX_LENGTH, SUBTITLE_MAX_LENGTH constants |
| `app/controllers/charts_controller.rb` | Chart CRUD |
| `app/controllers/tiles_controller.rb` | Tile edit, update, drill |
| `app/controllers/grids_controller.rb` | Grid show with breadcrumb |
| `app/views/tiles/_tile.html.erb` | **Single source of truth for tile card markup** — use this partial everywhere |
| `config/routes.rb` | Nested: charts → grids, charts → tiles (with drill member route) |
| `db/schema.rb` | Current schema — read this before writing migrations |

### Turbo pattern

Tile editing uses Turbo Frames. The edit form loads inline; save triggers a Turbo Stream that replaces the tile frame in place. The `_tile.html.erb` partial is what the stream replaces — keep it as the single source of truth.

---

## Agentic design intent

### `agentic_summary` field

Every `Tile` has an `agentic_summary` text column. This field is:

- **Nullable** — blank until an agent populates it
- **Agent-owned** — agents write here; users write to `title`, `subtitle`, and `body`
- **Intended format**: XML-nested summaries reflecting the Chart → Grid → Tile hierarchy

Example of intended summary format:

```xml
<chart id="1" title="Q3 Focus">
  <grid depth="0">
    <tile position="4" type="goal">
      <summary>Build and ship mandala-rails MVP.</summary>
    </tile>
    <tile position="0" type="theme">
      <summary>Establish local dev environment for fast iteration.</summary>
      <grid depth="1">
        <tile position="4" type="task">
          <summary>Switch from Neon to local Postgres in development.</summary>
        </tile>
      </grid>
    </tile>
  </grid>
</chart>
```

This format enables efficient context traversal without loading full `body` content. When navigating a chart, read `agentic_summary` first. Load `body` only when the task requires it.

### MCP server (planned)

Issue [#10](https://github.com/zigzagjeff/mandala-rails/issues/10) specifies a Model Context Protocol server for structured agent access to chart data. Tools will include `list_charts`, `get_chart`, `get_grid`, `get_tile`, and `write_agentic_summary`. Until this exists, agents access data via Rails console or direct database queries.

**Do not write to `body` as an agent.** `body` is the user's writing surface. `agentic_summary` is yours.

---

## How Jeff works

- **Shape Up methodology**: fixed time, variable scope. Six weeks is the ceiling, not the target. Scope is cut to ship.
- **Jeff writes first, agents execute**: Jeff drafts issues, commits, and design decisions in his own voice. Agents implement, suggest alternatives, and flag decisions — they don't replace Jeff's voice.
- **Commit messages are human-readable field notes**: Write them as if a capable colleague will read them six months from now. Not `fix bug` — `Fix: drill arrow dropped from Turbo Stream tile update (was missing from turbo template, now uses shared partial)`.
- **Issues are decision artifacts**: If you encounter an architectural decision point while working, file an issue rather than deciding silently. Even if the decision seems obvious.

---

## Conventions

### CHANGELOG.md

Update it with every meaningful change. Follow [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) format. Added / Changed / Fixed / Removed. Version bump when shipping a coherent set of changes.

### Migrations

- Always reversible where possible
- Never drop a column without a data migration plan (migrate values first, then drop)
- Check `db/schema.rb` before writing a migration — understand what's already there

### Tests

Don't skip them to ship faster. This is a learning project and tests are part of the learning. If a test is failing for a known reason, file an issue — don't delete the test.

### Gems

Don't add gems without flagging them in the commit message or issue body. Don't upgrade gems unless asked. Both are decisions, not implementation details.

---

## What not to do

- **Don't refactor speculatively.** Only touch what the current task requires. If you see something worth improving, file an issue.
- **Don't expand tile functionality** beyond the document model (title, subtitle, body). External launchers, image tiles, and embedded media are explicitly out of scope — see issue [#18](https://github.com/zigzagjeff/mandala-rails/issues/18).
- **Don't make architectural decisions silently.** Flag them.
- **Don't upgrade dependencies** unless the task requires it and you've noted it explicitly.
- **Don't write to `body`.** That's the user's field.

---

## See also

- [README.md](./README.md) — project overview and setup
- [CHANGELOG.md](./CHANGELOG.md) — version history
- [GitHub Issues](https://github.com/zigzagjeff/mandala-rails/issues) — open work
