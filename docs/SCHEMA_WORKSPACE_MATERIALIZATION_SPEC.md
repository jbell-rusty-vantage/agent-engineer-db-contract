# Schema workspace materialization, knowledge intents, and the three-way eve experiment

**Status:** implemented (M1–M4) and measured (M5–M6) on an isolated disposable database on 2026-09-12; see the "Implementation record" block below for where the measurements diverge from the estimates in the body. Result-shaped statements in §4–§8 were written before implementation; the record and `research_ingestion_systems_agent/experiments/exp3-schema-workspace/results/README.md` are the measurements.
**Date:** 2026-09-11 (spec), 2026-09-12 (implementation record)
**Contract baseline:** `@aiengineer/database-contract` 0.3.0, migration head `20260912011200` at spec time; `20260912040000` after the contract additions below (km_13–km_15, not yet deployed to `supabase-blue-ocean` / `wkythqbofmckbuoothhn`)

### Implementation record (2026-09-12)

| Item | Spec | Measured / shipped |
|---|---|---|
| Generator | `ai-engineer-db-contract/scripts/schema-workspace/` (§4) | Shipped: `introspect`, `build`, `check`, `validate`, `materialize`, `enrich --draft`; npm `workspace:*`, `test`; CI runs `check` + `validate` after `db:reset`. See `scripts/schema-workspace/README.md`. |
| Determinism | byte-identical rebuild | Confirmed; only `manifest.json → build.volatile.introspected_at` varies. IR and enrichment are canonicalized in memory so re-rendering from `workspace/schema-ir.json` is byte-identical (`validate` → `rerender_differences: 0`). |
| Full workspace size | 1.8–2.5 MB (§4 estimate) | 650 files, 6.7 MB on disk, of which `schema-ir.json` is 4.1 MB; pages alone ≈ 2.6 MB. |
| Scoped `db-aware-research` bundle | 350–450 KB | 267 files, 1.03 MB (113 relations, 63 functions, 9 stubs, all 12 vocabularies); `search/index.json` 195 KB (target ≤ 250 KB). |
| Budgets | `schema_readme_bytes` 12288, `search_index_bytes` 256000 | Raised to 16384 and 512000 after measurement (`workspace.config.json`); all other budgets as specified; 0 `SIZE_BUDGET_EXCEEDED`. |
| Enrichment | §4.7 domains, §5.4 catalog | 18 domains / 20 schemas, 63 relation overlays, 46 terms, 14 tasks, 27 catalog queries (26 executable, `retrieval.hybrid_search` pending: needs an embedding), 13 ingestion rules; 83 examples execute under their declared roles. |
| Drift detection | `check` exit 1 with structured diff | Confirmed against an injected column and grant; diff lists exactly the injected changes. |
| Contract additions | §6 artifact/intent codes, `api.knowledge_head()` | km_13 (codes + `api.knowledge_head()`), km_14 (`artifact_lineage` grants; select-only policy on the three global vocabularies that inherited deny-all), km_15 (`operation_receipt` tenancy derived from the owning intent). km_14/15 were discovered by the executor and the experiment fixture, not anticipated by the spec. |
| Executor (M3/M4) | §5–§7 | Shipped in `ai-engineer-knowledge-services` (`packages/schema-workspace`, `packages/db-read`, `packages/ingestion`; `knowledge` bin, 12 MCP tools, `/knowledge/:op`, three skills). Not done: retrieval read variant, `knowledge_service.operation` row/outbox, bucket upload by default, pin swap from `link:` to a git ref. |
| Experiment (M5/M6) | §8, A/B first, C later | Fixture (head 4, 32 entities from the three sample reports), gold, evidence captures, runner, blinded evaluator shipped in `research_ingestion_systems_agent/experiments/exp3-schema-workspace/`. All three arms ran against the shipped executor, N=3 each (9 runs; a 402 credit outage split the matrix into two sessions, and the second session used the workspace with three added task pages, the executor duplicate fix, and the refactored runner — confounds stated in the results README). Means: input tokens A 11.4M / B 15.5M / C 13.9M; gateway cost A $3.46 / B $4.61 / C $4.62; tool calls A 159 / B 131 / C 214 (failed 17.7 / 29.7 / 3.7); canonical entity hit rate 1.0 and 0 duplicates in every run; stale-fact fix rate A 0.083 / B 0.50 / C 0.167; gold fact recall A 0.178 / B 0.422 / C 0.067, precision A 0.875 / B 1.0 / C 1.0; false stale closures A 0 / B 0.33 / C 0; reads before first DB op A 2.7 / B 9.3 / C 11; ingest validity A 0.985 / B 0.68 / C 1.0; judge mean A 2.11 / B 2.46 / C 2.19 (0–5). Consistent under §8's every-run rule only: ingest validity A,C > B and reads-to-first-DB-op A < B, C. Everything else overlaps at N=3. |
| Finding that changed the workspace | §4.7 rules as data | The unreviewed rule `price.scope_key_is_unit` plus the `compose-ingestion-intent` example told agents to key price series by unit unconditionally; on a database whose series use other keys (the fixture: `input_tokens`) that leaves stale segments current. A/C runs that followed it fixed 0/8 stale facts; B, reading the DB directly, reused the existing keys and fixed 6/8. Corrected 2026-09-12: a new series defaults to the unit, an existing series keeps its key (rule, tasks, overlay, terminology, domain text), and the KS planner's rewrite is now slot-aware (reuses the existing same-unit series key, `reason: existing_series_reused`; proven on the fixture: the stale segment closes on the same key). Not re-measured. The lesson generalizes: curated guidance that conflicts with existing data is worse than no guidance, and `find-stale-facts`/`verify-ingestion-result` now make the receipt (`closed` rows) the test of a fix. |
| Workspace follow-ups from the runs | — | `task:compose-ingestion-intent`, `task:find-stale-facts`, `task:verify-ingestion-result` were referenced by the spec and skills but absent from the enrichment; added (17 tasks). Executor: parallel duplicate `ingest apply` surfaced 23505 instead of `duplicateOf`; fixed and confirmed in the second session (12× `duplicateOf`, 0× 23505). Arm C exhausts its tool-call budget with parallel MCP calls and twice finished without a report. |
**Repos in scope:** `ai-engineer-db-contract` (generator, IR, workspace, contract additions), `ai-engineer-knowledge-services` (executors, read API, MCP, skills, storage), `research_ingestion_systems_agent` (eve proving ground), `ai-engineer-mission-control` (consumer; boundaries only)
**Authority above this spec:** `ai-engineer-meta/ai-engineer-architecture/CONTEXT.md` → `specs/mission-control/MISSION_CONTROL_ARCHITECTURE.md` → `specs/research-ingestion-blueprint/WHEN_AND_WHERE_TO_INGEST.md` → ADRs. The 2026-09-10 handoff (`notes/KNOWLEDGE_SERVICES_SCOPE_HANDOFF.md`) is planning context; where it conflicts with current migrations or those documents, this spec says so explicitly (§2.5).

Companion documents (linked from the sections that need them):

| Document | Contents |
|---|---|
| [`schema-workspace/WORKSPACE_LAYOUT_AND_SAMPLES.md`](schema-workspace/WORKSPACE_LAYOUT_AND_SAMPLES.md) | Directory tree, size budget per layer, realistic sample artifacts for the L0→L3 drill-down, scoped-materialization example |
| [`schema-workspace/INTENT_AND_EXECUTOR_CONTRACTS.md`](schema-workspace/INTENT_AND_EXECUTOR_CONTRACTS.md) | `knowledge-read-intent.v1`, `knowledge-read-snapshot.v1`, `knowledge-ingestion-intent.v1`, `knowledge-ingestion-plan.v1`, `knowledge-ingestion-receipt.v1`, named-query catalog, error codes, examples |
| [`schema-workspace/SKILLS.md`](schema-workspace/SKILLS.md) | Drafts of the `schema-explore`, `knowledge-db`, and `knowledge-ingest` skills: procedure, gates, references, recovery |
| [`schema-workspace/EXPERIMENT_PROTOCOL.md`](schema-workspace/EXPERIMENT_PROTOCOL.md) | The A/B-first, C-later eve experiment: arms, task brief, fixture, isolation, metrics, evaluator procedure, run manifest |

---

## 0. Summary of decisions

1. **The workspace is a projection of a canonical intermediate representation (`schema-ir.v1`), not of the database directly.** Introspection, generated types, migration head, vocabulary snapshots, and curated enrichment are merged into one IR; every surface (Markdown layers, search index, named-query catalog, MCP `schema_*` responses, TS path hints) is rendered from that IR. This is what makes full and scoped materialization consistent and makes drift detection a digest comparison instead of a rewrite-and-diff.
2. **Generator and IR live in `ai-engineer-db-contract`** (`scripts/schema-workspace/`, output committed under `workspace/`). The workspace is a contract artifact, versioned with the migrations that shape it. Knowledge Services consumes it as a pinned dependency and never regenerates it from the live database at request time.
3. **Curated enrichment is data, kept apart from derived facts.** `workspace-enrichment/*.yaml` holds domain maps, aliases, terminology, task entry points, semantic relationships, and examples. Every enrichment entry carries `provenance: human | model_assisted` and is validated against the IR (referenced relations/columns/functions must exist; examples must parse; named queries must match the catalog). Rendered pages mark enrichment visibly (`> curated`) so agents can tell database-enforced structure from guidance.
4. **One sandbox-facing executor host, three command families.** The verification executor (`apps/verification-executor`) becomes the **knowledge executor** host that also serves `knowledge-db` (schema + read) and `knowledge-ingest` (ingestion). Same remote-mode trust boundary (`*_EXECUTOR_URL`, credentials never enter the sandbox), same exit lattice (0/1/2), same content-addressed store, same MCP server. New capability code lives in KS packages (`packages/schema-workspace`, `packages/db-read`, `packages/ingestion`) so the platform API/MCP/worker can compose the same libraries later. A second executor process was rejected: it would double deployment config, connections, and pack-sandbox artifacts without adding a trust boundary; role separation happens inside Postgres (`SET ROLE pipeline_agent` for reads, `SET ROLE executor_service` for ingestion).
5. **Reads and retrieval are one contract (`knowledge-read-intent.v1`) with typed operation variants**, because the thing that matters downstream, the input snapshot, must be one object with one digest and one knowledge head. Retrieval search is a variant, not a sibling contract.
6. **Ingestion is intent → deterministic executor → receipt, mapped onto the temporal helpers exactly.** The executor opens `temporal.begin_batch(p_expected_head := <snapshot knowledge_seq>)`, so stale snapshots fail closed with the database's own `rebase_required` (SQLSTATE 40001). Per-proposal outcomes use the blueprint promotion vocabulary; the receipt uses the `operation_receipt` outcome vocabulary; `rebase_required` is a transaction-level failure, not a proposal outcome.
7. **Storage reuses what exists**: bucket `research-ingestion-intents` (already created, no client policies), `SupabaseArtifactStore`, `orchestration.artifact` + `artifact_lineage`. New: six `artifact_type` codes and one `intent_type` code, added by migration in db-contract.
8. **MCP extends existing servers.** The executor MCP gains `schema_*`, `db_*`, `ingest_*` tools generated from the same Zod schemas as the CLI. The platform `apps/mcp` re-exports them by proxy in a later phase; `raw_sql` stays forbidden on both.
9. **The experiment runs A and B first**, on an isolated local Postgres 17 stack reset per run, with a fixed evidence set, a seeded partly-stale OpenAI subgraph, the same model and budgets, and a runner extended to emit `metrics.json`. Arm B is executable with `supabase db query --db-url` but is a *stronger-operation* baseline (raw SQL, direct role use); the protocol says how to read that.

