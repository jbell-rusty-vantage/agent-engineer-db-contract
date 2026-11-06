---
id: "rel:retrieval.space_publication"
kind: table
schema: retrieval
name: space_publication
domain: retrieval
aliases: [publication]
tokens: [retrieval, space_publication, retrieval.space_publication, id, tenant_id, vector_store_space_id, vector_space_version_id, vector_item_manifest_sha256, embedding_manifest_sha256, index_manifest_sha256, evaluation_result_id, publication_decision_id, predecessor_id, status, expected_item_count, published_at, created_at, operation_id, legacy_provenance]
summary: Published vector-space version that hybrid search may read.
summary_basis: curated
rls: enabled
readers: []
writers: []
typescript: "Database[\"retrieval\"][\"Tables\"][\"space_publication\"][\"Row\"]"
defined_in: ["20260903010100_knowledge_retrieval_contract.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# retrieval.space_publication

table in domain `retrieval`.

> curated (model_assisted, unreviewed) — Published vector-space version that hybrid search may read.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | unique (tenant_id, id) |
| 3 | `vector_store_space_id` | `uuid` | no | — | — |
| 4 | `vector_space_version_id` | `uuid` | no | — | — |
| 5 | `vector_item_manifest_sha256` | `text` | no | — | — |
| 6 | `embedding_manifest_sha256` | `text` | no | — | — |
| 7 | `index_manifest_sha256` | `text` | no | — | — |
| 8 | `evaluation_result_id` | `uuid` | yes | — | — |
| 9 | `publication_decision_id` | `uuid` | no | — | — |
| 10 | `predecessor_id` | `uuid` | yes | — | — |
| 11 | `status` | `text` | no | `'draft'::text` | _curated:_ Must be published for hybrid search. |
| 12 | `expected_item_count` | `bigint` | no | — | — |
| 13 | `published_at` | `timestamp with time zone` | yes | — | — |
| 14 | `created_at` | `timestamp with time zone` | no | `now()` | — |
| 15 | `operation_id` | `uuid` | yes | — | — |
| 16 | `legacy_provenance` | `boolean` | no | `false` | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- check `space_publication_check`: `((predecessor_id IS NULL) OR (predecessor_id <> id))`
- check `space_publication_embedding_manifest_sha256_check`: `(embedding_manifest_sha256 ~ '^[0-9a-f]{64}$'::text)`
- check `space_publication_expected_item_count_check`: `(expected_item_count >= 0)`
- check `space_publication_index_manifest_sha256_check`: `(index_manifest_sha256 ~ '^[0-9a-f]{64}$'::text)`
- check `space_publication_provenance_required_ck`: `(legacy_provenance OR (operation_id IS NOT NULL))`
- check `space_publication_published_timestamp_ck`: `((status = ANY (ARRAY['published'::text, 'superseded'::text, 'withdrawn'::text])) = (published_at IS NOT NULL))`
- check `space_publication_status_check`: `(status = ANY (ARRAY['draft'::text, 'evaluated'::text, 'approved'::text, 'publishing'::text, 'published'::text, 'superseded'::text, 'withdr…`
- check `space_publication_vector_item_manifest_sha256_check`: `(vector_item_manifest_sha256 ~ '^[0-9a-f]{64}$'::text)`

## Relationships

Outbound: `tenant_id,evaluation_result_id` → [`evaluation.promotion_gate_result`](../evaluation/promotion_gate_result.md)`.tenant_id,id` on delete restrict; `tenant_id,operation_id` → [`knowledge_service.operation`](../knowledge_service/operation.md)`.tenant_id,id` on delete restrict; `tenant_id,predecessor_id` → [`retrieval.space_publication`](space_publication.md)`.tenant_id,id` on delete restrict; `tenant_id,publication_decision_id` → [`retrieval.content_promotion_decision`](content_promotion_decision.md)`.tenant_id,id` on delete restrict; `tenant_id,vector_space_version_id` → [`retrieval.vector_space_version`](vector_space_version.md)`.tenant_id,id` on delete restrict; `tenant_id,vector_store_space_id` → [`retrieval.vector_store_space`](vector_store_space.md)`.tenant_id,id` on delete restrict.
Inbound: [`retrieval.publication_switch_receipt`](publication_switch_receipt.md).from_publication_id|to_publication_id, [`retrieval.space_publication`](space_publication.md).predecessor_id.

## Indexes

`publication_current_idx` where `(status = 'published'::text)`; `space_publication_tenant_id_id_key` unique

## Triggers

- `predecessor_direction` → [`util.validate_predecessor`](../../functions/util/validate_predecessor.md)
- `space_publication_guard` → [`retrieval.guard_space_publication`](../../functions/retrieval/guard_space_publication.md)
- `space_publication_no_new_legacy` → [`retrieval.reject_new_legacy_governance_provenance`](../../functions/retrieval/reject_new_legacy_governance_provenance.md)

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

No role has privileges. None: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

## Read paths

- Named queries: `q:retrieval.hybrid_search`.
- No agent role may SELECT directly.

## Write path

- No direct DML for any agent role.
- Via functions (best effort): [`retrieval.publish_vector_space`](../../functions/retrieval/publish_vector_space.md), [`retrieval.rollback_vector_space`](../../functions/retrieval/rollback_vector_space.md).

## TypeScript

insert: `Database["retrieval"]["Tables"]["space_publication"]["Insert"]`; row: `Database["retrieval"]["Tables"]["space_publication"]["Row"]`; update: `Database["retrieval"]["Tables"]["space_publication"]["Update"]`

## Examples

Search a published version

```bash
knowledge db query retrieval.hybrid_search --param filters={} --param limit=20 --param query_text=OpenAI API pricing 2026 --param vector_space_version_id=0192b100-0000-7000-8000-000000000001
```
Unpublished versions raise insufficient_privilege.

Defined in: `20260903010100_knowledge_retrieval_contract.sql`.
