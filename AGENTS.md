# AGENTS.md

Orientation for AI agents working in this codebase. Read this before touching anything.

---

## Who built this and how

Jeff Long built mandala-rails with AI assistance as a first-class part of the workflow. The arrangement is explicit: Jeff shapes the work, sets constraints, and makes judgment calls. Agents execute, suggest, and flag decisions they can't resolve confidently.

This is not a repo where AI quietly generated everything and a human rubber-stamped it. The human orchestration layer is intentional and visible — in the commit messages, the issue bodies, and this file. If you're an agent reading this: operate accordingly.

---

## What this is

A web-based Mandala Chart tool. The Mandala Chart is a 9-square planning framework rooted in Miller's Law (7 ± 2). Users create mandalas, fill tiles, and drill down into sub-grids — creating a fractal structure for planning, brainstorming, or writing.

Tiles are documents. Each has a `title`, `subtitle`, and `body`. The tile card surface shows title and subtitle. The body opens in a full document view with a Lexxy rich text editor. This is the product. Do not expand it into something else without an issue and a decision.

Current version: **0.3.0** (see [CHANGELOG.md](./CHANGELOG.md)).

---

## Architecture orientation

### Stack

- Rails 8.1, SQLite, Propshaft, Import maps
- Hotwire: Turbo Frames for inline edit, Turbo Streams for partial page updates
- Lexxy for rich text (Action Text under the hood)
- Kamal for deployment
- SQLite in every environment (file-based, `storage/*.sqlite3`); the Rails 8 Solid stack (Queue, Cache, Cable) runs on SQLite — no Redis, no external database

### Data model

A Mandala has a title and holds up to 81 tiles, organized into a root grid
(always present) and up to 8 child grids (created lazily, one per drilled
surrounding tile). Hierarchy: **Mandala > Grid > Tile** — three concrete nouns,
recursion living inside `Grid`.

```
User
└── Mandala (max 9 per user — Miller's Law)
    └── Grid (root + one per drilled tile)
        └── Tile (9 per grid, positions 0–8)
```

Key files:

| Path | Purpose |
|---|---|
| `app/models/mandala.rb` | Mandala model — belongs to user, has many grids; seeds the root center tile from its title |
| `app/models/grid.rb` | Grid model — root? when parent_tile_id is nil |
| `app/models/tile.rb` | Tile model — position 0–8, TITLE_MAX_LENGTH, SUBTITLE_MAX_LENGTH constants; center? vs. surrounding |
| `app/controllers/mandalas_controller.rb` | Mandala CRUD |
| `app/controllers/tiles_controller.rb` | Tile edit, update, drill |
| `app/controllers/grids_controller.rb` | Grid show with breadcrumb |
| `app/views/tiles/_tile.html.erb` | **Single source of truth for tile card markup** — use this partial everywhere |
| `config/routes.rb` | Nested: mandalas → grids, mandalas → tiles (with drill member route) |
| `db/schema.rb` | Current schema — read this before writing migrations |

### Turbo pattern

Tile editing uses Turbo Frames. The edit form loads inline; save triggers a Turbo Stream that replaces the tile frame in place. The `_tile.html.erb` partial is what the stream replaces — keep it as the single source of truth.

---

## Agentic design intent

### `agentic_summary` field

Every `Tile` has an `agentic_summary` text column. This field is:

- **Nullable** — blank until an agent populates it
- **Agent-owned** — agents write here; users write to `title`, `subtitle`, and `body`
- **Intended format**: XML-nested summaries reflecting the Mandala → Grid → Tile hierarchy

Example of intended summary format:

```xml
<mandala id="1" title="Q3 Focus">
  <grid depth="0">
    <tile position="4" heading_level="1">
      <summary>Build and ship mandala-rails MVP.</summary>
    </tile>
    <tile position="0" heading_level="2">
      <summary>Establish local dev environment for fast iteration.</summary>
      <grid depth="1">
        <tile position="4" heading_level="2">
          <summary>Establish the SQLite dev database and load fixtures.</summary>
        </tile>
      </grid>
    </tile>
  </grid>
</mandala>
```

This format enables efficient context traversal without loading full `body` content. When navigating a mandala, read `agentic_summary` first. Load `body` only when the task requires it.

### API v1 — how agents read and write

