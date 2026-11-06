# schema-workspace generator

Materializes the agent-readable schema workspace described in
[`docs/SCHEMA_WORKSPACE_MATERIALIZATION_SPEC.md`](../../docs/SCHEMA_WORKSPACE_MATERIALIZATION_SPEC.md).
Inputs are the live database (pg_catalog), `supabase/migrations/`, `src/database.generated.ts`,
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

`--db-url` defaults to `POSTGRES_URL_NON_POOLING` / `POSTGRES_URL`. Exit codes: `0` ok,
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

Module map: `ir/ids.mjs` owns the stable id formats; `render/relation-sections.mjs` renders one
section each and `render/relation-page.mjs` only orchestrates the spill-to-details budget loop;
`render/links.mjs` is the single relative-link adapter; `selection.mjs` turns a scope into the set
of relations, functions, stubs, tasks, and queries to render.

Determinism: the IR and enrichment are canonicalized (sorted keys) in memory so a build from the
database and a re-render from `workspace/schema-ir.json` produce identical bytes. Only
`manifest.json → build.volatile.introspected_at` varies between builds.

## Scopes

`workspace-scopes/*.json` (`ai-engineer-schema-scope/1`) select relations/functions by glob and
domain. Out-of-scope FK targets get `*.stub.md` pages; vocabularies are always complete.
`materialize --scope db-aware-research` writes to `workspace-bundles/<id>` by default (gitignored).

Both `db-aware-research` and `ingestion-author` include `research.report*` relations,
report guards, and the `reports.*` read catalog. Start at `dom:research`, then
`task:navigate-report` for revision, section, evidence, coverage, artifact and lifecycle
reads, or `task:register-report` for v1 registration. The existing `task:publish-report`
documents the legacy compatibility path. Report guidance lives in enrichment; catalog
introspection supplies constraints, grants and foreign-key navigation without a separate
report renderer. Catalog reads are bounded slices; KS `report_get` assembles a v1 package.

## Tests

`npm test` runs `test/*.test.mjs` (pure helpers: canonicalization, pg array parsing, function-body
extraction, argument parsing, FK folding). Database-backed behaviour is covered by CI running
`workspace:check` and `workspace:validate` against a reset disposable stack.