The first implementation milestone is **M1: IR + full workspace generator + validator + CI check in db-contract** (§9).

---

## 1. Objectives, scope, non-goals

### 1.1 Objectives

- Give agents an operational interface to the shared database that supports progressive exploration: a table-name index, domain maps, relation summaries, complete relation references, function/RPC references, and executable examples, each sized to be loaded independently.
- Let agents express reads (named queries, entity navigation, temporal replay, retrieval search) as reproducible intents that return a digested **input snapshot** carrying the knowledge head they observed.
- Let agents author **ingestion intents** backed by sealed verification runs, and have a deterministic executor validate, compare against current state, apply through the temporal helpers as `executor_service`, and return a receipt.
- Store intents, snapshots, plans, receipts, and reports immutably with lineage in the existing artifact system.
- Expose the same capabilities on CLI, HTTP, MCP, and skills, and prove the design in the eve proving ground against two alternatives.

### 1.2 In scope

Schema workspace generation and scoped materialization; the `schema-explore`, `knowledge-db`, `knowledge-ingest` skills; read and ingestion intent contracts; the knowledge executor extension; artifact storage for this feature; MCP tools for the same operations; the eve three-way experiment design; contract additions (`artifact_type`, `intent_type`, one named-query helper).

### 1.3 Non-goals (explicitly deferred or owned elsewhere)

- Mission Control admission, grants, budgets, `mission_control.*` spine, and the `ingestion_executor` **identity** as an MC executor kind. This spec defines the KS capability and its HTTP/CLI/MCP contract; MC decides who may call it (§7.6).
- Capability search / `CapabilityDescriptor@1` / `MaterializationPlan@1` builder (handoff §5.4). This spec produces a **capability bundle** shaped so that a future plan builder can consume it, nothing more.
- Moving the verification executor's store to buckets in general. Only the pieces needed to materialize evidence from a sealed run into `evidence.*` are specified (§6.5).
- Retrieval ↔ verification synthesis, admitted-only indexing (handoff §5.5). Retrieval search is exposed as a read variant; publication rules are unchanged.
- Bucket taxonomy migration of source-named transcript buckets.
- Raw SQL for agents on any surface. Long-tail reads are handled by adding named queries (§5.5), not by an SQL escape hatch.

---

## 2. Current-state findings

Each finding cites the file that establishes it. "Exists", "extend", and "new" are the three labels used throughout.

### 2.1 Database contract (exists)

| Fact | Source |
|---|---|
| 18 application schemas; `api` has 8 views (function-backed invoker views) and RPCs `resolve_entity`, `entity_at`, `relationships`, `entity_timeline`, `what_changed`, `entity_card`, `leaderboard`, `evidence_packet`, `summary_evidence`, `hybrid_knowledge_search_1536` | `docs/knowledge-model/SCHEMA-SUMMARY.md`; `supabase/migrations/20260912011000_km_10_api.sql` |
| Identity: `corpus.entity (kind → taxonomy.entity_kind.canonical_schema/canonical_table)` + 36 typed child tables keyed `(tenant_id,id,kind)`; `entity_alias (alias_kind)`, `entity_identifier (scheme,value)`, `entity_merge` | `20260912010200_km_02_corpus_identity.sql`; `20260912010100_km_01_vocabularies.sql` |
| Relationships: one `corpus.relationship` table with `kind → taxonomy.relationship_kind (from_kinds,to_kinds,temporal,property_schema)`; endpoint kinds enforced by trigger; temporal kinds get a `relationship_active` stream | `20260912010300_km_03_relationship.sql` |
| Two clocks: world time (`valid_during`/`occurred_during` tstzrange) and knowledge sequence (`k_from`/`k_to` bigint) stamped by trigger from an open batch; `temporal.knowledge_head` per tenant; `knowledge_batch` requires `receipt_id → orchestration.operation_receipt`; `begin_batch(p_expected_head)` raises `rebase_required` (40001) on head mismatch; `assert_state` returns the existing segment when an identical current segment exists (native no-op), splits overlapping intervals and closes replaced segments; `commit_batch` validates stream slot rules and payload JSON Schema (`pg_jsonschema`) | `20260912010400_km_04_temporal.sql` |
| Write authority: `insert/update/delete` on all of `temporal.*`, `corpus.relationship`, `evidence.segment_support` is revoked from **every** role including `service_role`; `execute` on `temporal.*` functions granted only to `executor_service`; `executor_service` alone has DML on `corpus.*`, `knowledge.*`, `ranking.*`; `pipeline_agent`/`executor_service` may insert into `evidence.source_query…claim_record`, `staging.*`, `content.document_*`; nine evidence/content tables are insert-only (`km_immutable`); `app_reader`/`authenticated` read only `api` views and RPCs | `20260912011100_km_11_grants_rls.sql` |
| Roles are NOLOGIN, granted to `service_role`; services `SET ROLE` after connecting; `util.current_tenant_id()` reads `app.tenant_id` and fails closed | `20260826000100_foundation.sql` §6; `20260903010200_knowledge_runtime_security.sql` L192 |
| Intent/receipt ledger: `orchestration.operation_intent (intent_type, schema_version, payload, preconditions, idempotency_key unique, proposed_by_attempt, mission_id, approval_state)`, `operation_receipt (intent_id unique, executor_version, precondition_results, outcome in applied\|rejected\|noop\|partial, changes_summary, affected_refs)` immutable; seeded `intent_type` codes include `upsert_entity`, `link_entities`, `record_claim`, `publish_report`, `ingest_research_bundle`; `artifact_type` includes `ingestion_intent` | `20260826000200_orchestration.sql` L370–405, L440; `20260829012402_cloud_agent_research_operations.sql` L72–82 |
| Artifacts: `orchestration.artifact (artifact_type, sha256, bucket_class enum source_captures\|candidate\|accepted\|ledger\|published, storage_bucket, object_path unique, producer_attempt_id, mission_id)` append-only; `artifact_lineage (relation_kind derived_from\|supersedes\|corrects\|produced_by\|consumed_by, receipt_id)` | `20260826000200_orchestration.sql` L204; `20260903010000_knowledge_content_contract.sql` L20 |
| Buckets: `source-captures`, `content-derivatives`, `research-ingestion-intents` (no anon/authenticated policies), `ai-engineer-cloud-bucket`, `ai-engineer-project-provenance`, two transcript buckets | grep `storage.buckets` in migrations |
| `evidence.claim (claim_type, statement, structured, status, created_by_receipt_id)`, `evidence.source`, `source_capture (artifact_id, content_sha256, capture_method)`, `locator (capture_id, selector jsonb, selector_kind, selected_content_sha256)`, `claim_subject (role subject\|object\|context)`, `segment_support (segment_id\|event_occurrence_id, claim_id, locator_id, role)` (k-stamped, admitted through `temporal.admit_support`) | `20260826000300_evidence_core.sql`; `20260912010500_km_05_evidence.sql` |
| `staging.candidate (proposed_kind, proposed_payload, resolved_entity_id, source_id)`, `identity_match`, `resolution_decision (create\|match\|reject\|defer, receipt_id)`, `vetting_decision (admit\|reject\|defer, receipt_id)` | `20260912010900_km_09_ranking_staging.sql` |
| `knowledge_service.operation (operation_kind, idempotency_key, ownership_mode standalone\|mission_control\|eve, attempt_id, request_sha256, status)`, `operation_step`, `outbox` | `20260903010200_knowledge_runtime_security.sql` L5–49 |
| Generated types: `src/database.generated.ts` (21,679 lines) includes `temporal`; scripts `generate-types.mjs` (supabase CLI) and `generate-types-native.mjs` (`@supabase/postgres-meta`); `types:check` | `package.json`; `scripts/` |
| Local disposable DB: `scripts/reset-disposable-local.mjs`; PG 17; `api` exposed schemas `public, graphql_public, api` | `supabase/config.toml` |

### 2.2 Existing schema workspace generator (extend, then supersede)

`ai-engineer-industry-cloud-automated-research/scripts/build-schema-workspace.mjs` (443 lines) introspects live Postgres for a hardcoded allowlist of 9 schemas and emits `ai-engineer-schema-workspace/2`: `index.md`, `manifest.json`, `search-index.json`, per-schema `README.md`/`enums.md`/`functions.md`/`schema.json`, and one Markdown file per relation (columns, constraints, in/outbound FKs, indexes, triggers, RLS policies, `Database[...]["Row"]` path, search tokens). Output: 280 files, 239 relations, median relation page 3.6 KB, largest 23.5 KB (`orchestration.operation_receipt`). It is deterministic (sorted keys, ordered SQL, no timestamps in generated files) and has a `--check` that regenerates and compares a tree digest.

What it lacks for this spec (verified by reading the script and output): no intermediate representation (Markdown and JSON are rendered independently from query rows); no `temporal`, `content`, `knowledge`, `retrieval`, `knowledge_service`, `observability`, `provenance`, `evaluation`, `curriculum`, `util`; no grants/ACLs, sequences, partitions, extensions; no domain layer; no aliases, terminology, task entry points, or examples; functions get a one-row table, not a page; views point at `tables/`; FK target qualification is inconsistent (556 qualified vs 54 unqualified `related_relations`); `--check` mutates the tree; no scope mechanism; no validation of TS paths against `database.generated.ts`; only 22/239 relations have a description because most tables have no Postgres comment. Its skill (`.agents/skills/ai-engineer-cloud-research/references/schema-routing.md`) teaches the drill-down policy that this spec formalizes.

**Decision:** the new generator reuses the eight catalog queries and the rendering conventions of this script as its starting point, but is a new program in db-contract. The old workspace is retired once the new one is committed (the cloud-research repo pins the db-contract copy).

### 2.3 Knowledge Services (exists / extend / new)

| Area | Status | Evidence |
|---|---|---|
| Intent → deterministic executor → receipts, exit lattice 0/1/2, remote mode with credentials outside the sandbox, content-addressed store, `bytes + lineage` artifact identity, skill co-located with executor, `pack-sandbox.mjs` tarball with `TARBALL.sha256` | **exists** | `apps/verification-executor/src/{intents,store,capture,remote,index,mcp,http}.ts`, `skills/knowledge-verify/SKILL.md`, `scripts/pack-sandbox.mjs` |
| Intent families `verification-claims-intent.v1`, `-extraction-intent.v1`, `-report-intent.v1` with `intentId`, `policyVersion`, `producer{deploymentId,attemptId,capabilityVersion}` | **exists** (pattern to mirror) | `apps/verification-executor/src/intents.ts` L41–85 |
| Operation identity (`tenantId, operationId, attemptId, missionId, correlationId, actor, capabilityVersion, idempotencyKey, contractVersion`) | **exists** | `packages/contracts/src/identity.ts` L29–44 |
| `SupabaseArtifactStore` (`put/get`, path `{tenant}/{digest[7:9]}/{digest[7:]}`, `x-upsert:false`, collision verification); `orchestration.artifact` + `verification_artifact_metadata` + `artifact_lineage` writes | **exists** | `packages/runtime/src/artifacts.ts` L81–121; `packages/persistence/src/verification.ts` L198–218 |
| Postgres access: `pg.Pool`, `set_config('app.tenant_id',…,true)` per transaction; no `SET ROLE`; contract pinned as vendored `0.2.38` tgz | **extend** (pin 0.3.0 by git ref; add role switching) | `packages/persistence/src/postgres.ts` L116–147; `packages/persistence/package.json` L18 |
| Code touching `corpus.*`, `temporal.*`, `staging.*`, `api.*`, `knowledge_head`, `begin_batch` | **none** (greenfield) | repository grep |
| Platform MCP: `McpServer` + Streamable HTTP on `/mcp` (port 4101), manual `registerTool`, 37-entry catalog → `OperationKind`, `FORBIDDEN_MCP_CAPABILITIES` includes `raw_sql`, `storage.list`, `capability.admit`; verification tools proxied to the API via `KnowledgeClient` | **exists** (extend by re-export in phase 7) | `apps/mcp/src/index.ts`, `apps/mcp/src/catalog.ts` L2–66 |
| Executor MCP: same SDK, Streamable HTTP + stdio, `verify_*` step tools, optional bearer | **exists** (extend with new tool families) | `apps/verification-executor/src/mcp.ts` |
| Worker admitted operation kinds; adding a kind = `OperationKindSchema` → steps → handler → registry | **exists** (used in phase 7 for platform-durable execution) | `packages/application/src/surface.ts` L27–68; `apps/worker/src/activity-registry.ts` |
| Skills manifest (6 skills) and `catalog/capability-profiles.v1.json` | **exists** (new skills join) | `skills/manifest.json`; `catalog/` |
| Schema workspace, DB read surface, read intent, ingestion intent, ingestion executor, intent storage in buckets | **new** | — |

