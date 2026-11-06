# Schema workspace: layout, budgets, and sample artifacts

Companion to [`../SCHEMA_WORKSPACE_MATERIALIZATION_SPEC.md`](../SCHEMA_WORKSPACE_MATERIALIZATION_SPEC.md) §4. Everything below is a **design sample** written from migrations `km_01`–`km_12` before the generator existed. **Status (2026-09-12):** the generator has since produced the committed `../../workspace/` tree (head `20260912040000`); the real pages are the authority for layout and content, and the spec's "Implementation record" lists the measured sizes and the two budgets that were raised. The samples remain useful as an explanation of intent. Where a value would come from the live catalog and is not knowable from the migrations alone (row-count classes, `defined_in` for older tables), the sample shows the placeholder the renderer would emit.

Format identifier for the new generator: `ai-engineer-schema-workspace/3`. IR: `ai-engineer-schema-ir/1`.

---

## 1. Directory tree (full workspace, committed in `ai-engineer-db-contract/workspace/`)

```
workspace/
├── START_HERE.md                      L0  ≤ 2 KB   navigation rule + three entry points
├── INDEX.md                           L0  ≤ 4 KB   domains → schemas → counts → entry files
├── relations.txt                      L0  ~8 KB    one qualified relation name per line, grouped by schema
├── manifest.json                      machine     build identity, layer inventory, sizes, volatile build info
├── fingerprint.json                   machine     fingerprint + workspace_fingerprint + inputs
├── validation.json                    machine     validator output (0 errors asserted)
├── schema-ir.json                     machine     canonical IR (never read whole by agents)
├── domains/                           L1  ≤ 8 KB each
│   ├── identity.md
│   ├── relationships.md
│   ├── temporal-facts.md
│   ├── evidence.md
│   ├── content.md
│   ├── knowledge-records.md
│   ├── retrieval.md
│   ├── ranking.md
│   ├── staging.md
│   ├── orchestration-ledger.md
│   ├── knowledge-service-runtime.md
│   ├── research.md
│   ├── evaluation.md
│   ├── curriculum.md
│   ├── observability.md
│   ├── provenance.md
│   ├── api-surface.md
│   └── research-starter-protected.md
├── schemas/<schema>/README.md         L2  ≤ 12 KB  relation summary table for one schema (18 + util)
├── relations/<schema>/<name>.md       L3  ≤ 6 KB   complete reference for one relation
├── relations/<schema>/<name>.details.md   ≤ 16 KB  spill: indexes, policies, triggers, view SQL (only when needed)
├── functions/<schema>/<name>.md       L3  ≤ 6 KB   one page per function (overloads grouped)
├── types/<schema>.md                  L3           enums, domains, composite types per schema
├── vocabularies/<schema>.<table>.md   L3  ≤ 16 KB  snapshot of allowlisted reference tables (matrices)
├── tasks/<slug>.md                    task ≤ 5 KB  question → navigation → operation → shape → pitfalls
├── rules/
│   ├── README.md                                  ingestion rules, human-readable
│   └── ingestion-rules.v1.json                    rules as data (executor cites rulesVersion)
├── queries/
│   ├── README.md                                  how named queries work; one table of all queries
│   └── catalog.json                               knowledge-query-catalog.v1
└── search/
    ├── index.json                     ≤ 250 KB   one entry per relation/function/domain/task/term
    ├── aliases.json                               alias → [ids]
    └── terminology.json                           term → definition + ids
```

Scoped bundle (`materialize --scope db-aware-research`): the same tree filtered, plus `scope.json` and `relations/<schema>/<name>.stub.md` for out-of-scope FK targets. `START_HERE.md` carries the "omission is not access control" paragraph.