The versioned JSON API (issue [#25](https://github.com/zigzagjeff/mandala-rails/issues/25), shipped) is the agent's front door. Every request carries a bearer token:

```
Authorization: Bearer <api_token>
```

The token lives on the user (`User#api_token`, `has_secure_token`). Retrieve it locally with `bin/rails runner 'print User.first.api_token'`; regenerate with `user.regenerate_api_token` if leaked. One token, one user, scoped to that user's mandalas. Rotate on any suspicion of a leak, and as a habit whenever you wire up a new agent integration — the blast radius of a leaked token is that one user's mandalas, read and write, so rotation is cheap insurance (issue [#100](https://github.com/zigzagjeff/mandala-rails/issues/100)).

Requests are rate-limited (issue [#89](https://github.com/zigzagjeff/mandala-rails/issues/89)): **60 requests/minute per token**, with a wider 120/minute per-address backstop against token guessing. Exceeding either returns `429` with `{ "error": "Too many requests" }`. Budget accordingly when polling `?since=` or traversing large mandalas — the traversal model below exists so you rarely need more.

The traversal model: read summaries first, load a body only when the task demands it.

| Verb + path | Returns |
|---|---|
| `GET /api/v1/mandalas` | the user's mandalas |
| `GET /api/v1/mandalas/:id` | mandala metadata + `root_grid_id` |
| `POST /api/v1/mandalas` | creates a mandala (born with root grid + 9 tiles, center titled from the mandala) |
| `GET /api/v1/grids/:id` | grid + its 9 tiles embedded — titles, subtitles, `agentic_summary`, `heading_level`, `child_grid_id`; **no bodies** |
| `GET /api/v1/tiles/:id` | full tile including `body` as plain text |
| `PATCH /api/v1/tiles/:id` | writes `title`, `subtitle`, `body`, `agentic_summary` |
| `POST /api/v1/tiles/:id/drill` | creates/returns the tile's child grid |

`drill` is a priced bend of C2.13 (canon C0.3): the CRUD-conforming shape would be `POST /api/v1/tiles/:id/grid` (create-or-return the child grid), but `drill` is the domain verb (C4.1) and reads clearer to agent consumers than a nested `grid` resource. It stays as the published v1 contract; a conforming alias would only be added if an external consumer needed it (issue [#65](https://github.com/zigzagjeff/mandala-rails/issues/65)).

Descend by following `root_grid_id` → tiles → `child_grid_id`. Errors are `{ "errors": [...] }` with 401/404/422. No deletes — the API deliberately has none.

`heading_level` on every tile is derived from stored grid depth (issue [#63](https://github.com/zigzagjeff/mandala-rails/issues/63)): depth 0 center → 1, depth 0 surrounding → 2, depth 1 center → 2, depth 1 surrounding → 3. When assembling mandala context client-side, order by depth then position — the same order the server derives in one query.

### Populating `agentic_summary` (issue #24)

To summarize one tile:

1. `GET /api/v1/grids/:id` for the tile's grid → the 8 neighbor titles.
2. `GET /api/v1/tiles/:id` for the tile's own title and body.
3. If the grid has a `parent_tile_id`, `GET` that tile for parent context.
4. Compose a snake_case XML slug capturing the tile's **unique contribution within its grid** — neighbors force distinctness, the parent anchors meaning. A human would write `<hiring>`; seeing the whole grid, write `<revenue_hiring_growth>Hiring three new sales reps to hit 2026 revenue targets</revenue_hiring_growth>`.
5. `PATCH /api/v1/tiles/:id` with `{ "tile": { "agentic_summary": "<slug>…</slug>" } }`.

Per-tile slugs are what is stored; the nested mandala document above is what gets *assembled* from them at read time. Re-summarize a tile when its title or body changes materially; neighbors changing is usually not reason enough.

### CLI

`bin/mandala` (issue [#64](https://github.com/zigzagjeff/mandala-rails/issues/64)) is the Unix-pipe face of the same API — one HTTP call per subcommand, nested XML to stdout, errors to stderr:

```sh
bin/mandala list                        # list mandalas
bin/mandala show 2                      # metadata + root grid id
bin/mandala grid 15                     # nine tiles, no bodies
bin/mandala tile 128                    # full tile including body
bin/mandala drill 128                   # create/return the child grid
bin/mandala summarize 128 "<slug>…</slug>"
```

Same env vars as the MCP server; composes with `gh`, `jq`-adjacent tooling, and other CLIs in agent pipelines.

### MCP server

`bin/mcp` (issue [#10](https://github.com/zigzagjeff/mandala-rails/issues/10), shipped) is a stdio MCP server exposing five tools: `list_mandalas`, `get_mandala`, `get_grid`, `get_tile`, and `write_agentic_summary`. It is a consumption layer over API v1 — every tool is one HTTP call rendered as nested XML, no new capabilities. It boots without Rails; configure with env vars:

```sh
claude mcp add mandala \
  --env MANDALA_API_TOKEN=$(bin/rails runner 'print User.first.api_token') \
  --env MANDALA_URL=http://localhost:3000 \
  -- bin/mcp
```

The Rails server must be running for the tools to answer.

**Do not write to `body` as an agent.** `body` is the user's writing surface. `agentic_summary` is yours. (The PATCH endpoint permits `body` so a user can direct an agent to draft for them — but unprompted, stay out.)

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

### Fixing bugs

A bug fix begins with its reproduction, seen failing (canon C8.6). Invoke the `bugs-reproducer` skill before investigating any fix — it classifies the bug (model/controller, CLI/MCP, UI/Turbo, or upstream Lexxy) and produces the failing test. Fix under `dhh-coder`; then validate two-sided (C8.7): the bug reproduces on `main` and is gone on the branch, through the real app. Editor-core bugs (typing, cursor, formatting inside Lexxy) belong upstream in `basecamp/lexxy` — file or link the issue there rather than papering over them here, as with #61/#12 → lexxy#1057.

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