### 2.4 Eve proving ground (exists / extend)

| Fact | Source |
|---|---|
| One agent; deployment layer (connections, sandbox template, env, `RESEARCH_SURFACE=mcp\|cli`) vs session layer (`defineDynamic` skills/instructions/tools keyed on `x-capability-profile` → auth attribute) | `agents/verified-research/agent/{channels/eve.ts, lib/profiles.ts, skills/capabilities.ts, instructions/surface.ts}` |
| Profiles today: `mcp-verified-research`, `cli-verified-research`, `cli-verified-research-minimal` | `lib/profiles.ts` L37–62 |
| Sandbox bootstrap installs `knowledge-verify` (tarball), `firecrawl-cli`, `tavily-cli`; `revalidationKey = verified-research-workspace-v2:${surface}:${tarballSha16}`; env baked: `VERIFY_EXECUTOR_URL`, `FIRECRAWL_API_KEY`, `TAVILY_API_KEY` | `sandbox/sandbox.ts` L63 and bootstrap |
| Connections (`verification`, `tavily`, `firecrawl`) with `tools.allow` narrowed by surface | `connections/*.ts` |
| Model `openai/gpt-5.6-terra`, reasoning `high`, via env; eve `0.44.4` | `agent/agent.ts`; `pnpm-workspace.yaml` L7 |
| Runner: spawns executor + `eve dev`, creates a session with header, streams `events.jsonl` + `transcript.md`, collects `steps/`, `store/`, `workspace-run/`; `step.completed` events already carry `usage.{costUsd,inputTokens,outputTokens}` but nothing aggregates them; one run per invocation; no DB snapshotting; MCP vs CLI connection sets cannot flip within one process | `tools/experiment-runner/run.mjs`; README L116–124 |
| No database access from the sandbox today (no `psql`, `supabase`, or DB URLs) | grep of agent and sandbox |
| Observed behaviors to design around: duplicate parallel identical tool calls (2–4×), report-intent drift | `experiments/exp2-cli-surface/README.md` obs 6–7 |

### 2.5 Handoff items that are obsolete or corrected here

- "239 relations / 9 schemas" describes the old workspace, not the database. The current model has 18 application schemas and a different corpus (36 typed entity tables, one `relationship` table, `temporal.*`).
- The handoff's per-proposal outcomes `no_op_duplicate | superseded | rebase_required | applied` mix three vocabularies. This spec uses: **proposal** outcomes `admitted | no_op_duplicate | superseded | review_required | held | quarantined` (blueprint), **receipt** outcomes `applied | rejected | noop | partial` (`operation_receipt` check constraint), and `rebase_required` as a **transaction failure** surfaced from `temporal.begin_batch`.
- The handoff assumed `staging → evidence → corpus` as the ingestion path. In the current model canonical facts are **temporal segments/events/relationships** admitted through helpers; `staging.candidate` is the identity-resolution zone for *new* entities, not a staging copy of facts. The intent proposals in §6 reflect that.
- The handoff proposed `pipeline_agent`/`app_reader` for a read API "option (ii) PostgREST through `api.*`". `app_reader` cannot see `staging.*`, `evidence.*` or `knowledge_service.*` (grants in `km_11`); the read executor therefore uses `pipeline_agent` for bounded-schema named queries and `app_reader` semantics only for `api.*` (§5.5).
- `ingestion_executor` and `materialize_capabilities` are **not** M0–M8 executor kinds (`workflow-types/05-EXECUTORS_AND_DURABLE_CONTROLS.md` L131–142; Architecture §16 defers materialization). This spec ships the capability in KS and stages the MC binding (§7.6).

---

## 3. Recommended architecture and ownership

```
ai-engineer-db-contract                          ai-engineer-knowledge-services
┌──────────────────────────────────────┐          ┌───────────────────────────────────────────────┐
│ supabase/migrations  (source of DDL) │          │ packages/schema-workspace  (load, search, scope)│
│ src/database.generated.ts            │  pinned  │ packages/db-read           (named queries, snap)│
│ scripts/schema-workspace/            │ ───────▶ │ packages/ingestion         (validate, plan,     │
│   introspect → schema-ir.v1.json     │          │                              apply, receipt)     │
│   enrich   ← workspace-enrichment/   │          │ apps/verification-executor → knowledge executor │
│   render   → workspace/ (L0–L3)      │          │   CLIs: knowledge-verify, knowledge-db,          │
│   validate, fingerprint, check       │          │         knowledge-ingest   (remote mode)         │
│   materialize --scope → bundle       │          │   HTTP: /schema, /db, /ingest, /artifacts        │
│ workspace/  (committed)              │          │   MCP:  verify_*, schema_*, db_*, ingest_*        │
│ workspace-scopes/*.json              │          │   skills/: knowledge-verify, schema-explore,     │
│ migration: artifact_type/intent_type │          │            knowledge-db, knowledge-ingest        │
└──────────────────────────────────────┘          │ apps/mcp (platform) re-exports (phase 7)         │
                                                  │ packages/persistence: pin 0.3.0, SET ROLE        │
research_ingestion_systems_agent                  └───────────────────────────────────────────────┘
┌──────────────────────────────────────┐
│ profiles: schema-workspace-research  │  arm A     Postgres (isolated experiment stack)
│           supabase-cli-baseline      │  arm B     roles: pipeline_agent (reads),
│           mcp-db-research            │  arm C            executor_service (ingestion apply)
│ sandbox: + supabase CLI (B), + tarball│
│ runner: metrics.json, db deltas      │
└──────────────────────────────────────┘
```

### 3.1 Ownership table

| Component | Owner | Location | Why |
|---|---|---|---|
| Introspection, IR, enrichment files, workspace rendering, validation, fingerprint, scoped materialization CLI | db-contract | `scripts/schema-workspace/`, `workspace/`, `workspace-enrichment/`, `workspace-scopes/` | The workspace is a projection of the contract; it must change in the same commit as a migration and be `types:check`-style verifiable in CI |
| New `artifact_type`/`intent_type` codes; optional helper `api.knowledge_head()` | db-contract | `supabase/migrations/` | Shared schema goes in the contract only (`db-contract.mdc`) |
| Scope definitions that mirror capability profiles | KS (authoring) → committed in db-contract `workspace-scopes/` | `workspace-scopes/<scope>.json` | Scopes reference relations that only db-contract can validate; KS proposes, db-contract validates on build |
| Workspace loader, search, scope filter (runtime) | KS | `packages/schema-workspace` | Used by executor CLI/HTTP/MCP `schema_*` and later by platform MCP |
| Named-query catalog execution, snapshots | KS | `packages/db-read` | Needs `pg`, `SET ROLE`, tenant context, digesting |
| Ingestion validation/plan/apply/receipt | KS | `packages/ingestion` | Needs persistence, temporal helpers, artifact store |
| Executor host (CLI + HTTP + MCP), skills, tarball | KS | `apps/verification-executor` (renamed `apps/knowledge-executor` in phase 3; bin names unchanged) | One sandbox trust boundary, one pack |
| Platform re-export | KS | `apps/mcp`, `apps/api` | Later, for MC and non-sandbox consumers |
| Eve profiles, sandbox bootstrap, runner metrics, experiment fixtures | proving ground | `research_ingestion_systems_agent/` | Existing harness |
| Admission of `knowledge-db`/`knowledge-ingest` into profiles, the `ingestion_executor` identity, budgets | Mission Control | `ai-engineer-mission-control` (staged) | Architecture invariants 9–10 |

### 3.2 Deployment layer vs session layer (preserved)

Deployment: executor binaries in the sandbox template (tarball), the Supabase CLI for arm B, the executor URL/token, DB URL for arm B only, MCP connection set. Session: which skills, which instruction procedure, which tool allowlist, which **scoped workspace bundle** is written into the sandbox. The workspace bundle is text, therefore session-layer: it is written by a session-start step (eve `defineDynamic` skill files, Cursor Cloud repo ref, or a file tree) from the KS-pinned db-contract copy, never fetched from the live database.

---

## 4. Schema workspace algorithm

### 4.1 Authoritative inputs and precedence

| # | Input | Contributes | Precedence rule |
|---|---|---|---|
| 1 | Live catalog introspection of a database at a known migration head (`pg_class`, `pg_attribute`, `pg_constraint`, `pg_index`, `pg_policy`, `pg_trigger`, `pg_proc`, `pg_type`, `pg_enum`, `information_schema.role_table_grants`, `pg_inherits`, `pg_depend` for view→relation edges) | Structure: relations, columns, types, defaults, generated columns, constraints, FKs, indexes, triggers, RLS, function signatures/volatility/security, grants, partitions, view definitions | **Wins for every structural fact.** Nothing else may assert a column, constraint, or grant |
| 2 | `supabase_migrations.schema_migrations` head + `package.json` version | Identity of the build (`migration_head`, `contract_version`) | Build fails if the head is not the repo's latest migration file name |
| 3 | `src/database.generated.ts` | TS path hints (`Database["schema"]["Tables"\|"Views"\|"Functions"][name]`) | Rendered only if the path resolves in the file; mismatch is a validation error, not a silent omission |
| 4 | Postgres comments (`obj_description`, `col_description`) | Descriptions | Used verbatim when present; enrichment may **append**, never replace |
| 5 | Reference-data snapshots of allowlisted vocabulary tables (`taxonomy.entity_kind`, `taxonomy.relationship_kind`, `temporal.stream_kind`, `temporal.event_kind`, `content.document_type`, `orchestration.intent_type`, `orchestration.artifact_type`, `evidence.capture_method`, `evidence.search_provider`, `corpus.media_platform`, `corpus.license`, `corpus.distribution_kind`) | Vocabulary pages, "which kinds may relate to which", stream slot rules | Data, not DDL; captured with row digests so drift in vocabularies is detected like DDL drift |
| 6 | Curated enrichment (`workspace-enrichment/*.yaml`) | Domains, aliases, terminology, task entry points, semantic relationships, examples, "how to read this" notes | Lowest precedence; must validate against 1–5; rendered with a visible `curated` marker and provenance |

Migrations themselves are **not parsed** (SQL parsing is fragile and the live catalog is the truth of what applied); they are used only for the head check and as human-readable references linked from relation pages (`defined_in: [20260912010200_km_02_corpus_identity.sql]`, derived by grepping `create table <qualified>` across migration files, best-effort, marked as such).

### 4.2 Canonical intermediate representation: `schema-ir.v1`

One JSON document, canonicalized (sorted keys, stable array order, LF), committed as `workspace/schema-ir.json`. Stable identifiers are strings, not hashes, so pages can link across builds:

