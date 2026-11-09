# schema-workspace generator

Materializes the agent-readable schema workspace described in
[`docs/SCHEMA_WORKSPACE_MATERIALIZATION_SPEC.md`](../../docs/SCHEMA_WORKSPACE_MATERIALIZATION_SPEC.md).
Inputs are the live database (pg_catalog), `supabase/migrations/` (plus the lab draft directories in
`paths.draftMigrations`, whose ordered files count toward the migration head), `src/database.generated.ts`,
`workspace.config.json`, and the human/model-assisted YAML in `workspace-enrichment/`. Output is
the committed `workspace/` tree (`ai-engineer-schema-workspace/3`).

## Commands

```
node scripts/schema-workspace/cli.mjs <command> [options]

introspect   --db-url <url> [--out ir.json]        pg_catalog → schema-ir.v1 (no rendering)
build        --db-url <url> [--enrichment <dir>]   full pipeline → workspace/ (atomic replace)
check        --db-url <url>                        committed IR vs live DB + generated types; exit 1 on drift
validate     [--db-url <url>]                      re-render committed IR, compare bytes, run catalog examples
materialize  --scope <id|file> [--out <dir>] [--format tree|json-bundle]
enrich       --draft <schema.relation|domain:slug> YAML stub for a new enrichment entry
```

`--db-url` defaults to `AIENG_DB_ADMIN_DSN`, then `AIENG_DB_LOCAL_DSN` (loopback only; a remote value is refused). Exit codes: `0` ok,
`1` domain failure (drift, validation, budget, broken link, example failure), `2` infrastructure
(unreachable DB, IO, usage). Errors are one JSON object on stderr.

npm aliases: `workspace:build`, `workspace:check`, `workspace:validate`, `workspace:materialize`, `test`.

## Pipeline

```
introspect.mjs ──raw rows──▶ ir/build-ir.mjs ──schema-ir.v1──▶ enrichment/load.mjs
                                                        │              │
                                                        ▼              ▼
                                   render/render-workspace.mjs (model → L0–L3 pages, catalog, rules, search)
                                                        │
                                                        ▼
                                   validate.mjs (budgets, links, ids, coverage, grants guard, examples)
                                                        │
                                                        ▼
                                   pipeline.mjs adds fingerprint.json / validation.json / manifest.json
                                                        │
                                                        ▼
                                   write-tree.mjs (stage + rename)
```

Module map: `ir/ids.mjs` owns the stable id formats; `ir/case-branches.mjs` splits the product
dispatcher bodies (`workspace.config.json → operations.dispatchers`) into `when '<op>' then` arms, which
`ir/build-ir.mjs` records as `derived.operations`; `render/operation-page.mjs` renders one `ops/<op>.md`
per arm; `render/relation-sections.mjs` renders one section each and `render/relation-page.mjs` only
orchestrates the spill-to-details budget loop; `render/links.mjs` is the single relative-link adapter;
`render/entry-pages.mjs` renders the START_HERE router (question shape → L1–L4 → page), `MAP.md`
(schemas by lens) and `INDEX.md`; `selection.mjs` turns a scope into the set of relations, functions,
stubs, tasks, queries and operations to render.

Lenses: every page and search-index entry carries a `lens` (ours, private, corpus, evidence, machinery,
legacy) derived from `workspace.config.json → lenses` (schema map, per-relation/function overrides,
trigger functions → machinery) or a `lens:` override in `workspace-enrichment/relations.yaml` /
`domains.yaml`. `lenses.hidden` names the lenses START_HERE and MAP collapse into one line.

Determinism: the IR and enrichment are canonicalized (sorted keys) in memory so a build from the
database and a re-render from `workspace/schema-ir.json` produce identical bytes. Only
`manifest.json → build.volatile.introspected_at` varies between builds.

## Scopes

`workspace-scopes/*.json` (`ai-engineer-schema-scope/1`) select relations/functions by glob and
domain, tasks by slug, queries and `operations` by glob. Out-of-scope FK targets get `*.stub.md`
pages; vocabularies are always complete. `materialize --scope research` writes to
`workspace-bundles/<id>` by default (gitignored).

Mission scopes: `research`, `ingestion`, `content-refresh`, `course-authoring`, `learner-assistant`,
`report-writer` (each excludes the machinery/legacy lenses and selects the product operations the
mission calls); `db-aware-research` and `ingestion-author` remain as the older read/write pair; `full`
is everything.

## Tests

`npm test` runs `test/*.test.mjs` (pure helpers: canonicalization, pg array parsing, function-body
extraction, dispatcher arm parsing, argument parsing, FK folding; `scopes.test.mjs` loads the committed
workspace and checks that every scope selects known pages, that mission scopes exclude machinery, and
that every search entry carries a lens). Database-backed behaviour is covered by CI running
`workspace:check` and `workspace:validate` against a reset disposable stack.
