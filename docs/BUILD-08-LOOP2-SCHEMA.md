# Build 08 loop 2: benchmarks, compute, repository symbols, APIs, advisories, registry, paper levels

**Status: lab-proven on `disposable-aieng-build04` (2026-11-09/10), determination ADD THESE CHANGES applied in-loop and promoted as [`supabase/migrations/20261109130000_build08_loop2_numbers_compute_apis.sql`](../supabase/migrations/20261109130000_build08_loop2_numbers_compute_apis.sql) (`main` 3e1bb6b); applied on the clean replay database `disposable-aieng-b08replay` with a schema-identical result (one cosmetic index aside). Owner approval of the Phase A selection and schema recommendation: 2026-11-09 ("approve, yes, confirm, stands"). The loop-2 record itself (counts, question verdicts, deltas, gaps) still awaits John's review.** Nothing here is integrated into `ai-engineer-service` or Mission Control, and nothing is qualified for the remote `aieng-db`. Cycle record: [Build 08 §19](../../../platform/ai-engineer-research-2026-11-02/10-review-workspace/reviews/BUILD-08-KNOWLEDGE-LOOP.md#s19); selection and recommendation: [BUILD-08-LOOP-2-SELECTION](../../../platform/ai-engineer-research-2026-11-02/10-review-workspace/reviews/BUILD-08-LOOP-2-SELECTION.md).

Units: **RV07, RV05, RV04** (primary), **RV03, RV08** (content gaps D-09 and D-15), RV10, RV11, RV12, RV13 (seams).

## A. What the migration does

| Area | Change |
| --- | --- |
| Benchmarks (RV07) | `benchmark_version` entity kind (`version_of` pair added to `catalog.check_relationship_kinds`); `benchmark` attribute schema; `benchmark_score` stream widened (ref `benchmark_version`, subjects `compute_device`/`compute_offering`/`paper`, payload harness/reported_by/effort/cost/run_date/n/CI; scope key = version \| harness \| setting \| reported_by); `ranking.leaderboard` publisher/benchmark version/source/methodology, `leaderboard_edition` as a dated capture, `leaderboard_entry` conditions; document type `leaderboard_page`; unit kinds `leaderboard_row`, `metric_definition`; `eval_row` widened; `api.benchmarks`, `api.benchmark_scores`, `api.leaderboard_diff` |
| Compute (RV05) | `compute_device` and `compute_offering` attribute schemas (`offering_class`); `compute_offering_price` removed in favour of `offering_price` (new units and payload: commitment, interruptible, per, gpu_count, effective_from); `offering_limit` replaces `model_offering_limit`; `price_row` logical key includes commitment; `spec_field` → `entity_attribute` mapping; `api.compute_devices`, `api.compute_offerings`, `api.cheapest_compute` |
| Software (RV04) | document types `api_surface` (derived per release, R3) and `openapi_spec`; unit kinds `api_symbol`, `endpoint`, `parameter`, `schema_component`, `advisory`, `registry_listing`, `paper_section`, `reference`; new table `content.unit_link`; `library_release`, `security_advisory`, `ai_protocol_version`, `mcp_server`, `registry` attribute schemas; `cites` from talks; `api.api_symbols`, `api.symbol_changes`, `api.endpoints`, `api.advisories`, `api.advisories_for`, `api.registry_listings`, `api.protocol_versions` |
| Papers and digests | `api.papers` reads `ingestion_level`/`promotion` from the document linked through `document_about_entity` (role `primary`); digest item kinds `problem`, `method`, `key_result`, `artifact`, `practitioner_change` |
| Refresh | `unit_change.change_kind` admits `format_only`; `api.changes_since` excludes it by default |

Knowledge-side tables after the migration: 172 (catalog 9, content 30, temporal 9, evidence 26, retrieval 55, guidance 4, acquisition 1, verification 1, ranking 3, library 6, knowledge_service 15, taxonomy 9, dataset 4); 33 `api` views, 43 `api` functions.

## B. Sources, drafts and promotion

`supabase/drafts/` keeps the lab sources: `20261109130000_build08_loop2_numbers_compute_apis.sql` (the approved recommendation) and the in-loop fixups `20261109130100` (D-17/18/19/20), `130200` (D-19 corrected, D-21), `130300` (D-35), `130400` (D-36), `130500` (D-39). The promoted migration is their union; a fresh install applies only `supabase/migrations/`. The lab head is `20261109130500` (drafts applied one by one); the workspace generator indexes `supabase/drafts/` so its head assertion matches the lab.

## C. Evidence

| Check | Result |
| --- | --- |
| Replay | promoted file applied on the clean replay database from head `20261108120000` (`scripts/apply-disposable-migration.mjs --source-dir=supabase/migrations`); `pg_dump --schema-only` identical to the lab except the `authoring.event` FK index known from loop 1. The replay's full Supabase stack was not started (memory) |
| `npm run typecheck` / `npm test` | 0 errors / 27 passing |
| `workspace:build` / `check` / `validate` (`--db-url` lab) | `drift: null`, `details: []`; 831 files changed |
| Loop-2 questions ([`reviews/QUERY-LEDGER.jsonl`](../../../platform/ai-engineer-research-2026-11-02/10-review-workspace/reviews/QUERY-LEDGER.jsonl), loop 2) | 19 answered, 1 partial (Q15 content gap); schema calls ≤ 4 for 18 of 20 (Q11 at 6) |
| Traversal T1–T12 | 11 in ≤ 4 reads; T9 in 5 |
| Spend | 37 Firecrawl credits + about USD 0.038 embeddings (ceiling USD 25) |

## D. Consumer impact

- Type contract: [`src/api.ts`](../src/api.ts) adds `ApiBenchmark`, `ApiComputeDevice`, `ApiComputeOffering`, `ApiSymbol`, `ApiEndpoint`, `ApiAdvisory`, `ApiRegistryListing`, `ApiProtocolVersion`, `ApiLeaderboardDiffRow`, `ApiCheapestComputeRow`, `ApiSymbolChange`, `ApiAdvisoryForRow`; [`src/database.generated.ts`](../src/database.generated.ts) regenerated from the lab.
- `platform/knowledge-services/packages/knowledge-db` still breaks on the loop-1 renames (RV21, recorded, not fixed).
- `ai-engineer-service`: not re-proven against this schema.

## E. Deferred and recorded

Overloaded symbols as one unit with an `overloads` attribute; `api.symbol_docs`; dedupe of duplicated vector items from projection re-runs (D-40); the ARC Prize board grammar; the Gemini evaluation PDF results table (an image); six of ten OWASP ASI sections; `implements_protocol` per SDK release; `benchmark_run` and its relationship kinds (remove next loop); the loop-1 deferrals (`knowledge_service` → `ks`, evidence split, relationship verb reduction, materialized L1 views, PostgREST tenant wrappers).