- relation `rel:<schema>.<name>`; column `col:<schema>.<name>.<column>`; function `fn:<schema>.<name>(<argtypes>)`; enum `enum:<schema>.<name>`; policy `pol:<schema>.<name>.<policy>`; index `idx:<schema>.<index>`; trigger `trg:<schema>.<name>.<trigger>`; domain `dom:<slug>`; task `task:<slug>`; query `q:<slug>`; vocabulary row `voc:<schema>.<table>.<code>`.

```jsonc
{
  "format": "ai-engineer-schema-ir/1",
  "build": {
    "contract_version": "0.3.0",
    "migration_head": "20260912011200",
    "generated_types_sha256": "…",
    "enrichment_sha256": "…",
    "source": { "kind": "local_disposable" | "project", "project_ref": "wkythqbofmckbuoothhn"? }
    // introspected_at is written to manifest.json only; it is not part of the fingerprint
  },
  "fingerprint": "sha256:<over canonical(schemas,relations,functions,types,vocabularies,derived) — excludes enrichment>",
  "workspace_fingerprint": "sha256:<over fingerprint + enrichment_sha256 + renderer_version>",
  "schemas": { "corpus": { "id": "sch:corpus", "comment": null, "relation_ids": [...], "function_ids": [...], "enum_ids": [...], "domain_ids": ["dom:identity"] } },
  "relations": {
    "rel:corpus.entity": {
      "schema": "corpus", "name": "entity", "kind": "table" | "partitioned_table" | "view" | "materialized_view" | "foreign_table",
      "comment": null,
      "columns": [ { "id": "col:corpus.entity.kind", "position": 3, "name": "kind", "type": "text", "nullable": false,
                     "default": null, "generated": null, "identity": null, "comment": null,
                     "fk": { "to": "rel:taxonomy.entity_kind", "columns": ["code"], "constraint": "entity_kind_fkey" } } ],
      "primary_key": ["id"], "unique": [["tenant_id","id"],["tenant_id","id","kind"],["tenant_id","kind","slug"]],
      "checks": [ { "name": "entity_lifecycle_check", "expression": "lifecycle = ANY (ARRAY['active','merged','retired'])" } ],
      "foreign_keys": [ { "name": "...", "columns": ["created_by_receipt_id"], "to": "rel:orchestration.operation_receipt", "to_columns": ["id"], "deferrable": false } ],
      "inbound_foreign_keys": [ { "from": "rel:corpus.entity_alias", "columns": ["entity_id"] }, "…" ],
      "indexes": [ { "id": "idx:corpus.entity_name_trgm", "definition": "CREATE INDEX … gin_trgm_ops" } ],
      "triggers": [ { "id": "trg:corpus.entity.entity_receipt_tenant", "function": "fn:corpus.check_receipt_tenant()", "definition": "…" } ],
      "rls": { "enabled": true, "forced": false,
               "policies": [ { "id": "pol:corpus.entity.km_tenant_access", "command": "ALL", "roles": ["executor_service","pipeline_agent","verifier_agent","control_plane"], "using": "tenant_id = util.current_tenant_id()", "with_check": "…" } ] },
      "grants": { "executor_service": ["SELECT","INSERT","UPDATE"], "pipeline_agent": ["SELECT"], "verifier_agent": ["SELECT"], "control_plane": ["SELECT"], "app_reader": [], "authenticated": [], "anon": [] },
      "partitions": null, "view_definition": null,
      "typescript": { "row": "Database[\"corpus\"][\"Tables\"][\"entity\"][\"Row\"]", "insert": "…[\"Insert\"]", "update": "…[\"Update\"]" },
      "defined_in": ["20260912010200_km_02_corpus_identity.sql"]
    }
  },
  "functions": { "fn:temporal.assert_state(uuid,text,tstzrange,text,text,numeric,text,text,uuid,jsonb,uuid,uuid,text,uuid,text,uuid)": {
      "schema": "temporal", "name": "assert_state", "arguments": [ { "name": "p_entity", "type": "uuid", "default": null }, "…" ],
      "returns": "uuid", "volatility": "volatile", "security": "definer", "language": "plpgsql",
      "grants": { "executor_service": ["EXECUTE"] }, "comment": null, "body_sha256": "…",
      "raises": ["no open knowledge batch","stream does not admit entity kind","overlapping assertions in one batch; consolidate before admission"]  // literal `raise exception` strings, mechanically extracted
  } },
  "types": { "enum:evidence.claim_status": { "labels": ["proposed","verified","disputed","retracted","superseded"] }, "enum:orchestration.bucket_class": {...} },
  "vocabularies": { "voc:taxonomy.relationship_kind": { "key": "code", "rows": [ { "code": "employed_by", "from_kinds": ["person"], "to_kinds": ["organization"], "temporal": true, "…": "…" } ], "rows_sha256": "…" } },
  "roles": { "executor_service": { "login": false, "member_of": [], "granted_to": ["service_role"], "purpose_comment": "sole DML on corpus, knowledge, canonical evidence, receipts" } },
  "derived": {
    "write_paths": { "rel:temporal.segment": { "direct_dml_roles": [], "via_functions": ["fn:temporal.assert_state(...)", "fn:temporal.close_segment(uuid)"], "note": "history is closed only by helper; DELETE raises 23001" } },
    "polymorphic": [ { "id": "poly:corpus.entity.kind", "discriminator": "col:corpus.entity.kind", "vocabulary": "voc:taxonomy.entity_kind", "targets_by_value": { "organization": "rel:corpus.organization", "…": "…" }, "basis": "taxonomy.entity_kind.canonical_schema/canonical_table + FK (tenant_id,id,kind)" },
                     { "id": "poly:temporal.stream.subject", "discriminator": "num_nonnulls(subject_entity_id, subject_relationship_id)=1", "targets": ["rel:corpus.entity","rel:corpus.relationship"], "basis": "check constraint" } ],
    "join_paths": { "corpus.entity→temporal.segment": ["corpus.entity.id = temporal.stream.subject_entity_id", "temporal.stream.id = temporal.segment.stream_id"] },
    "view_sources": { "rel:api.current_facts": ["fn:api.current_fact_rows()", "rel:temporal.segment", "rel:temporal.stream"] },
    "function_touches": { "fn:temporal.assert_state(...)": { "reads": ["rel:temporal.stream_kind","rel:corpus.entity","rel:corpus.relationship"], "writes": ["rel:temporal.stream","rel:temporal.segment"] } }  // from pg_depend + body regex; marked best_effort
  },
  "enrichment": { "domains": [...], "relation_overlays": {...}, "aliases": [...], "terminology": [...], "tasks": [...], "examples": [...], "semantic_relationships": [...] }
}
```

Everything under `schemas`, `relations`, `functions`, `types`, `vocabularies`, `roles` is **derived**. `derived.*` is mechanical but marked `best_effort` where it relies on body parsing. `enrichment` is curated. Renderers never invent facts that are not in the IR.

### 4.3 Progressive disclosure layers

| Layer | Files | Size target | Purpose |
|---|---|---|---|
| **L0 index** | `INDEX.md` (~3 KB), `relations.txt` (one qualified name per line, grouped by schema; ~8 KB for ~330 relations), `START_HERE.md` (~2 KB: the five-step navigation rule and the three entry files) | ≤ 4 KB each except `relations.txt` | Answer "what tables exist" and "where do I start" without loading anything else |
| **L1 domains** | `domains/<slug>.md` (identity, relationships, temporal-facts, evidence, content, knowledge-records, retrieval, ranking, staging, orchestration-ledger, knowledge-service-runtime, research, evaluation, curriculum, observability, provenance, api-surface, research-starter-protected) | ≤ 8 KB | Purpose, the 5–15 relations that matter, key RPCs, read paths, write paths (who may write, through what), invariants, task entry points, links down |
| **L2 relation summaries** | `schemas/<schema>/README.md`: table of relations with kind, row-count-class (none, from stats, `unknown`), one-line description, key FKs | ≤ 12 KB | Choose the relation |
| **L3 references** | `relations/<schema>/<name>.md` (columns, constraints, FKs both ways, indexes, triggers, RLS, grants, write path, TS paths, examples); big relations spill indexes/policies into `relations/<schema>/<name>.details.md`; `functions/<schema>/<name>.md`; `types/<schema>.md`; `vocabularies/<table>.md` | main page ≤ 6 KB, details ≤ 16 KB | Compose a correct operation |
| **Task layer** | `tasks/<slug>.md` (question → navigation → named query or intent skeleton → expected shape → pitfalls) | ≤ 5 KB | Translate a natural-language question into a valid operation |
| **Search** | `search/index.json` (one entry per relation/function/domain/task/term with `id, kind, qualified_name, path, aliases[], tokens[], summary, domain`), `search/aliases.json` (alias → ids), `search/terminology.json` | index ≤ 250 KB; agents query it with `jq`/`rg`, never read it whole | Find without browsing |
| **Machine** | `manifest.json`, `schema-ir.json`, `fingerprint.json`, `queries/catalog.json` (named-query catalog, §5.5), `scope.json` (in scoped builds) | — | Tooling, freshness checks, executor coupling |

Navigation depth from `START_HERE.md` to a valid operation is designed to be **≤ 4 file reads** for the common tasks (start → domain → relation or task → catalog entry). Samples for every layer are in [`WORKSPACE_LAYOUT_AND_SAMPLES.md`](schema-workspace/WORKSPACE_LAYOUT_AND_SAMPLES.md).

### 4.4 Frontmatter and searchability

Every Markdown page starts with YAML frontmatter rendered from the IR:

```yaml
---
id: rel:corpus.entity
kind: table                      # table | view | function | domain | task | vocabulary | types
schema: corpus
name: entity
domain: identity
aliases: [entity, entities, canonical entity, identity row]        # curated
tokens: [corpus, entity, kind, display_name, slug, lifecycle, merged_into_id, projection_knowledge_seq, created_by_receipt_id]  # derived
summary: "One row per canonical identity; typed attributes live in corpus.<kind>."  # comment or curated (marked)
rls: enabled
writers: [executor_service]      # roles with INSERT/UPDATE (derived)
readers: [executor_service, pipeline_agent, verifier_agent, control_plane]
workspace_fingerprint: sha256:…
---
```

`tokens` are derived (schema, name, qualified name, column names, enum labels, function names); `aliases` and `summary` may be curated. `search/index.json` mirrors the frontmatter so `jq 'select(.aliases|index("org"))'` and `rg -l "^aliases:.*pricing"` both work.

### 4.5 Navigation edges

Rendered as link lists on every page, all derived from the IR:

- **FK out/in** with qualified target links and the column mapping; deferrable/on-delete shown.
- **Polymorphic references**: `corpus.entity.kind` → typed table (via `taxonomy.entity_kind.canonical_table`, plus the composite FK `(tenant_id,id,kind)`); `temporal.stream` subject (entity | relationship); `evidence.segment_support` target (segment | event_occurrence); `taxonomy.assignment` target; `retrieval.packet_member` typed record columns. Each is rendered with its **basis** (constraint, vocabulary table, or `curated`) so the agent knows whether the database enforces it.
- **Views → sources** and **functions → touched relations** (best-effort, marked).
- **Vocabulary-constrained edges**: `relationship_kind.from_kinds/to_kinds`, `stream_kind.subject_kinds/status_values/unit_values`, `event_kind.subject_kinds/object_kinds` rendered as matrices on the vocabulary pages and as "allowed" lists on the relation pages.
- **Domain relationships** (curated): e.g. "a `staging.candidate` becomes a `corpus.entity` through a `resolution_decision` with `decision='create'`, which requires an `operation_receipt`". Rendered under a `> curated` block with provenance.

