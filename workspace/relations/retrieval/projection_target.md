---
id: "rel:retrieval.projection_target"
kind: table
schema: retrieval
name: projection_target
domain: retrieval
aliases: [projection target]
tokens: [retrieval, projection_target, retrieval.projection_target, id, tenant_id, target_kind, entity_id, record_id, chunk_id, claim_id, summary_id, admitted_at, retired_at]
summary: "Five-way target a search projection may point at (entity, record, chunk, claim, summary)."
summary_basis: curated
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, pipeline_agent, service_role]
typescript: "Database[\"retrieval\"][\"Tables\"][\"projection_target\"][\"Row\"]"
defined_in: ["20260903010100_knowledge_retrieval_contract.sql", "20260912010800_km_08_retrieval.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# retrieval.projection_target

table in domain `retrieval`.

> curated (model_assisted, unreviewed) — Five-way target a search projection may point at (entity, record, chunk, claim, summary).

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | unique (tenant_id, id); unique (tenant_id, target_kind, entity_id, record_id, chunk_id, claim_id, summary_id) |
| 3 | `target_kind` | `text` | no | — | unique (tenant_id, target_kind, entity_id, record_id, chunk_id, claim_id, summary_id); _curated:_ Which of entity_id, record_id, chunk_id, claim_id, summary_id is set. |
| 4 | `entity_id` | `uuid` | yes | — | unique (tenant_id, target_kind, entity_id, record_id, chunk_id, claim_id, summary_id); FK → [`corpus.entity`](../corpus/entity.md).id; _curated:_ Set when the projection is an entity profile. |
| 5 | `record_id` | `uuid` | yes | — | unique (tenant_id, target_kind, entity_id, record_id, chunk_id, claim_id, summary_id); FK → [`knowledge.record`](../knowledge/record.md).id |
| 6 | `chunk_id` | `uuid` | yes | — | unique (tenant_id, target_kind, entity_id, record_id, chunk_id, claim_id, summary_id); FK → [`retrieval.retrieval_chunk`](retrieval_chunk.md).id |
| 7 | `claim_id` | `uuid` | yes | — | unique (tenant_id, target_kind, entity_id, record_id, chunk_id, claim_id, summary_id); FK → [`evidence.claim`](../evidence/claim.md).id |
| 8 | `summary_id` | `uuid` | yes | — | unique (tenant_id, target_kind, entity_id, record_id, chunk_id, claim_id, summary_id); FK → [`content.document_summary`](../content/document_summary.md).id |
| 9 | `admitted_at` | `timestamp with time zone` | no | `now()` | — |
| 10 | `retired_at` | `timestamp with time zone` | yes | — | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- unique (tenant_id, target_kind, entity_id, record_id, chunk_id, claim_id, summary_id)
- check `projection_target_check`: `(num_nonnulls(entity_id, record_id, chunk_id, claim_id, summary_id) = 1)`
- check `projection_target_check1`: `(((target_kind = 'entity'::text) AND (entity_id IS NOT NULL)) OR ((target_kind = 'record'::text) AND (record_id IS NOT NULL)) OR ((target_k…`
- check `projection_target_target_kind_check`: `(target_kind = ANY (ARRAY['entity'::text, 'record'::text, 'chunk'::text, 'claim'::text, 'summary'::text]))`

## Relationships

Outbound: `chunk_id` → [`retrieval.retrieval_chunk`](retrieval_chunk.md)`.id` (+tenant); `claim_id` → [`evidence.claim`](../evidence/claim.md)`.id` (+tenant); `entity_id` → [`corpus.entity`](../corpus/entity.md)`.id` (+tenant); `record_id` → [`knowledge.record`](../knowledge/record.md)`.id` (+tenant); `summary_id` → [`content.document_summary`](../content/document_summary.md)`.id` (+tenant).
Inbound: [`evaluation.eval_case_relevance`](../evaluation/eval_case_relevance.md).projection_target_id, [`retrieval.search_projection`](search_projection.md).projection_target_id, [`retrieval.vector_item`](vector_item.md).projection_target_id.
Polymorphic: exactly one of `entity_id`, `record_id`, `chunk_id`, `claim_id`, `summary_id` → [`content.document_summary`](../content/document_summary.md) | [`corpus.entity`](../corpus/entity.md) | [`evidence.claim`](../evidence/claim.md) | [`knowledge.record`](../knowledge/record.md) | [`retrieval.retrieval_chunk`](retrieval_chunk.md) — basis: check constraint projection_target_check.

## Indexes

`projection_target_tenant_id_id_key` unique; `projection_target_tenant_id_target_kind_entity_id_record_id_key` unique

## Triggers

_None._

## Row-level security

Enabled.
- `km_tenant_access` (ALL) for `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`control_plane`: SELECT; `executor_service`: INSERT, SELECT, UPDATE; `pipeline_agent`: INSERT, SELECT, UPDATE; `service_role`: INSERT, SELECT, UPDATE; `verifier_agent`: SELECT. None: `anon`, `app_reader`, `authenticated`.

## Read paths

- Direct SELECT: `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- Direct DML: `executor_service`, `pipeline_agent`.
- Via functions (best effort): [`retrieval.project_entity_timeline`](../../functions/retrieval/project_entity_timeline.md).

## TypeScript

insert: `Database["retrieval"]["Tables"]["projection_target"]["Insert"]`; row: `Database["retrieval"]["Tables"]["projection_target"]["Row"]`; update: `Database["retrieval"]["Tables"]["projection_target"]["Update"]`

## Examples

Hybrid search ranks items that point at targets

```bash
knowledge db query retrieval.hybrid_search --param filters={} --param limit=20 --param query_text=OpenAI API pricing 2026 --param vector_space_version_id=0192b100-0000-7000-8000-000000000001
```
Follow search_projection.projection_target_id to this row.

Defined in: `20260903010100_knowledge_retrieval_contract.sql`, `20260912010800_km_08_retrieval.sql`.
