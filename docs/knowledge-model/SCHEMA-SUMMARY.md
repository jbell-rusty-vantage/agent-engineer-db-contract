# Database schema summary

Applied to **supabase-blue-ocean** (`wkythqbofmckbuoothhn`) on 2026-09-11. Contract **0.3.0**, migration head **20260912011200**. Counts exclude child vector partitions.

| Schema | Tables | Purpose and main entry points |
|---|---:|---|
| `corpus` | 51 | Industry identities: `entity`, aliases/identifiers, 36 typed entity tables, one `relationship` table. Includes media channels/series/works, events/talks, repository revisions/modules/files, model specifications and registry listings. |
| `temporal` | 9 | Two-clock facts: `knowledge_head`, `knowledge_batch`, `extent`, stream/event vocabularies, `stream`, `segment`, `event`, `event_occurrence`. World intervals plus knowledge-sequence history. |
| `taxonomy` | 9 | Versioned facets/terms, entity and relationship vocabularies, term target restrictions. `assignment` targets an entity, knowledge record, or lesson. |
| `evidence` | 32 | Sources/captures/locators, provider queries/results/encounters, extraction and attribution, claims and verification. `claim_subject`, `claim_record`, `segment_support` connect evidence to the graph. Existing verification ledgers remain. |
| `content` | 18 | Document types/routing, documents/versions, representations/nodes, transformations and conversion decisions. Summaries carry source-node and transformation lineage. |
| `knowledge` | 13 | `record` plus nine typed engineering records and `record_entity_link`. Retains assurance vocabulary and runtime reconciliation. Code examples reference captured repository files. |
| `retrieval` | 37 | Chunking/chunks/spans, five-way `projection_target`, search projections, embeddings, publications, retrieval runs and packets. Eleven 1536-dimensional half-vector partitions, each indexed with HNSW. |
| `ranking` | 16 | Entity-keyed metrics, feature values and ranking results. Existing group/policy/run/leaderboard/selection control tables remain for runtime references. |
| `staging` | 4 | Generic `candidate`, `identity_match`, `resolution_decision`, `vetting_decision`. |
| `api` | 0 | Eight views and application RPCs. Start with `entities`, `current_facts`, `current_relationships`, `events_current`; RPCs below. |
| `orchestration` | 36 | Missions, work, capabilities, attempts, intents, receipts and artifacts; verification extraction operations. |
| `knowledge_service` | 11 | Durable service operations, steps/events, outbox, callbacks and runtime control. Temporal batches emit `knowledge.batch_sealed`; projection rebuilding emits `projection.rebuilt`. |
| `research` | 8 | Reports, versions, findings and mission research outputs. |
| `evaluation` | 30 | Datasets, cases, graders, scores, review tasks and verification benchmark/adjudication records. |
| `curriculum` | 13 | Learning paths, modules, lessons, challenges and evidence/knowledge associations. |
| `observability` | 7 | Traces, spans and normalized runtime events. |
| `provenance` | 4 | Project objects, bindings, edges and evidence. |
| `public` | 41 | **Protected:** 25 pre-research/research-starter tables. Also 16 retained factory tables. Both YouTube channels and all 2,252 starter videos are unchanged. |

`util` supplies UUID, tenant and mutation helpers; `research_private` holds protected pipeline routines. Platform-managed namespaces are `auth` (23 tables), `storage` (8), `realtime` (3), `vault` (1), `extensions`, `graphql`, `graphql_public`, and `supabase_migrations`. There is no separate application `foundation` schema: the foundation migration creates shared helpers and roles.

## Reading and writing

Set the trusted server-side `app.tenant_id` context before using the bounded schemas. Missing context fails closed. Applications read through `api`; pipeline agents propose/extract; `executor_service` admits graph facts through the temporal helpers. Direct writes to temporal history and relationships are revoked, including from `service_role`.

```sql
begin;
set local app.tenant_id = '00000000-0000-7000-8000-000000000001';
select temporal.begin_batch(p_expected_head => 0);
-- temporal.make_extent(...), assert_state(...), assert_relationship(...), assert_event(...)
select temporal.commit_batch(:receipt_id, :idempotency_key, :sha256, '{}'::jsonb);
commit;
```