### 4.6 What each relation page must represent

Columns (position, name, type, nullability, default, generated expression, identity, comment, FK), primary key, unique constraints, check constraints (expression), exclusion constraints, foreign keys both directions, indexes (definition, partial predicate), triggers (function, timing, events, definition), RLS (enabled/forced, policies with roles, command, `using`, `with_check`), grants per bounded role and per Supabase role, partitions (parent/children, strategy), view definition (for views), TS paths for `Row`/`Insert`/`Update` (tables) or `Row` (views), **supported read paths** (which `api.*` view/RPC or named query exposes this relation to `app_reader`; whether `pipeline_agent` can `SELECT` directly), **supported write paths** (direct DML roles; helper functions; "no write path for agents" when applicable), and `defined_in` migrations.

### 4.7 Guidance for the current model (curated, validated)

The `domains/` pages carry this guidance. It is curated content with `provenance: human`, validated so every referenced object exists:

- **Identities**: `corpus.entity` is the identity; `kind` picks the typed table; aliases are typed (`alias_kind`), identifiers are schemed; merges are rows (`entity_merge`) and the loser gets `lifecycle='merged'`, `merged_into_id`. Resolve names with `api.resolve_entity(text)` before creating anything.
- **Two-clock facts**: a fact is a `temporal.segment` on a `stream (kind, subject, scope_key)` with a world interval `valid_during` and knowledge interval `[k_from, k_to)`. Current = `k_to is null`. "As the world was at T, as we knew at K" = `api.entity_at(id, T, K)`. Assertions go through `temporal.assert_state`; identical current segment → returns existing id (no-op); overlap → old segment closed and split. Stream slot rules (`status_values`, `requires_amount`, `unit_values`, `payload_schema`) are enforced at `commit_batch`.
- **Relationships**: `corpus.relationship` rows are k-stamped and current when `k_to is null`; temporal kinds additionally need an active `relationship_active` segment; endpoint kinds are enforced by trigger from `relationship_kind`; properties validated against `property_schema`.
- **Events**: `temporal.event` identity + `event_occurrence` (mode, belief, k-stamped); asserting a different occurrence closes the previous one.
- **Source and evidence lineage**: `evidence.source` → `source_capture (artifact_id, content_sha256)` → `locator (selector, selected_content_sha256)` → `claim` ← `claim_subject`; facts are tied to claims via `primary_claim_id` and to quotes via `segment_support (segment|occurrence, claim, locator)`. Discovery leads are `source_query` → `provider_result` → `source_encounter`.
- **Knowledge records**: `knowledge.record` + nine typed engineering records + `record_entity_link`; created only by `executor_service` with a receipt.
- **Ranking**: `ranking.metric_observation (subject_entity_id, metric_definition_version_id, value, observed_at, claim_id)`.
- **Vector retrieval**: spaces, `vector_item` partitions, `api.hybrid_knowledge_search_1536` with entity/document/content/time/assurance/publication filters; publication is governed; agents read only published versions.
- **Receipts everywhere**: `corpus.entity.created_by_receipt_id`, `knowledge_batch.receipt_id`, `staging.*_decision.receipt_id`, `evidence.claim.created_by_receipt_id`. An agent never creates a receipt; the executor does.

### 4.8 Database-enforced vs curated

Every fact on a page is in exactly one of two visual classes: plain text/tables (derived from the catalog: constraint, trigger, grant, FK, vocabulary row) or a `> curated (provenance: human|model_assisted, reviewed: <date>)` block. The search index carries `basis: enforced | vocabulary | curated` on relationship edges. Agents are instructed (skill) to treat only `enforced`/`vocabulary` as guarantees.

### 4.9 Examples that translate questions into operations

Each `tasks/<slug>.md` contains: the question family, the navigation (which pages), the operation (`knowledge-db query <named> --params` or an intent skeleton), the expected shape (from the named-query catalog), pitfalls (e.g. "`api.current_facts` filters `valid_during @> now()`; for historical values use `entity_at`"). Examples are **executable**: the validator runs each example's named query against the disposable database at build time (empty result sets are fine; errors fail the build) and every intent skeleton is validated against the JSON schema.

### 4.10 Determinism, identifiers, versioning, fingerprints, drift

- Canonical JSON (sorted keys), stable ordering (schema name, relation name, column position, constraint name, policy name), LF endings, no timestamps in fingerprinted content. `introspected_at` lives only in `manifest.json` under `build.volatile`.
- `fingerprint` (structure + vocabularies) and `workspace_fingerprint` (structure + enrichment + renderer version) are both in `fingerprint.json` and in every page's frontmatter. Renderer version is a semver in the generator (`ai-engineer-schema-workspace/3`).
- **Freshness contract**: the workspace records `migration_head`; the executor records the head of the database it is connected to (`select version from supabase_migrations.schema_migrations order by version desc limit 1`) and refuses (`WORKSPACE_STALE`, exit 2) when heads differ, unless `--allow-stale` is set (experiments only, recorded in receipts).
- **Drift detection without mutation**: `schema-workspace check` introspects into a temp IR and compares `fingerprint` with the committed one, printing a structured diff (added/removed/changed relations, columns, policies, grants, vocabulary rows). CI runs it against the disposable DB after `db:reset`. `--check` never writes into `workspace/`.
- **Regeneration**: `schema-workspace build` rewrites `workspace/` atomically (temp dir + rename). A migration PR must include the regenerated workspace or CI fails (same rule as `types:check`).

### 4.11 Full workspace vs scoped materialization

Scope file `workspace-scopes/<id>.json` (`schema-scope.v1`):

```json
{
  "format": "ai-engineer-schema-scope/1",
  "id": "db-aware-research",
  "description": "Read-side exploration for research planning and ingestion authoring",
  "include": { "domains": ["identity","relationships","temporal-facts","evidence","staging","api-surface"],
               "relations": ["orchestration.operation_intent","orchestration.operation_receipt","orchestration.artifact","knowledge_service.operation"],
               "functions": ["temporal.*", "api.*"] },
  "exclude": { "relations": ["public.*", "evaluation.*", "observability.*"] },
  "closure": { "fk_targets": "stub", "vocabularies": "full", "functions_touching_included": "summary" },
  "tasks": ["what-do-we-know-about-entity","find-stale-facts","compose-ingestion-intent","verify-ingestion-result"],
  "queries": ["entity.*","facts.*","evidence.*","staging.*","receipts.*","knowledge.head"]
}
```

Rules: included relations get full L3 pages; FK targets outside the scope get **stub pages** (`relations/<schema>/<name>.stub.md`: identity, columns referenced by in-scope FKs, one line "out of scope; full page in the complete workspace at <fingerprint>"), so no link is broken; vocabularies are always complete (they are small and needed for validity); `INDEX.md`/`relations.txt` list only in-scope relations and a count of omitted ones; `manifest.json.scope` records the scope id, its digest, and the omitted list. The search index contains only in-scope entries plus stubs flagged `stub: true`.

**Visibility is not authorization.** `START_HERE.md` in a scoped bundle states: "This bundle omits relations you were not expected to need. Omission is not access control; the executor and the database roles decide what you may do." The executor validates every operation against the catalog and roles, not against the bundle.

### 4.12 Context efficiency

- Size budgets in §4.3 are enforced by the validator (`SIZE_BUDGET_EXCEEDED` is a build error; the fix is to split into `.details.md`).
- Agents are instructed to search (`rg`, `jq` over `search/index.json`) before reading, to read a domain page before a relation page, and never to `cat` `schema-ir.json` or `search/index.json` whole.
- The named-query catalog means the agent rarely needs column-level pages for common reads; L3 pages are for composing ingestion proposals and for unusual reads.
- Estimated full workspace: ~330 relation pages × ~4 KB + ~60 function pages + 18 domain pages + ~25 task pages ≈ 1.8–2.5 MB on disk; the scoped `db-aware-research` bundle ≈ 350–450 KB. These are estimates from the old workspace's per-page sizes, to be measured at M1.

### 4.13 Validation

`schema-workspace validate` fails the build on: uncovered relations/functions in included schemas; broken intra-workspace links; TS path that does not resolve; frontmatter `id` collisions; enrichment referencing unknown ids; example named query that fails against the disposable DB; intent skeleton that fails schema validation; size budget exceeded; vocabulary row referenced in prose (`stream_kind:` `code`) that no longer exists; a relation page whose `writers` list disagrees with the grants in the IR (renderer bug guard). It emits `validation.json` (committed) with counts and a zero-error assertion.

---

## 5. Materializer, read surface, skills

### 5.1 The materialization program (db-contract)

`node scripts/schema-workspace/cli.mjs <command>` (npm scripts `workspace:build`, `workspace:check`, `workspace:validate`, `workspace:materialize`).

| Command | Inputs | Output | Exit |
|---|---|---|---|
| `introspect --db-url … [--project-ref …]` | connection; `--schemas` default: all application schemas + `util`, excluding platform namespaces | `schema-ir.json` (derived parts) to stdout or `--out` | 0/2 |
| `build [--db-url …] [--enrichment workspace-enrichment/] [--out workspace/]` | IR (fresh or `--ir file`), enrichment, `src/database.generated.ts`, migrations dir | full `workspace/` tree, `manifest.json`, `fingerprint.json`, `validation.json` | 0 ok; 1 validation errors (tree written to temp, not moved); 2 connection/IO |
| `check [--db-url …]` | committed `fingerprint.json` | structured drift report (`drift.json` to stdout) | 0 same; 1 drift; 2 error |
| `validate [--workspace workspace/]` | committed tree | `validation.json` | 0/1/2 |
| `materialize --scope workspace-scopes/<id>.json [--out <dir>] [--format tree\|tarball\|json-bundle]` | committed full workspace (never the DB) | scoped bundle + `manifest.json` with `scope`, `omitted`, `bundle_sha256`; tarball name `schema-workspace-<scope>-<fp16>.tgz` + `.sha256` | 0/1/2 |
| `enrich --draft <relation|domain>` | IR | a YAML stub with all referenced ids pre-filled, `provenance: model_assisted`, `reviewed: null` | 0 |

Configuration: `workspace.config.json` (schemas allowlist, platform namespaces to exclude, size budgets, vocabulary allowlist, renderer version). Connection via `POSTGRES_URL`/`--db-url` (same env vars as `generate-types-native.mjs`). Errors are JSON on stderr with `code` (`DB_UNREACHABLE`, `HEAD_MISMATCH`, `TYPES_OUT_OF_DATE`, `ENRICHMENT_INVALID`, `SIZE_BUDGET_EXCEEDED`, `BROKEN_LINK`, `EXAMPLE_FAILED`).

Reproducible build: same IR + same enrichment + same renderer version ⇒ byte-identical tree (CI asserts by building twice). The tree is committed; PRs that change migrations must include it (`workspace:check` in CI after `db:reset`).

### 5.2 How Knowledge Services consumes it

KS pins `@aiengineer/database-contract` at a git ref (replacing the vendored `0.2.38` tgz) and reads `workspace/` from `node_modules/@aiengineer/database-contract/workspace/` (added to `files` in `package.json`). `packages/schema-workspace` exposes `loadWorkspace()`, `search(query, {kinds, domain, limit})`, `describe(id)`, `materializeScope(scopeId)` (in-memory scoped view built by the same filter rules as the db-contract CLI, verified equal by a test that compares against a committed scoped bundle digest), and `expectedMigrationHead()`. The executor's `health` reports `workspace_fingerprint`, `migration_head`, and the connected database's head.

### 5.3 How eve receives it

