---
name: mandala
description: Read and annotate Mandala charts via bin/mandala (CLI), the mandala MCP tools, or API v1 directly. Use for ANY request to read a chart, grid, or tile, traverse a chart's structure, drill a tile into a sub-grid, or write agentic summaries. Covers command reference, the traversal model, and the summarization workflow.
argument-hint: "[command] [args...]"
---

# /mandala — drive the Mandala chart tool

One product, three faces over the same API v1: `bin/mandala` for shell
pipelines, the `mcp__mandala__*` tools when the MCP server is registered,
and raw HTTP for anything else. Every capability is one HTTP call; the
faces never diverge. Full API contract: [AGENTS.md](../../../AGENTS.md).

## Agent invariants

**MUST follow:**

1. **Never write `body` unprompted.** `body` is the user's writing
   surface; `agentic_summary` is yours. Draft into `body` only when the
   user explicitly asks you to write for them.
2. **Summaries before bodies.** `grid <id>` returns all nine tiles with
   titles, subtitles, and summaries — no bodies. Fetch `tile <id>` (the
   only call that returns `body`) only when the task needs the document
   itself.
3. **Check the exit code.** XML goes to stdout, errors to stderr with a
   non-zero exit. In pipelines, a silent empty result means you ignored
   a failure.
4. **There are no deletes.** The API deliberately has none — do not
   improvise one via Rails console when asked to remove content; that is
   the user's call in the UI.
5. **Prefer the MCP tools when registered** (`mcp__mandala__list_charts`
   etc.); reach for `bin/mandala` when composing with other CLIs or when
   no MCP session exists. Same five capabilities either way.
6. **The Rails server must be running** (`bin/dev`). A connection
   refusal means the server, not the tool.

## Quick reference

```sh
bin/mandala charts                      # list the user's charts
bin/mandala chart 2                     # metadata + root_grid_id
bin/mandala grid 15                     # nine tiles, no bodies
bin/mandala tile 128                    # full tile including body
bin/mandala drill 128                   # create/return the tile's child grid
bin/mandala summarize 128 "<slug>…</slug>"   # write agentic_summary
```

Env: `MANDALA_URL` (default `http://localhost:3000`), `MANDALA_API_TOKEN`
(`bin/rails runner 'print User.first.api_token'`).

## The traversal model

```
charts → chart <id> → root_grid_id
                        └── grid <id> → nine tiles (positions 0–8, center 4)
                                          ├── child_grid_id → grid <id> …
                                          └── tile <id> → body (only when needed)
```

- A chart is born with its root grid and nine tiles; `drill` creates or
  returns a tile's child grid (idempotent — safe to call to navigate).
- `heading_level` on each tile encodes its place in the hierarchy:
  1 = the goal (depth-0 center), 2 = themes, 3 = tasks. When assembling
  chart context, order tiles by depth then position.
- Writes go through `summarize` (CLI) / `write_agentic_summary` (MCP);
  `PATCH /api/v1/tiles/:id` additionally accepts `title`, `subtitle`,
  and `body` for user-directed edits.

## Workflow: summarize a tile

Follow the procedure in AGENTS.md (§ Populating `agentic_summary`):

1. `grid <id>` for the tile's grid → the eight neighbor titles.
2. `tile <id>` for the tile's own title and body.
3. If the grid has a `parent_tile_id`, fetch that tile for anchor context.
4. Compose a snake_case XML slug naming the tile's **unique contribution
   within its grid** — neighbors force distinctness. Not `<hiring>` but
   `<revenue_hiring_growth>Hiring three new sales reps to hit 2026
   revenue targets</revenue_hiring_growth>`.
5. `summarize <id> "<slug>…</slug>"`.

Re-summarize when a tile's own title or body changes materially;
neighbors changing is usually not reason enough.

## Workflow: assemble chart context

Descend breadth-first reading only grids (never bodies): `chart` →
`root_grid_id` → `grid` → follow each `child_grid_id`. The per-tile
slugs nest into the chart-level XML document shown in AGENTS.md. Load a
`body` only if the user's question is about that document's content.

## Errors

| Symptom | Meaning |
|---|---|
| `401` / unauthorized on stderr | `MANDALA_API_TOKEN` missing, stale, or regenerated |
| `404` | wrong id, or the record belongs to another user's chart |
| `422` with `{ "errors": [...] }` | validation — e.g. title over `TITLE_MAX_LENGTH` |
| connection refused | Rails server not running — `bin/dev` first |
| usage text on stderr | unknown subcommand or missing argument |