Size budgets are validator-enforced. Estimated totals (from the old workspace's measured per-page sizes: median relation page 3.6 KB, largest 23.5 KB): full ≈ 1.8–2.5 MB; `db-aware-research` ≈ 350–450 KB. Measured at M1.

---

## 2. L0 samples

### 2.1 `START_HERE.md`

```markdown
---
id: start
kind: entry
workspace_fingerprint: sha256:3f9c…
migration_head: "20260912011200"
contract_version: "0.3.0"
---

# Start here

This workspace describes the shared AI Engineer database at migration head `20260912011200`.
It is generated from the database catalog; blocks marked `> curated` are human guidance that
was validated against the catalog but is not enforced by it.

## Navigation rule (≤ 4 reads to an operation)

1. Search before reading: `rg -n "<word>" search/index.json` or
   `jq -c '.[] | select(.aliases[]? == "<alias>")' search/index.json`.
2. Read the **domain** page (`domains/<slug>.md`) before any relation page.
3. Read a **task** page (`tasks/<slug>.md`) if your question matches one; it names the exact
   named query or intent skeleton.
4. Open a **relation** or **function** page only to compose a proposal or an unusual read.
5. Never read `schema-ir.json` or `search/index.json` whole.

## Entry points

- `INDEX.md` — domains, schemas, counts.
- `relations.txt` — every relation name (grep it).
- `queries/README.md` — every named query you can run with `knowledge-db query`.

## Reading and writing

Applications and agents read through named queries (role `app_reader` or `pipeline_agent`).
Canonical facts are written only by `executor_service` through `temporal.begin_batch` →
`temporal.assert_*` → `temporal.commit_batch`, and only via a receipt. You author intents;
the knowledge executor writes. See `domains/temporal-facts.md` and `tasks/compose-ingestion-intent.md`.
```

### 2.2 `INDEX.md` (excerpt)

```markdown
# Index

| Domain | Schemas | Relations | Functions | Start with |
|---|---|---:|---:|---|
| identity | corpus | 41 | 4 | `domains/identity.md`, `tasks/what-do-we-know-about-entity.md` |
| relationships | corpus, taxonomy | 2 | 3 | `domains/relationships.md` |
| temporal-facts | temporal | 9 | 14 | `domains/temporal-facts.md`, `tasks/find-stale-facts.md` |
| evidence | evidence | 32 | 6 | `domains/evidence.md` |
| api-surface | api | 8 views | 15 | `domains/api-surface.md`, `queries/README.md` |
| orchestration-ledger | orchestration | 36 | 12 | `domains/orchestration-ledger.md` |
| … | | | | |

Counts are relation counts at head `20260912011200`; child vector partitions are excluded.
```

### 2.3 `relations.txt` (excerpt)

```
# corpus
corpus.agent_skill
corpus.ai_model
corpus.ai_model_version
corpus.ai_model_version_spec
corpus.benchmark
…
corpus.entity
corpus.entity_alias
corpus.entity_identifier
corpus.entity_merge
…
corpus.relationship
# temporal
temporal.event
temporal.event_kind
temporal.event_occurrence
temporal.extent
temporal.knowledge_batch
temporal.knowledge_head
temporal.segment
temporal.stream
temporal.stream_kind
# api (views)
api.current_facts
api.current_relationships
api.entities
api.events_current
api.library_profile
api.review_queue
api.technical_record_search
```

---

## 3. L1 sample: `domains/temporal-facts.md`

```markdown
---
id: dom:temporal-facts
kind: domain
schemas: [temporal]
aliases: [facts, two-clock, bitemporal, history, timeline, knowledge head, batch]
relations: [temporal.knowledge_head, temporal.knowledge_batch, temporal.extent, temporal.stream, temporal.segment, temporal.event, temporal.event_occurrence, temporal.stream_kind, temporal.event_kind]
functions: [temporal.begin_batch, temporal.commit_batch, temporal.make_extent, temporal.assert_state, temporal.assert_relationship, temporal.assert_event, temporal.close_segment, temporal.admit_support, temporal.withdraw_support, temporal.current_k, api.entity_at, api.entity_timeline, api.what_changed]
tasks: [what-do-we-know-about-entity, find-stale-facts, compose-ingestion-intent, verify-ingestion-result]
provenance: human
reviewed: 2026-09-11
workspace_fingerprint: sha256:3f9c…
---

# Temporal facts (two clocks)

A fact is a `temporal.segment` on a `temporal.stream`. The stream is `(kind, subject, scope_key)`;
the segment is a world-time interval `valid_during` plus a knowledge interval `[k_from, k_to)`.

> curated — The two clocks answer different questions. `valid_during` says *when the world was
> like this*. `k_from`/`k_to` say *when we came to know it / stopped believing it*. "Current"
> means `k_to is null` **and** `valid_during @> now()`. Historical questions use
> `api.entity_at(entity, world_time, knowledge_seq)`.

## Relations that matter

| Relation | Role | Enforced facts |
|---|---|---|
| `temporal.knowledge_head` | one row per tenant; `knowledge_seq` is the tenant clock; `open_xid`/`open_k` mark an open batch | no DML for any role; only helpers |
| `temporal.knowledge_batch` | one row per sealed batch; `receipt_id → orchestration.operation_receipt` **not null**; `unique(tenant_id, idempotency_key)` | insert only by `commit_batch` |
| `temporal.stream` | `(kind → stream_kind, subject_entity_id | subject_relationship_id, scope_key)`; exactly one subject | `unique nulls not distinct (tenant, kind, subject…, scope_key)` |
| `temporal.segment` | the fact: `valid_during` (`[)` bounded below), `belief`, `temporal_basis`, `status`, `amount`, `currency`, `unit`, `ref_entity_id`, `payload`, `extent_id`, `primary_claim_id`, `replaces_segment_id`, `specification_id`, `k_from`, `k_to` | `exclude using gist (stream_id =, valid_during &&) where k_to is null`; stamped by `stamp_k`; `guard_k` allows only closure |
| `temporal.event` / `event_occurrence` | identity + k-stamped occurrences (`actual|scheduled|cancelled`) | one current occurrence per event |
| `temporal.extent` | source text for a date with `precision` (`instant|day|month|quarter|year|relative|unknown`) and `earliest/latest` | — |
| `temporal.stream_kind` / `event_kind` | vocabulary with slot rules (`status_values`, `requires_amount`, `unit_values`, `requires_ref_entity`, `payload_schema`) | enforced at `commit_batch` |

## Read paths

- `q:entity.at` → `api.entity_at(entity, at, k)` — facts true at world time `at` as known at `k`.
- `q:facts.current_by_stream` → `api.current_facts` filtered by `stream_kind`, `subject_entity_id`.
- `q:entity.timeline` → `api.entity_timeline(entity, from, to, k)` — segments, events, and `unknown` gaps.
- `q:entity.what_changed` → `api.what_changed(entity, k1, k2)` — opened/closed items between two heads.
- `q:knowledge.head` → current `knowledge_seq` (record it in every snapshot).

## Write path (executor only)

```
begin; set local app.tenant_id = '<tenant>';
select temporal.begin_batch(p_expected_head => <knowledge_seq from your snapshot>);   -- 40001 rebase_required on mismatch
select temporal.make_extent('March 2026','month', <locator>, '2026-03-01', '2026-03-31');
select temporal.assert_state(<entity>, 'model_offering_price', tstzrange('2026-03-01', null, '[)'),
        p_amount => 2.50, p_currency => 'USD', p_unit => 'per_1m_input_tokens', p_claim => <claim>, p_extent => <extent>);
select temporal.commit_batch(<receipt_id>, <idempotency_key>, <sha256 of intent>, '{}');
commit;
```

You do not run this. `knowledge-ingest submit` runs it as `executor_service` from your
intent file. The helper behaviours you must know:

- identical current segment → **no-op**, existing id returned;
- overlapping current segment → old one closed (`k_to = k`), unaffected fragments re-inserted with
  `replaces_segment_id`, new segment inserted;
- two overlapping assertions in one batch → error `overlapping assertions in one batch`; consolidate;
- `commit_batch` validates slot rules; `model_offering_price` requires `currency ~ '^[A-Z]{3}$'`
  and `unit ∈ unit_values`.

## Pitfalls

- `api.current_facts` hides facts whose `valid_during` does not contain `now()`; use `entity.at` for
  history and `entity.timeline` for gaps.
- `temporal_basis='explicit'` requires an `extent_id`; use `observation_bounded` when the source only
  proves "true at capture time".
- `belief='disputed'` does not replace an `accepted` current segment; it lands as `review_required`
  in the executor plan.

## See also

`domains/relationships.md` (temporal relationship kinds get a `relationship_active` stream),
`vocabularies/temporal.stream_kind.md`, `tasks/compose-ingestion-intent.md`.
```

---

## 4. L2 sample: `schemas/temporal/README.md` (excerpt)

```markdown
---
id: sch:temporal
kind: schema
domain: temporal-facts
relations: 9
functions: 14
workspace_fingerprint: sha256:3f9c…
---

# temporal

| Relation | Kind | Rows | Summary | Key edges |
|---|---|---|---|---|
| [`knowledge_head`](../../relations/temporal/knowledge_head.md) | table | per tenant | tenant knowledge clock; open-batch marker | — |
| [`knowledge_batch`](../../relations/temporal/knowledge_batch.md) | table | unknown | sealed batch ledger | → `orchestration.operation_receipt`, → `knowledge_service.operation` |
| [`extent`](../../relations/temporal/extent.md) | table | unknown | dated source text with precision | → `evidence.locator` |
| [`stream`](../../relations/temporal/stream.md) | table | unknown | `(kind, subject, scope_key)` fact series | → `stream_kind`, → `corpus.entity` \| `corpus.relationship` (poly) |
| [`segment`](../../relations/temporal/segment.md) | table | unknown | a fact with two clocks | → `stream`, → `extent`, → `temporal.event`, → `evidence.claim`, → `corpus.ai_model_version_spec` |
| … | | | | |

Functions: [`begin_batch`](../../functions/temporal/begin_batch.md), [`assert_state`](../../functions/temporal/assert_state.md), … (14)
Types: none. Vocabularies: [`stream_kind`](../../vocabularies/temporal.stream_kind.md), [`event_kind`](../../vocabularies/temporal.event_kind.md).
```

`Rows` is a class (`none | small | medium | large | unknown`) from `pg_class.reltuples` when statistics exist; `unknown` otherwise. It is excluded from the fingerprint.

---

## 5. L3 sample: `relations/temporal/segment.md`

```markdown
---
id: rel:temporal.segment
kind: table
schema: temporal
name: segment
domain: temporal-facts
aliases: [fact, temporal fact, state segment, interval fact]
tokens: [temporal, segment, temporal.segment, stream_id, valid_during, belief, temporal_basis, status, amount, currency, unit, ref_entity_id, payload, extent_id, caused_by_event_id, replaces_segment_id, primary_claim_id, k_from, k_to, specification_id]
summary: "A fact on a stream: world interval valid_during, knowledge interval [k_from,k_to)."   # curated
rls: enabled
readers: [executor_service, pipeline_agent, verifier_agent, control_plane]
writers: []            # no direct DML for any role; see Write path
typescript: 'Database["temporal"]["Tables"]["segment"]["Row"]'
defined_in: [20260912010400_km_04_temporal.sql]
workspace_fingerprint: sha256:3f9c…
---

# temporal.segment

> curated (human, 2026-09-11) — One row per assertion of a fact over a world-time interval.
> Current facts have `k_to is null`. Amount-bearing streams put the value in `amount`/`unit`
> (and `currency` for monetary streams); status streams use `status`; free-form slots use `payload`
> validated against `stream_kind.payload_schema`.

## Columns

| # | Column | Type | Null | Default | Notes |
|---|---|---|---|---|---|
| 1 | `id` | uuid | no | `util.uuidv7()` | PK |
| 2 | `tenant_id` | uuid | no | `util.current_tenant_id()` | RLS key; `unique (tenant_id, id)` |
| 3 | `stream_id` | uuid | no | | FK → [`temporal.stream`](stream.md)`.id`; also `(tenant_id, stream_id)` deferrable |
| 4 | `valid_during` | tstzrange | no | | check: not empty, `[)`, bounded below |
| 5 | `belief` | text | no | `'accepted'` | check: `accepted \| disputed \| unknown` |
| 6 | `temporal_basis` | text | no | | check: `explicit \| carry_forward \| observation_bounded \| unresolved`; `explicit`/`carry_forward` require `extent_id` |
| 7 | `status` | text | yes | | must be in `stream_kind.status_values` when defined (commit-time) |
| 8 | `amount` | numeric(20,6) | yes | | required when `stream_kind.requires_amount` |
| 9 | `currency` | char(3) | yes | | required `^[A-Z]{3}$` for `model_offering_price`, `compute_offering_price`, `valuation` |
| 10 | `unit` | text | yes | | must be in `stream_kind.unit_values` when defined |
| 11 | `ref_entity_id` | uuid | yes | | FK → [`corpus.entity`](../corpus/entity.md); required when `stream_kind.requires_ref_entity` |
| 12 | `payload` | jsonb | no | `'{}'` | validated by `pg_jsonschema` against `stream_kind.payload_schema` at commit |
| 13 | `extent_id` | uuid | yes | | FK → [`temporal.extent`](extent.md) |
| 14 | `caused_by_event_id` | uuid | yes | | FK → [`temporal.event`](event.md) |
| 15 | `replaces_segment_id` | uuid | yes | | FK → `temporal.segment`; set by `assert_state` on split/replace; `<> id` |
| 16 | `primary_claim_id` | uuid | yes | | FK → [`evidence.claim`](../evidence/claim.md) |
| 17 | `k_from` | bigint | no | | stamped from the open batch by `stamp_k` |
| 18 | `k_to` | bigint | yes | | closure only, by `close_segment`/`assert_state` in an open batch |
| 19 | `created_at` | timestamptz | no | `now()` | |
| 20 | `specification_id` | uuid | yes | | FK → [`corpus.ai_model_version_spec`](../corpus/ai_model_version_spec.md); required for `model_version_spec` stream |

## Constraints

- PK `(id)`; unique `(tenant_id, id)`.
- Check `k_to is null or k_to > k_from`; check `replaces_segment_id is null or replaces_segment_id <> id`.
- Check `temporal_basis in ('observation_bounded','unresolved') or extent_id is not null`.
- **Exclusion** `using gist (stream_id with =, valid_during with &&) where (k_to is null)` — no two current segments on one stream may overlap.

## Relationships

Outbound: `stream_id → temporal.stream`, `ref_entity_id → corpus.entity`, `extent_id → temporal.extent`, `caused_by_event_id → temporal.event`, `replaces_segment_id → temporal.segment`, `primary_claim_id → evidence.claim`, `specification_id → corpus.ai_model_version_spec` (all also tenant-scoped, deferrable).
Inbound: `evidence.segment_support.segment_id`, `temporal.segment.replaces_segment_id`.
Polymorphic (via `stream`): the subject is `corpus.entity` **or** `corpus.relationship` — basis: check constraint `num_nonnulls(...) = 1` on `temporal.stream`.

## Indexes

`segment_stream_current_idx (stream_id) where k_to is null`; `segment_valid_gist gist(valid_during) where k_to is null`; exclusion index from the constraint above. Full definitions: [`segment.details.md`](segment.details.md).

## Triggers

`stamp_k` before insert → `temporal.stamp_k()` (requires an open tenant batch; sets `k_from`);
`guard_k` before update/delete → `temporal.guard_k()` (delete raises 23001; update allowed only to set `k_to` to the open batch);
`sealed_batch` constraint trigger, deferred → `temporal.require_sealed_batch()` (every `k_from`/`k_to` must be a sealed `knowledge_batch` at commit).

## Row-level security

Enabled. Policy `km_tenant_access` for `executor_service, pipeline_agent, verifier_agent, control_plane`: `using (tenant_id = util.current_tenant_id()) with check (same)`.

## Grants

| Role | Privileges |
|---|---|
| `executor_service` | SELECT |
| `pipeline_agent` | SELECT |
| `verifier_agent` | SELECT |
| `control_plane` | SELECT |
| `app_reader`, `authenticated`, `anon`, `service_role` | none on the table (`service_role` has no INSERT/UPDATE/DELETE either) |

## Read paths

- `q:facts.current_by_stream`, `q:facts.history_for_stream`, `q:entity.at`, `q:entity.timeline`, `q:entity.what_changed`.
- `api.current_facts` (view, `app_reader`) exposes current rows via `api.current_fact_rows()`.

## Write path

No direct DML for any role. Facts are asserted by `executor_service` through
[`temporal.assert_state`](../../functions/temporal/assert_state.md) inside an open batch
([`begin_batch`](../../functions/temporal/begin_batch.md) … [`commit_batch`](../../functions/temporal/commit_batch.md)).
Agents: use a `fact.assert_state` proposal in a `knowledge-ingestion-intent.v1`
(`tasks/compose-ingestion-intent.md`).

## Example

Ask "what was the input price of offering X in March 2026 as we knew it at head 41?":

```bash
knowledge-db query entity.at --param entity_id=<offering uuid> --param at=2026-03-15T00:00:00Z --param k=41
```

Result rows have `stream_kind='model_offering_price'`, `amount`, `currency`, `unit`, `valid_during`, `k_from`, `k_to`.
```

---

## 6. L3 sample: `functions/temporal/assert_state.md` (excerpt)

```markdown
---
id: fn:temporal.assert_state(uuid,text,tstzrange,text,text,numeric,text,text,uuid,jsonb,uuid,uuid,text,uuid,text,uuid)
kind: function
schema: temporal
name: assert_state
domain: temporal-facts
security: definer
volatility: volatile
executors: [executor_service]
touches: { reads: [temporal.stream_kind, corpus.entity, corpus.relationship, taxonomy.relationship_kind], writes: [temporal.stream, temporal.segment] }   # best_effort
raises: ["no open knowledge batch", "entity stream cannot target relationship", "stream does not admit entity kind", "relationship stream cannot target entity", "stream does not admit relationship kind", "overlapping assertions in one batch; consolidate before admission"]
workspace_fingerprint: sha256:3f9c…
---

# temporal.assert_state(…) → uuid

Asserts a fact on `(p_stream_kind, subject, p_scope_key)` over `p_valid_during`. Returns the segment id.

| Argument | Type | Default | Meaning |
|---|---|---|---|
| `p_entity` | uuid | — | subject entity (entity-mode streams) |
| `p_stream_kind` | text | — | `temporal.stream_kind.code` |
| `p_valid_during` | tstzrange | — | world interval `[)` |
| `p_scope_key` | text | `''` | distinguishes parallel series (e.g. region) |
| `p_status` | text | null | must be in `status_values` |
| `p_amount`, `p_currency`, `p_unit` | numeric, text, text | null | slot values |
| `p_ref_entity` | uuid | null | referenced entity when `requires_ref_entity` |
| `p_payload` | jsonb | `'{}'` | validated against `payload_schema` at commit |
| `p_extent` | uuid | null | required for `explicit`/`carry_forward` |
| `p_claim` | uuid | null | `primary_claim_id` |
| `p_temporal_basis` | text | `'explicit'` | |
| `p_relationship` | uuid | null | subject relationship (relationship-mode streams) |
| `p_belief` | text | `'accepted'` | |
| `p_specification` | uuid | null | for `model_version_spec` |

## Behaviour (mechanically extracted from the body)

1. Requires an open batch (`temporal.current_k()`), else raises.
2. Checks the subject kind against `stream_kind.subject_kinds`.
3. Creates the stream if absent (`on conflict do nothing`).
4. If an identical current segment exists → returns its id (**no-op**).
5. For each overlapping current segment: raises if it was asserted in this batch; otherwise closes it and
   re-inserts the non-overlapping fragments with `replaces_segment_id = old.id`.
6. Inserts the new segment with `replaces_segment_id` = the last replaced old segment (or null).

Grants: `EXECUTE` → `executor_service` only. Agents reach this through `fact.assert_state` proposals.
```

---

## 7. Task sample: `tasks/what-do-we-know-about-entity.md`

```markdown
---
id: task:what-do-we-know-about-entity
kind: task
domains: [identity, temporal-facts, relationships, evidence]
queries: [entity.resolve, entity.card, entity.at, entity.relationships, entity.timeline, evidence.claims_for_entity, knowledge.head]
provenance: human
reviewed: 2026-09-11
---

# What do we already know about <name>?

## Navigation
`domains/identity.md` → `queries/README.md` (entity.*)

## Operation

```json
{ "schemaVersion": "knowledge-read-intent.v1", "intentId": "openai-baseline",
  "operations": [
    { "opId": "resolve", "kind": "named_query", "query": "entity.resolve", "params": { "text": "OpenAI" } },
    { "opId": "card",    "kind": "named_query", "query": "entity.card",    "params": { "entity_id": "$resolve.rows[0].entity_id" } },
    { "opId": "rels",    "kind": "named_query", "query": "entity.relationships", "params": { "entity_id": "$resolve.rows[0].entity_id", "direction": "both" } },
    { "opId": "claims",  "kind": "named_query", "query": "evidence.claims_for_entity", "params": { "entity_id": "$resolve.rows[0].entity_id", "limit": 100 } },
    { "opId": "head",    "kind": "named_query", "query": "knowledge.head" } ] }
```

```bash
knowledge-db snapshot 05-read-intent.json --out 06-snapshot.json
```

## Expected shape
`resolve` rows: `entity_id, kind, display_name, score` (≤ 25, best first). If `score < 0.9` for every row, the entity probably does not exist: plan an `entity.create` proposal. `card` is one JSON object: `entity, aliases, facts[], relationships[], events[], sources[]`. `head.knowledge_seq` is the value you will put in `expectedKnowledgeHead`.

## Pitfalls
- `entity.card` shows **current** facts only. For "what did we believe on date D" use `entity.at` with `at=D`.
- Merged entities (`lifecycle='merged'`) are excluded by `resolve_entity`; follow `merged_into_id` if you hold an old id.
- Record `06-snapshot.json`'s `snapshotDigest` and `knowledgeHead.knowledge_seq` in `07-gaps.md`; the ingestion intent must cite both.
```

---

## 8. Vocabulary sample: `vocabularies/temporal.stream_kind.md` (excerpt)

```markdown
---
id: voc:temporal.stream_kind
kind: vocabulary
rows: 20
rows_sha256: "…"
---

# temporal.stream_kind

| code | subject_mode | subject_kinds | status_values | requires_amount | unit_values | payload_schema |
|---|---|---|---|---|---|---|
| `model_offering_price` | entity | model_offering | — | **yes** | per_1m_input_tokens, per_1m_output_tokens, per_1m_cached_input_tokens, per_hour, per_seat_month, per_request, per_image, per_minute_audio | `{}` |
| `model_offering_availability` | entity | model_offering | announced, preview, ga, deprecated, retired | no | — | `{}` |
| `model_offering_limit` | entity | model_offering | — | yes | context_tokens, max_output_tokens, rpm, tpm, batch_size | `{}` |
| `product_feature_availability` | entity | product_feature | announced, preview, ga, deprecated, removed | no | — | `{}` |
| `engagement_role` | relationship | employed_by | — | no | — | `{required:[title]}` |
| `organization_status` | entity | organization | operating, acquired, merged, dissolved, stealth | no | — | `{}` |
| … | | | | | | |

Currency rule (enforced at `commit_batch`): `model_offering_price`, `compute_offering_price`, `valuation` require `currency ~ '^[A-Z]{3}$'`.
```

---

## 9. Search index sample entries (`search/index.json`)

```json
[
  { "id": "rel:temporal.segment", "kind": "table", "qualified_name": "temporal.segment", "path": "relations/temporal/segment.md",
    "domain": "temporal-facts", "aliases": ["fact","temporal fact","state segment","interval fact"],
    "tokens": ["temporal","segment","stream_id","valid_during","belief","temporal_basis","status","amount","currency","unit","ref_entity_id","payload","extent_id","k_from","k_to"],
    "summary": "A fact on a stream: world interval valid_during, knowledge interval [k_from,k_to).", "summary_basis": "curated",
    "edges": [ { "to": "rel:temporal.stream", "via": "stream_id", "basis": "enforced" }, { "to": "rel:evidence.claim", "via": "primary_claim_id", "basis": "enforced" } ],
    "readers": ["executor_service","pipeline_agent","verifier_agent","control_plane"], "writers": [], "write_via": ["fn:temporal.assert_state"] },
  { "id": "q:entity.at", "kind": "query", "path": "queries/README.md#entityat", "domain": "temporal-facts",
    "aliases": ["as of","point in time","historical facts","replay"], "role": "app_reader",
    "summary": "Facts true at world time `at` as known at knowledge seq `k` for one entity." },
  { "id": "task:find-stale-facts", "kind": "task", "path": "tasks/find-stale-facts.md",
    "aliases": ["stale","outdated","needs revisit","last seen"], "domain": "temporal-facts" },
  { "id": "term:knowledge-head", "kind": "term", "path": "search/terminology.json#knowledge-head",
    "aliases": ["head","knowledge_seq","K"], "summary": "Per-tenant monotonic sequence of sealed knowledge batches; every snapshot and intent cites it." }
]
```

---

## 10. `manifest.json` (full workspace)

```json
{
  "format": "ai-engineer-schema-workspace/3",
  "build": { "contract_version": "0.3.0", "migration_head": "20260912011200", "renderer_version": "3.0.0",
             "fingerprint": "sha256:…", "workspace_fingerprint": "sha256:…",
             "generated_types_sha256": "sha256:…", "enrichment_sha256": "sha256:…",
             "volatile": { "introspected_at": "2026-09-1xT..Z", "source": { "kind": "local_disposable" } } },
  "scope": null,
  "layers": {
    "domains": 18, "schemas": 19, "relations": 331, "relation_details": 24, "functions": 61, "types": 9,
    "vocabularies": 12, "tasks": 14, "queries": 27 },
  "sizes": { "total_bytes": 0, "largest": { "path": "relations/orchestration/operation_receipt.details.md", "bytes": 0 } },
  "budgets": { "relation_main_bytes": 6144, "relation_details_bytes": 16384, "domain_bytes": 8192, "task_bytes": 5120, "search_index_bytes": 256000 },
  "entry_points": ["START_HERE.md", "INDEX.md", "relations.txt", "queries/README.md"]
}
```

Counts above are placeholders to be filled by the build; `layers.relations` is expected around 330 (SCHEMA-SUMMARY totals excluding vector partitions).

---

## 11. Scoped materialization sample

`workspace-scopes/db-aware-research.json` (in the spec §4.11). Resulting differences:

- `START_HERE.md` gains: *"This bundle (`db-aware-research`, digest `…`) omits 112 relations you were not expected to need. Omission is not access control; the executor and the database roles decide what you may do. The complete workspace is available to operators at fingerprint `…`."*
- `relations/orchestration/attempt.stub.md`:

```markdown
---
id: rel:orchestration.attempt
kind: table
stub: true
scope: db-aware-research
---
# orchestration.attempt (stub)

Out of scope for this bundle. Referenced by in-scope relations: `evidence.source_query.attempt_id`,
`evidence.extraction_run.attempt_id`, `evidence.source_capture.produced_by_attempt_id`,
`orchestration.operation_intent.proposed_by_attempt`. Columns referenced: `id`.
Full page in the complete workspace (fingerprint `sha256:3f9c…`).
```

- `manifest.json.scope`: `{ "id": "db-aware-research", "scope_sha256": "…", "included": { "relations": 219, "functions": 38 }, "omitted": { "relations": 112, "functions": 23, "list_path": "scope.json" }, "stubs": 17 }`.
- `search/index.json` entries for stubs carry `"stub": true`; tasks and queries outside the scope's `tasks`/`queries` lists are omitted.