Session layer: the profile resolves a scope id; the eve skill for `schema-explore` embeds the scoped bundle as files (the `skill-pack-sync` mechanism already embeds `references/`; the bundle is generated into `.agents/skills/schema-explore/references/workspace/` by `pnpm skills:sync` from the pinned db-contract). Eve materializes skills to `$HOME/.agents/skills/<name>/` at session start, so the agent finds `references/workspace/START_HERE.md`. Deployment layer: the tarball with `knowledge-db`/`knowledge-ingest` binaries and `KNOWLEDGE_EXECUTOR_URL`. The bundle digest is recorded in the session's first `knowledge-db health` step receipt, which is how a run manifest proves which workspace the agent saw. Cursor Cloud receives the same bundle as a repo ref (out of scope here, but the format is a plain tree so nothing prevents it).

### 5.4 Skills (session layer)

Three skills, each following the `knowledge-verify` structure (frontmatter, rules, sequence table with quality gates and files, exit codes, `references/`). Full drafts in [`SKILLS.md`](schema-workspace/SKILLS.md).

| Skill | Purpose | Sequence (files written in `/workspace/run`) |
|---|---|---|
| `schema-explore` | Navigate the workspace to answer "where is X / how do I read or write X" | search → domain → relation/task → record `01-schema-notes.md` (ids consulted, fingerprint) |
| `knowledge-db` | Reads and snapshots | `health` → compose `05-read-intent.json` → `snapshot` → inspect `06-snapshot.json` (knowledge head, digests) → gap notes `07-gaps.md` |
| `knowledge-ingest` | Compose, validate, submit, inspect, re-query | `plan` (dry-run) → fix → `validate` → `submit` → `status` → `receipt` → re-query with `knowledge-db` and diff against `06-snapshot.json` → `90-ingest-summary.md` |

The seven agent capabilities named in the brief map as: explore (schema-explore), query + snapshot (knowledge-db), gaps + research (knowledge-db → knowledge-verify), create intents (knowledge-db/knowledge-ingest), validate + submit (knowledge-ingest), inspect (knowledge-ingest `status`/`receipt`), re-query (knowledge-db).

### 5.5 The safe read surface: named queries

Agents never hold database credentials and never send SQL. The read surface is a **named-query catalog** (`workspace/queries/catalog.json`, `knowledge-query-catalog.v1`), rendered from `workspace-enrichment/queries.yaml` and validated at build time by executing each query against the disposable database. Each entry:

```json
{ "id": "q:entity.card", "title": "Current overview of one entity", "role": "app_reader",
  "sql": "select api.entity_card($1::uuid) as card", "params": { "type": "object", "required": ["entity_id"], "properties": { "entity_id": { "type": "string", "format": "uuid" } } },
  "result": { "shape": "single_json", "schema_ref": "api.entity_card" }, "cost_class": "cheap",
  "temporal": { "world_time": "now()", "knowledge": "head" }, "pagination": null,
  "domain": "identity", "tasks": ["what-do-we-know-about-entity"], "example": { "entity_id": "0192…" } }
```

Initial catalog (all backed by existing objects; the only new SQL object is optional `api.knowledge_head()` returning `(knowledge_seq, updated_at)` for `app_reader`, otherwise `knowledge.head` runs as `pipeline_agent` against `temporal.knowledge_head`):