`api.resolve_entity(text)` finds identities. `entity_card(id)` gives a current overview; `entity_at(id, world_time, knowledge_seq)` replays facts. `relationships`, `entity_timeline` and `what_changed` expose graph and history. `summary_evidence` expands a summary into faithful nodes/chunks/locators. `evidence_packet` includes available node timecodes. `hybrid_knowledge_search_1536` adds entity/document/content/time/assurance/publication filters to exact, full-text, trigram and vector retrieval.

The eleven spaces are `engineering_claims`, `tool_capabilities`, `implementation_examples`, `paper_case_study_knowledge`, `entity_profiles`, `model_capabilities`, `benchmark_intelligence`, `entity_timeline`, `market_intelligence`, `document_summaries`, and exploratory `source_native_sections`. Document types route into spaces; they are not spaces themselves.

## Native ledger provenance (migration 20261031010000)

Contract **0.6.0**. Applied to the local disposable `supabase_db_disposable-overnight-20261029` on 2026-10-31, and on
2026-11-01 (2026-11-02T03:05Z) to the owner-declared disposable remote `wkythqbofmckbuoothhn` (aieng-db,
`supabase-blue-ocean`): head `20261025010200` (186) → `20261031010000` (187), owner approval in sitting II (OVE-206).
Path: `install-ai-engineer.mjs --remote-reinstall --skip-mission-control --no-seal-key` against
`deployments/ai-engineer/target.toml` (identity `matched`, DSN TLS `verify-full` with the Supabase root CA); steps
`component:current`, `domain-migrations:applied` (`20261031010000` only), `custody-grants:verified`; a repeat run
reported `changed: false`. Verified read-only afterwards: `orchestration.operation_receipt_target` with its 12 columns
and forced RLS, the nine `operation_intent` origin/`mc_*` columns, `operation_receipt.origin_digest`,
`evidence.claim.producer_origin_digest` (nullable `producer_attempt_id`) and `orchestration.mission_run_effects`;
Knowledge Services' pinned workspace head check (`assertHeadMatches`) passes against the remote. Cloud type generation
differs from `src/database.generated.ts` only in generator formatting (`__InternalSupabase` block, parenthesized
conditional types), no schema content. Mission Control and the seal key were not touched. The table above predates it.

- `orchestration.operation_intent` carries `origin_digest`/`origin_kind` (restating `knowledge_verification.origin`, no cross-schema FK) and the Mission Control coordinates `mc_mission_id`, `mc_run_id`, `mc_activation_id`, `mc_operation_id`, `mc_operation_attempt`, `mc_execution_generation`, `mc_lane` (all required exactly when `origin_kind = 'mission_invocation'`; immutable). `mission_id` remains the uuid FK to `orchestration.mission` and is not the Mission Control id. `operation_receipt.origin_digest` repeats the digest.
- `orchestration.operation_receipt_target`: one immutable row per native row a receipt `created`, `reused`, `superseded` or `staged`, with `role` (`subject`, `canonical`, `supporting`, `provenance`, `staging`, `projection`), the `proposal_id`, `entity_id`+`entity_kind` (FK to `corpus.entity (tenant_id, id, kind)`) and `claim_id` (FK to `evidence.claim`). `target_id` is text (composite targets are JSON tuples). Written by `executor_service` in the apply transaction; forced RLS.
- `evidence.claim.producer_attempt_id` is nullable; `producer_origin_digest` was added and `claim_producer_identity` requires one of them.
- `orchestration.mission_run_effects` (security invoker; `executor_service`, `control_plane`): intent → receipt → target for intents with `mc_run_id`, so "everything run X produced" is `select * from orchestration.mission_run_effects where mc_run_id = $1`.

Generated rows, insert/update shapes, relationships and RPC signatures live in [`src/database.generated.ts`](../../src/database.generated.ts). Import `Database` from `@aiengineer/database-contract`. See [deployment notes](MIGRATION-RESULT.md) for implementation decisions and proof receipts.
