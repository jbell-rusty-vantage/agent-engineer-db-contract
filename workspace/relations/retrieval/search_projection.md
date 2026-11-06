---
id: "rel:retrieval.search_projection"
kind: table
schema: retrieval
name: search_projection
domain: retrieval
aliases: [projection]
tokens: [retrieval, search_projection, retrieval.search_projection, id, tenant_id, projection_target_id, projection_procedure_id, purpose, source_text, contextual_prefix, embedding_text, source_text_sha256, contextual_prefix_sha256, embedding_text_sha256, support_manifest, language, content_kind, visibility, classification, effective_during, promotion_state, generator_identity, prompt_schema_version, representation_decision_id, content_promotion_decision_id, created_at]
summary: Derived text projection that a vector item may point at.
summary_basis: curated
rls: enabled
readers: []
writers: []
typescript: "Database[\"retrieval\"][\"Tables\"][\"search_projection\"][\"Row\"]"
defined_in: ["20260903010100_knowledge_retrieval_contract.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# retrieval.search_projection

table in domain `retrieval`.

> curated (model_assisted, unreviewed) — Derived text projection that a vector item may point at.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | unique (tenant_id, id); unique (tenant_id, projection_target_id, projection_procedure_id, purpose, embedding_text_sha256) |
| 3 | `projection_target_id` | `uuid` | no | — | unique (tenant_id, projection_target_id, projection_procedure_id, purpose, embedding_text_sha256); _curated:_ Five-way target (entity, document, record, …). |
| 4 | `projection_procedure_id` | `uuid` | no | — | unique (tenant_id, projection_target_id, projection_procedure_id, purpose, embedding_text_sha256); FK → [`retrieval.projection_procedure`](projection_procedure.md).id |
| 5 | `purpose` | `text` | no | — | unique (tenant_id, projection_target_id, projection_procedure_id, purpose, embedding_text_sha256) |
| 6 | `source_text` | `text` | no | — | — |
| 7 | `contextual_prefix` | `text` | no | `''::text` | — |
| 8 | `embedding_text` | `text` | no | — | — |
| 9 | `source_text_sha256` | `text` | no | — | — |
| 10 | `contextual_prefix_sha256` | `text` | no | — | — |
| 11 | `embedding_text_sha256` | `text` | no | — | unique (tenant_id, projection_target_id, projection_procedure_id, purpose, embedding_text_sha256) |
| 12 | `support_manifest` | `jsonb` | no | `'[]'::jsonb` | — |
| 13 | `language` | `text` | yes | — | — |
| 14 | `content_kind` | `text` | no | — | — |
| 15 | `visibility` | `text` | no | — | — |
| 16 | `classification` | `text` | no | — | — |
| 17 | `effective_during` | `tstzrange` | yes | — | — |
| 18 | `promotion_state` | `text` | no | `'candidate'::text` | — |
| 19 | `generator_identity` | `text` | yes | — | — |
| 20 | `prompt_schema_version` | `text` | yes | — | — |
| 21 | `representation_decision_id` | `uuid` | yes | — | — |
| 22 | `content_promotion_decision_id` | `uuid` | yes | — | — |
| 23 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- unique (tenant_id, projection_target_id, projection_procedure_id, purpose, embedding_text_sha256)
- check `search_projection_contextual_prefix_sha256_check`: `(contextual_prefix_sha256 ~ '^[0-9a-f]{64}$'::text)`
- check `search_projection_embedding_text_sha256_check`: `(embedding_text_sha256 ~ '^[0-9a-f]{64}$'::text)`
- check `search_projection_source_text_sha256_check`: `(source_text_sha256 ~ '^[0-9a-f]{64}$'::text)`

## Relationships

Outbound: `projection_procedure_id` → [`retrieval.projection_procedure`](projection_procedure.md)`.id` on delete restrict; `tenant_id,content_promotion_decision_id` → [`retrieval.content_promotion_decision`](content_promotion_decision.md)`.tenant_id,id` on delete restrict; `tenant_id,projection_target_id` → [`retrieval.projection_target`](projection_target.md)`.tenant_id,id` on delete restrict; `tenant_id,representation_decision_id` → [`content.representation_decision`](../content/representation_decision.md)`.tenant_id,id` on delete restrict.
Inbound: [`retrieval.embedding_item`](embedding_item.md).search_projection_id, [`retrieval.packet_member`](packet_member.md).search_projection_id, [`retrieval.retrieval_candidate_source`](retrieval_candidate_source.md).search_projection_id, [`retrieval.search_projection_chunk_support`](search_projection_chunk_support.md).search_projection_id, [`retrieval.vector_item`](vector_item.md).search_projection_id.

## Indexes

`search_projection_target_idx`; `search_projection_tenant_id_id_key` unique; `search_projection_tenant_id_projection_target_id_projection_key` unique

## Triggers

- `search_projection_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md)

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

No role has privileges. None: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

## Read paths

- No agent role may SELECT directly.

## Write path

- No direct DML for any agent role.
- Via functions (best effort): [`retrieval.project_entity_timeline`](../../functions/retrieval/project_entity_timeline.md).

## TypeScript

insert: `Database["retrieval"]["Tables"]["search_projection"]["Insert"]`; row: `Database["retrieval"]["Tables"]["search_projection"]["Row"]`; update: `Database["retrieval"]["Tables"]["search_projection"]["Update"]`

## Examples

Packet members cite projections

```bash
knowledge db query retrieval.evidence_packet --param packet_id=0192c000-0000-7000-8000-000000000001
```
Members may include search_projection_id.

Defined in: `20260903010100_knowledge_retrieval_contract.sql`.