`entity.resolve`, `entity.card`, `entity.at`, `entity.relationships`, `entity.timeline`, `entity.what_changed`, `entity.by_identifier`, `entity.typed_row` (kind-dispatched), `facts.current_by_stream`, `facts.history_for_stream`, `events.current_for_entity`, `relationships.current_by_kind`, `vocab.stream_kind`, `vocab.relationship_kind`, `vocab.event_kind`, `evidence.claims_for_entity`, `evidence.claim_support`, `evidence.captures_for_source`, `evidence.sources_by_domain`, `staging.candidates_for_kind`, `staging.unresolved`, `knowledge.head`, `receipts.for_intent`, `receipts.recent_for_mission`, `artifacts.by_type`, `retrieval.hybrid_search` (variant; requires embedding computed by the executor from `query_text` with the space's configured model — the agent passes text only), `retrieval.evidence_packet`.

Execution: `SET LOCAL ROLE <catalog role>`, `set local app.tenant_id`, `set transaction read only`, `statement_timeout` (default 15 s, `cost_class: heavy` 60 s), row cap (default 200, max 2,000; beyond that the executor writes the rows to an artifact and returns a reference), parameter validation by JSON Schema, `EXPLAIN` gate for `heavy` queries (rejects sequential scans over configured size classes). The **long tail** is handled by adding catalog entries through a db-contract PR, which is cheap because entries are validated automatically. There is no `raw_sql` on any surface; that entry stays in `FORBIDDEN_MCP_CAPABILITIES`.

### 5.6 Read intents and snapshots

`knowledge-read-intent.v1` batches named queries and retrieval into one reproducible read; the executor returns `knowledge-read-snapshot.v1` with the tenant knowledge head, migration head, workspace fingerprint, per-operation content digests, and a snapshot digest over the per-operation digests. Single commands (`knowledge-db query entity.card --param entity_id=…`) are one-operation intents and still produce a snapshot with a digest. Contracts and examples: [`INTENT_AND_EXECUTOR_CONTRACTS.md`](schema-workspace/INTENT_AND_EXECUTOR_CONTRACTS.md) §1–2.

Freshness is expressed by `knowledge_seq` (stable, monotonic per tenant), not by timestamps. `executed_at` is recorded but excluded from digests. A snapshot is "fresh for ingestion" when its `knowledge_head.knowledge_seq` equals the head at apply time; the executor enforces that with `begin_batch(p_expected_head)`.

**Why one contract for query and retrieval:** both are reads over the same tenant and the same knowledge head, both need identical provenance (role, catalog id, parameters, digests), and the mission input snapshot must be one artifact with one digest that an ingestion intent can reference. Retrieval differs only in parameters and result shape, which is what a discriminated `kind` handles. Two contracts would force agents to stitch two snapshots and executors to validate two freshness proofs.

---

## 6. Ingestion intents and the deterministic executor

### 6.1 Contract

`knowledge-ingestion-intent.v1` (schema and worked example in [`INTENT_AND_EXECUTOR_CONTRACTS.md`](schema-workspace/INTENT_AND_EXECUTOR_CONTRACTS.md) §3): envelope with `schemaVersion`, `intentId`, `context {tenantId, missionId?, activationId?, attemptId?, correlationId}`, `contract {migrationHead, workspaceFingerprint, rulesVersion}`, `inputSnapshot {snapshotId, snapshotDigest, knowledgeSeq}`, `expectedKnowledgeHead`, `onStale: fail | rebase_if_disjoint`, `evidence {verificationRuns: [{runId, manifestDigest}]}`, `subjects[]` (resolved refs or `new` subjects with proposed kind/payload/identifiers), `proposals[]`, and `idempotencyKey`.

Proposal kinds, each mapped to the current write path:

| Kind | Target | Executor action (as `executor_service`, inside the batch) |
|---|---|---|
| `entity.create` | `staging.candidate` → `resolution_decision(create)` → `corpus.entity` + typed table + `entity_alias`/`entity_identifier` | Candidate row (provenance), decision with receipt, entity rows with `created_by_receipt_id`; `entity_name` stream asserted via `assert_state` |
| `entity.alias` / `entity.identifier` | `corpus.entity_alias` / `entity_identifier` | Insert if absent (unique keys make it idempotent) |
| `relationship.assert` | `corpus.relationship` (+ `relationship_active` segment for temporal kinds) | `temporal.assert_relationship(kind, from, to, valid_during, qualifier, episode, properties, extent, claim)` |
| `fact.assert_state` | `temporal.segment` on `stream(kind, subject, scope_key)` | `temporal.make_extent(...)` then `temporal.assert_state(...)` with claim id and `p_temporal_basis` |
| `event.assert` | `temporal.event` + `event_occurrence` | `temporal.assert_event(...)` |
| `support.admit` | `evidence.segment_support` | `temporal.admit_support(segment|occurrence, claim, locator, role)` |
| `claim.materialize` | `evidence.source`, `source_capture`, `locator`, `claim`, `claim_subject` | Materialize referenced sealed-run claims and their captures/quotes (§6.5); always implied by proposals that cite a claim not yet in `evidence.claim` |
| `metric.observe` | `ranking.metric_observation` | Insert with `claim_id`, `locator_id`, `observed_at` |
| `candidate.stage` | `staging.candidate` only (no identity decision) | For subjects the agent could not resolve and wants a human/identity pass on |
| `report.publish` | `research.report`, `report_version`, `report_claim` | Register the report artifact (from the verification run's registered report) and link claims. Staged: requires a `mission_id` today (`research.report.mission_id` nullable, `research_bundle.mission_id` not null); publish only the report/version/claim rows |

Every proposal cites evidence as `{ runId, claimId }` (and optionally `locatorRef` from the sealed run). Every fact proposal declares its `worldInterval` (`valid_during`/`occurred_during` with precision, or an extent source text), its `temporalBasis` (`explicit | carry_forward | observation_bounded | unresolved`), and `belief`.

### 6.2 Executor phases (deterministic, replayable)

1. **parse+schema**: JSON Schema (`knowledge-ingestion-intent.v1`); `INTENT_SCHEMA_INVALID` (exit 1).
2. **contract check**: `migrationHead` and `workspaceFingerprint` match the executor's pinned workspace and the connected database head; `WORKSPACE_STALE` / `HEAD_MISMATCH` (exit 2).
3. **evidence eligibility**: each cited run is sealed (`inspection.valid`), each `claimId` has a judge verdict in `directly_supported | supported_with_qualification` and policy outcome not `fail|abstain`; captures exist; `EVIDENCE_NOT_ELIGIBLE` (exit 1) with the offending ids.
4. **subject resolution**: resolved refs must exist and be `lifecycle='active'` (merged → `SUBJECT_MERGED` with the target); new subjects are matched with `api.resolve_entity` and identifier lookups; a high-confidence match (score ≥ 0.98 on identifier, or configured threshold on alias) turns `entity.create` into `review_required` unless the intent says `onMatch: use_existing` → the proposal is rewritten to reference the match, recorded in the plan.
5. **vocabulary validity**: `relationship_kind` endpoints, `stream_kind` subject kinds/status/unit/amount/payload schema, `event_kind` subjects, currency format; `VOCABULARY_VIOLATION` (exit 1). These duplicate database checks on purpose so the agent gets a readable error before a transaction is attempted.
6. **admission comparison** (read-only, as `pipeline_agent`, at current head `K_now`): for each proposal compute `no_op_duplicate` (identical current segment/relationship/occurrence exists), `superseded` (a newer knowledge batch already asserted a conflicting current value for the same stream slot and interval, and the intent's world interval is contained), `admitted`, `review_required` (identity ambiguity, or `belief: disputed` against an `accepted` current segment), `held` (missing optional evidence such as a required `context` quote for a table cell per rules), `quarantined` (subject merged/retired after the snapshot). If `expectedKnowledgeHead ≠ K_now` and `onStale = rebase_if_disjoint`: compute `api.what_changed(subject, K_snapshot, K_now)` for every subject; if no proposal touches a changed stream slot/relationship/event, rebase (`expectedKnowledgeHead := K_now`, recorded); otherwise fail `REBASE_REQUIRED` (exit 1) with the diff.
7. **plan artifact**: `knowledge-ingestion-plan.v1` with per-proposal outcome, resolved ids, computed idempotency keys, and the SQL helper calls to be made (as structured records, not SQL text). `knowledge-ingest plan` stops here (dry-run). `validate` = phases 1–6 with `no DB writes`.
8. **apply** (single transaction, as `executor_service`): `set local app.tenant_id`; insert `orchestration.operation_intent (intent_type='knowledge_ingestion', schema_version=1, payload=intent envelope minus large arrays, preconditions={expectedKnowledgeHead, snapshotDigest}, idempotency_key, proposed_by_attempt, mission_id, approval_state='approved' by executor policy)`; insert `operation_receipt` with the **planned** outcome (`applied` if all admitted/no-op; `partial` if some proposals are review/held/quarantined; `noop` if all no-op) and `precondition_results`; `temporal.begin_batch(expectedKnowledgeHead)`; apply admitted proposals in dependency order (claims → entities → aliases/identifiers → relationships → extents → segments/events → supports → metrics → report); `temporal.commit_batch(receipt_id, idempotency_key, intent_sha256, summary)`; `commit`. Any error → rollback, and a **second short transaction** writes intent + receipt `outcome='rejected'` with the error, so the failure is durable too (no batch is opened for that).
9. **receipt**: `knowledge-ingestion-receipt.v1` with `receiptId`, `knowledgeSeq` (from `commit_batch`), per-proposal outcomes and created ids, `affected_refs`, storage refs, and `duplicate_of` when applicable.
10. **storage + outbox**: intent, plan, receipt to bucket + `orchestration.artifact` + lineage (§6.4); `knowledge_service.operation` row (`operation_kind='knowledge_ingestion'`, `ownership_mode` from context: `eve` in experiments, `mission_control` when MC calls) with steps and an outbox event `knowledge.batch_sealed` (topic already emitted by the projection workers migration).

Why the receipt is inserted before the facts: `corpus.entity.created_by_receipt_id`, `staging.*_decision.receipt_id`, and `knowledge_batch.receipt_id` are `not null` FKs, and `operation_receipt` is immutable, so the outcome must be **known before apply**. Phases 1–7 make that possible: admission is decided on the plan; apply either performs the plan exactly or rolls back entirely.

### 6.3 Idempotency, duplicates, concurrency, supersession, rebase

- **Idempotency key** = `sha256(tenantId ‖ intentId ‖ canonical(proposals) ‖ inputSnapshot.snapshotDigest ‖ contract.rulesVersion)`. It is the `operation_intent.idempotency_key` (unique) and the `knowledge_batch.idempotency_key` (unique per tenant). A second submission of the same bytes returns the existing receipt with `duplicate_of` and exit 0; the same `intentId` with different proposals is a **new** intent (different key) and is admitted or rejected on its own merits; the agent is told in the receipt that a prior receipt exists for that `intentId`.
- **Duplicate parallel submissions** (the observed 2–4× identical tool calls): the first transaction wins the unique index; the losers see `23505` on `operation_intent.idempotency_key`, wait for the winner's receipt (poll up to 30 s), and return it as `duplicate_of`.
- **Expected head**: `begin_batch(p_expected_head)` fails with SQLSTATE 40001 if another batch was committed since the snapshot; the head row is locked `for update` so two executors cannot open batches concurrently (the second gets `knowledge batch already open` and retries after the first commits, then re-runs phase 6).
- **Supersession** is not an agent action. A newer fact for the same stream slot is asserted with `assert_state`; the helper closes and splits the old segments (`replaces_segment_id` records lineage). The plan reports `supersedes: [segment ids]` for the agent's re-query.
- **Rebase**: see phase 6. The receipt/failure includes `what_changed` diffs so the agent's recovery path is "re-snapshot the listed subjects, reconcile, resubmit".

### 6.4 Storage and lineage

Bucket **`research-ingestion-intents`** (exists; no client policies; service role writes via `SupabaseArtifactStore`). Object paths are content-addressed for immutable JSON: `<tenant>/<sha256[0:2]>/<sha256>.json`; the logical index is `orchestration.artifact` (bucket_class `ledger`), not the path. New `artifact_type` codes (migration in db-contract): `knowledge_read_intent`, `knowledge_read_snapshot`, `knowledge_ingestion_plan`, `knowledge_ingestion_receipt`, `schema_workspace_manifest`, `knowledge_report_markdown`; `ingestion_intent` (exists) is reused for the intent body. Lineage edges (`artifact_lineage`): snapshot `derived_from` read intent; ingestion intent `derived_from` snapshot; plan `derived_from` intent; receipt `produced_by` plan and `consumed_by` intent, with `receipt_id` set on the edges written in the apply transaction. Retry/partial failure: bucket writes are idempotent (`x-upsert:false` + collision verification); if the bucket write fails after the DB commit, the executor records `storage_state='pending'` on the artifact row (column exists from the verification artifact lifecycle migration) and a retry step completes it; receipts are never lost because the receipt row is in Postgres. Access: agents read artifacts only through `knowledge-db artifact get <id>` / `artifact_get` (executor-mediated), never with bucket credentials; large results are served by the executor as bytes (presigned URLs are not implemented in `SupabaseArtifactStore` and are not required for this slice).

### 6.5 Evidence materialization from sealed runs (required adjacent work, minimal)

The verification executor's store is filesystem-based; its sealed runs are not in `evidence.*`. For an ingestion proposal to carry `primary_claim_id` and `segment_support.locator_id`, the executor materializes **only the cited claims**: register the run's captures as `orchestration.artifact` (bucket `source-captures`, `bucket_class source_captures`) + `evidence.source` (by canonical URL) + `evidence.source_capture` (content_sha256 from the run) as `pipeline_agent`-permitted inserts; create `evidence.locator` rows from the run's resolved quotes (`selector_kind text_quote`, `selected_content_sha256`); create `evidence.claim` rows (`claim_type` from the intent, `statement` = claim text, `status='verified'`, `created_by_receipt_id` = this receipt) and `claim_subject` rows. The verification run's manifest digest is stored in `claim.structured.verification` for traceability. This is the synthesis point between verification and ingestion; the general bucket-store migration of the verification executor remains handoff §5.2 work.

### 6.6 Rules as data

`workspace-enrichment/ingestion-rules.yaml` → rendered `workspace/rules/ingestion-rules.v1.json` and `rules/README.md`. Encodes the blueprint's entity rules in checkable form: e.g. `organization.headquarters → stream_kind:? (none today) → candidate.stage + review_required`, `person.employment → relationship employed_by (temporal) + engagement_role stream`, `model_offering.price → model_offering_price with unit_values and currency`, `table-cell quotes require a context quote`. The executor cites `rulesVersion` in every plan and receipt; the skill links the rendered rules page. Rules that the database already enforces are marked `basis: enforced` and are not duplicated as prose.

---

## 7. Surfaces: CLI, HTTP, MCP, skills, and the Mission Control boundary

### 7.1 CLI (in the knowledge executor tarball; remote mode via `KNOWLEDGE_EXECUTOR_URL`, alias of `VERIFY_EXECUTOR_URL` during transition)

```
knowledge-db   health | search <text> [--kind rel|fn|domain|task] [--limit] | describe <id> | domain <slug> | task <slug>
               catalog [--domain] | query <named> [--param k=v]... [--as-of <ts>] [--k <seq>] [--limit] [--out]
               snapshot <read-intent.json> [--out] | artifact get <artifactId> [--out]
knowledge-ingest plan <intent.json> [--out] | validate <intent.json> | submit <intent.json> [--wait] [--out]
               status <intentId|receiptId> | receipt <receiptId> [--out] | rules [--version]
```

Exit lattice: 0 success/gate passed; 1 quality gate failed (`INTENT_SCHEMA_INVALID`, `EVIDENCE_NOT_ELIGIBLE`, `VOCABULARY_VIOLATION`, `REBASE_REQUIRED`, `SUBJECT_MERGED`, `REVIEW_REQUIRED_ONLY`); 2 usage/network/auth/executor (`WORKSPACE_STALE`, `HEAD_MISMATCH`, `DB_UNAVAILABLE`, `ROLE_DENIED`). One JSON document on stdout; `--out` writes the full JSON and prints a compact summary; every command appends a step receipt under the run.

### 7.2 HTTP (executor, canonical)

`GET /health`, `GET /schema/manifest`, `GET /schema/search?q=&kind=&limit=`, `GET /schema/describe/:id`, `GET /schema/domains/:slug`, `GET /schema/tasks/:slug`, `GET /db/catalog`, `POST /db/query` (one named op), `POST /db/snapshots` (read intent → snapshot), `GET /db/snapshots/:id`, `POST /ingest/plans`, `POST /ingest/validate`, `POST /ingest/intents` (submit; `Idempotency-Key` header = intent idempotency key), `GET /ingest/intents/:id`, `GET /ingest/receipts/:id`, `GET /ingest/rules`, `GET /artifacts/:id` (exists). Auth: bearer (`KNOWLEDGE_EXECUTOR_TOKEN`), `x-tenant-id`, optional `x-attempt-id`/`x-mission-id`/`x-activation-id` copied into `context`. Errors: `{ code, message, details, retryable }`.

### 7.3 MCP

Generated from the same Zod schemas as the CLI (one `defineOperation({ name, input, handler })` registry produces CLI subcommand, HTTP route, and MCP tool; this is the "one schema → three surfaces" helper the handoff §5.6 asked for, introduced here for the new families and applied to `verify_*` opportunistically).

Executor MCP tools: `schema_search`, `schema_describe`, `schema_domain`, `schema_task`, `db_catalog`, `db_query`, `db_snapshot`, `ingest_plan`, `ingest_validate`, `ingest_submit`, `ingest_status`, `ingest_receipt`, `ingest_rules`, `artifact_get`. Tool descriptions embed the START_HERE navigation rule in ≤ 300 characters so arm C gets equivalent guidance to A's skill in the tool surface itself (the protocol records this as a deliberate design choice, §8).

Platform `apps/mcp` (phase 7): register the same names by proxying to the executor HTTP (documented like the verification proxy in `SURFACE-REFERENCE.md`), keep `raw_sql`/`storage.list` forbidden, extend `catalog.test.ts`.

### 7.4 Skills

`schema-explore`, `knowledge-db`, `knowledge-ingest` live at `apps/knowledge-executor/skills/<name>/` (canonical), are listed in `skills/manifest.json`, and are synced into the proving ground by `skill-pack-sync`. The scoped workspace bundle is a `references/workspace/` subtree of `schema-explore`.

### 7.5 Staging

| Surface | Phase 3–4 (this slice) | Phase 7 (deferred) |
|---|---|---|
| CLI | full | — |
| HTTP (executor) | full | platform `apps/api` `/v1/knowledge/...` routes proxy or re-host |
| MCP | executor MCP full | platform `apps/mcp` re-export |
| Skill | full | overlays for Cursor/Claude hosts |
| Worker operation kind `knowledge_ingestion` | executor writes `knowledge_service.operation` directly | worker-admitted kind with leases, for MC-owned execution |

### 7.6 Mission Control boundary

Knowledge Services supplies: the workspace bundle, the named-query catalog, the intent contracts, the executor, and receipts. Mission Control (when M1+ lands) decides: which profile receives `schema-explore`/`knowledge-db`/`knowledge-ingest`, under which grant, with which budget; whether an intent's `approval_state` moves from `pending` to `approved` (today the executor sets `approved` under a **standalone policy** recorded in `policy_decision: {mode: 'standalone', policy: 'executor-default.v1'}`; when MC calls, it passes `context.approval = {grantId, decidedBy}` and the executor records that instead); and the `ingestion_executor` identity binding (`ownership_mode='mission_control'`). Nothing in this spec creates `mission_control.*` objects or writes to `orchestration.mission`; `mission_id`/`attempt_id` are recorded only when supplied.

---

## 8. The three-way eve experiment (design now, run A/B first, C later)

Full protocol in [`EXPERIMENT_PROTOCOL.md`](schema-workspace/EXPERIMENT_PROTOCOL.md). Summary of the design decisions:

- **Arms.** A: scoped workspace bundle + three skills + `knowledge-db`/`knowledge-ingest` CLIs (remote mode) + shared verification/discovery. B: Supabase CLI (`supabase db query --db-url`, `gen types`, `inspect`) with a login role that can `SET ROLE pipeline_agent` and `SET ROLE executor_service` on the isolated database, the temporal helper contract described only by the database itself (comments, `\df`-equivalent catalog queries), no workspace, no schema/ingestion skills, plus shared verification/discovery. C: executor MCP tools `schema_*`/`db_*`/`ingest_*` + shared verification (MCP) + discovery (MCP); no CLI, no skill files.
- **Verified Supabase CLI facts** (2.98.2 installed; 2.115.0 pinned in db-contract): `db query [sql] --db-url|--linked|--local -f file -o json|table|csv` executes arbitrary SQL directly against a connection string (verified: no Docker involved; `--linked` goes through the Management API and is not used); `db dump` needs Docker (not assumed available in the sandbox); `gen types --db-url --schema` works; `inspect db *` are statistics tools, not schema browsers. **Adjustment:** B's baseline is `db query` against `pg_catalog`/`information_schema` plus the temporal helpers; B does not get `db dump`. B must write `operation_intent`/`operation_receipt` rows itself to satisfy `commit_batch`; the protocol counts that as part of B's task.
- **What is measured.** A vs B compares **complete capability packages** (workspace + skills + executor vs raw SQL + database self-description); A vs C compares **interface effects** while holding the executor constant (same named queries, same intent validation, same receipts). The report never attributes an A-over-B advantage to transport, and it names B's extra power (raw SQL, direct role use) as a confound that can cut either way.
- **Controls.** Same model (`openai/gpt-5.6-terra`, reasoning `high`, pinned in `experiment.json`), same task brief and as-of date, same budgets (tool calls, wall clock, tokens), same seeded database state (`exp3-seed` fixture: a partial and partly stale OpenAI subgraph), same fixed evidence set (pre-captured pages with digests; discovery tools disabled in the controlled runs), same evaluator rubric and evaluator procedure; database reset between runs (`db:reset` on the isolated local stack); 3 repetitions per arm minimum; a separate live-web demonstration lane with discovery enabled that is reported descriptively only.
- **Task.** A bounded, source-attributed report on OpenAI's AI products and software as of 2026-09-11 with eight questions that exercise identities (organization, products, model families/versions, people), relationships (`develops`, `offered_as`, `version_of`, `built_on_model`, `employed_by`), temporal facts (`model_offering_availability`, `model_offering_price`, `product_feature_availability`), and evidence-backed claims; the agent must snapshot, find gaps/stale/conflicts, verify, report, ingest, read back, resubmit the same intent (duplicate handling), and recover from one injected stale-state failure (a background batch committed between snapshot and submit) and one injected validation failure (a proposal with a disallowed unit).
- **Metrics.** Report quality and attribution (rubric), query correctness and navigation accuracy (gold answers from the fixture), ingestion validity and canonical results (DB delta vs gold delta, vocabulary errors), temporal correctness (intervals, basis, head), duplicate handling (second receipt `duplicate_of`), tool calls, tokens, latency, cost (from `events.jsonl` usage), failures, human interventions. Artifacts per run: `run-manifest.json`, `transcript.md`, `events.jsonl`, intent/snapshot/receipt files, `db-before.json`/`db-after.json`/`db-delta.json`, `metrics.json`, `evaluation.json`.
- **A gets scrutiny, not favor.** The protocol lists the ways B or C could win (B: fewer round trips, direct SQL for ad-hoc joins; C: no file navigation, tool descriptions as guidance) and requires reporting them.

---

## 9. Phased implementation plan

Dependencies are stated; acceptance criteria are checkable.

| # | Phase | Depends on | Deliverables | Acceptance criteria |
|---|---|---|---|---|
| **M1** | **IR + full workspace + validator + CI (db-contract)** | 0.3.0 head | `scripts/schema-workspace/{introspect,ir,render,validate,fingerprint,cli}.mjs`, `workspace.config.json`, `workspace/` committed, `workspace:build/check/validate` scripts, CI job after `db:reset` | Build from the disposable DB produces byte-identical output on two runs; all 18 application schemas + `util` covered; `validation.json` has 0 errors; `check` against the same DB exits 0 and against a DB with one added column exits 1 with a diff naming the column; every relation page ≤ 6 KB main / ≤ 16 KB details; TS paths resolve for 100 % of tables/views/functions present in `database.generated.ts` |
| **M2** | Enrichment + domains + tasks + named-query catalog + scoped materialization | M1 | `workspace-enrichment/{domains,aliases,terminology,tasks,queries,ingestion-rules}.yaml`, `enrich --draft`, `materialize --scope`, `workspace-scopes/{db-aware-research,ingestion-author,full}.json`, `queries/catalog.json`, `rules/` | 18 domain pages with provenance; ≥ 25 named queries all executing against the disposable DB in validation; ≥ 12 task pages with executable examples; scoped `db-aware-research` bundle has no broken links (stubs present), ≤ 500 KB, and its manifest lists omissions; `enrich --draft` output validates with zero manual edits for a fresh relation |
| **M3** | Knowledge executor: read surface (`knowledge-db`), workspace loader, snapshots, storage, MCP `schema_*`/`db_*` | M2; KS pin of db-contract at git ref; persistence `SET ROLE` | `packages/schema-workspace`, `packages/db-read`, executor commands/routes/tools, `defineOperation` registry, `skills/schema-explore`, `skills/knowledge-db`, migration adding artifact types | `knowledge-db health` reports matching heads; every catalog query runs with the catalog role and rejects a parameter that violates its schema; a read intent with 5 ops returns a snapshot whose digest is identical across two executions at the same head and differs after a committed batch; snapshot + intent stored with lineage rows; `WORKSPACE_STALE` returned when the executor's workspace head ≠ DB head; tests for digesting, role switching, row caps |
| **M4** | Ingestion executor (`knowledge-ingest`), evidence materialization, rules, MCP `ingest_*` | M3; verification executor run access | `packages/ingestion`, executor commands/routes/tools, `skills/knowledge-ingest`, `intent_type 'knowledge_ingestion'` migration | Against the disposable DB seeded with `exp3-seed`: (1) an intent with 6 proposals across entity/relationship/fact/event kinds applies, `knowledge_head.knowledge_seq` increments by 1, receipt `applied`, per-proposal ids returned; (2) resubmitting the same file returns `duplicate_of` with no new batch; (3) submitting after a foreign batch returns `REBASE_REQUIRED` with `what_changed` when a touched slot changed, and auto-rebases when disjoint; (4) a proposal citing an unsealed run fails `EVIDENCE_NOT_ELIGIBLE` before any transaction; (5) a bad `unit` fails `VOCABULARY_VIOLATION` at phase 5 and, if forced past it in a test, is also rejected by `commit_batch`; (6) cited claims appear in `evidence.claim` with locators whose `selected_content_sha256` matches the run |
| **M5** | Proving ground: profiles A and B, sandbox bootstrap, fixture, runner metrics, DB snapshotting; run A and B | M4; isolated local stack | `profiles.ts` (+2), `sandbox.ts` (supabase CLI for B; tarball for A), `experiments/exp3-schema-workspace/`, runner: `metrics.json`, `db-before/after/delta.json`, repeat loop, `run-manifest.json`; evaluator scripts | Runner completes 3 runs per arm with reset between runs; every run manifest has model, bundle digest, fixture digest, budgets; `metrics.json` sums usage from `events.jsonl`; evaluator produces `evaluation.json` from gold answers; report written in `experiments/exp3-*/README.md` with results **only after runs exist** |
| **M6** | Arm C: executor MCP profile, run C, three-way comparison | M5 | `profiles.ts` (+1), connection allowlist for the executor MCP, `experiment.json` for C | 3 runs of C; comparison table across A/B/C with the confound notes required by the protocol |
| **M7** | Platform re-export and MC handoff (staged) | M4; MC M1 | `apps/mcp` proxies, `apps/api` routes, worker kind `knowledge_ingestion`, `SURFACE-REFERENCE.md` update, MC note on `ingestion_executor` binding | Platform MCP catalog test includes the new names and still excludes `raw_sql`; a call through the platform MCP produces the same receipt as the executor CLI for the same intent |

Code-health obligations bundled into M3/M4 (from handoff §5.6, limited to what these phases touch): shared digest/UUID helper used by the new packages; `defineOperation` registry replacing hand-rolled arg parsing for the new commands; tests for `store.ts`/`capture.ts` where the ingestion executor reads them; persistence pin to 0.3.0 by git ref.

---

## 10. Risks, unresolved decisions, assumptions

### 10.1 Risks

| Risk | Mitigation |
|---|---|
| Enrichment rots as the schema evolves | Validator rejects dangling ids; `enrich --draft` regenerates stubs; provenance + `reviewed` dates make staleness visible; domain pages are short by budget |
| Agents over-trust curated guidance | Visual `curated` blocks, `basis` on edges, skill rule "only enforced/vocabulary is a guarantee" |
| The executor's DB user needs `service_role`-level membership to `SET ROLE` bounded roles | Use a dedicated login role granted `pipeline_agent` and `executor_service` only (created in the runtime environment, not in the contract); document in KS `DEPLOYMENT.md`; never `service_role` in the executor |
| Evidence materialization couples ingestion to the verification store layout | Read runs through the verification executor's HTTP (`/runs/:id`, `/artifacts/:id`), not the filesystem; the interface is the sealed manifest |
| Receipt-before-apply misreports when apply fails | Whole-transaction rollback removes the optimistic receipt; a separate `rejected` receipt is written; tests cover both paths |
| Arm B leaks credentials into the sandbox | B's DB URL points only at the isolated experiment stack with a throwaway login role; the protocol forbids running B against shared databases |
| Workspace size grows past budgets as schemas grow | Budgets enforced; `.details.md` spill; scoped bundles for agents |
| `what_changed` is entity-scoped; rebase needs relationship/event coverage | `what_changed` already covers segments, occurrences, and relationships touching the entity; the executor calls it per subject and unions |

### 10.2 Unresolved decisions (do not block M1–M2)

1. Rename `apps/verification-executor` → `apps/knowledge-executor` at M3, or keep the directory and add binaries. Recommendation: rename at M3 with bin names unchanged.
2. Whether `retrieval.hybrid_search` embeddings in the read executor use the KS `embeddings` package directly or call the platform API. Recommendation: platform API, to keep provider keys out of the executor.
3. Whether standalone-mode ingestion (no MC) should require a human gate for `review_required` proposals or simply hold them. Recommendation: hold and report; no gate in the experiment.
4. Object path convention alignment with `SupabaseArtifactStore` (`{tenant}/{digest[7:9]}/{digest[7:]}`) vs the shorter form in §6.4. Recommendation: use the store's existing convention unchanged.

### 10.3 Assumptions

- The disposable local stack (`db:start`/`db:reset`) and PG 17 remain the build and test target; production introspection uses `--project-ref` read-only credentials.
- The tenant used in experiments is `00000000-0000-7000-8000-000000000001` (the id in `SCHEMA-SUMMARY.md`).
- `openai/gpt-5.6-terra` remains available via the AI gateway for the duration of the experiment; otherwise the protocol pins whatever model is chosen for all arms.
- The eve sandbox can reach the host (executor and, for B, Postgres) via `host.docker.internal` as in exp2.
- Nothing here changes `public.research_*` protected tables or transcript buckets.
