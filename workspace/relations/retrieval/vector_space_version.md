---
id: "rel:retrieval.vector_space_version"
kind: table
schema: retrieval
name: vector_space_version
domain: retrieval
aliases: [space version]
tokens: [retrieval, vector_space_version, retrieval.vector_space_version, id, vector_space_id, version, embedding_model, dims, projection_procedure_id, backend, promotion_gate_eval_id, promoted, created_at, tenant_id, precision, distance_operator, normalization, index_configuration, provider_routing_policy, publication_lifecycle, publication_decision_id]
summary: "Immutable version of a vector space, including dims and publication lifecycle."
summary_basis: curated
rls: enabled
readers: [executor_service, service_role]
writers: [executor_service, service_role]
typescript: "Database[\"retrieval\"][\"Tables\"][\"vector_space_version\"][\"Row\"]"
defined_in: ["20260826001000_retrieval.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# retrieval.vector_space_version

table in domain `retrieval`.

> curated (model_assisted, unreviewed) — Immutable version of a vector space, including dims and publication lifecycle.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `vector_space_id` | `uuid` | no | — | unique (vector_space_id, version); FK → [`retrieval.vector_space`](vector_space.md).id |
| 3 | `version` | `integer` | no | — | unique (vector_space_id, version) |
| 4 | `embedding_model` | `text` | no | — | — |
| 5 | `dims` | `integer` | no | — | _curated:_ Embedding width; hybrid_knowledge_search_1536 requires 1536. |
| 6 | `projection_procedure_id` | `uuid` | yes | — | FK → [`retrieval.projection_procedure`](projection_procedure.md).id |
| 7 | `backend` | `retrieval.backend_kind` | no | — | — |
| 8 | `promotion_gate_eval_id` | `uuid` | yes | — | FK → [`evaluation.eval_run`](../evaluation/eval_run.md).id |
| 9 | `promoted` | `boolean` | no | `false` | — |
| 10 | `created_at` | `timestamp with time zone` | no | `now()` | — |
| 11 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | unique (tenant_id, id) |
| 12 | `precision` | `text` | no | `'halfvec'::text` | — |
| 13 | `distance_operator` | `text` | no | `'cosine'::text` | — |
| 14 | `normalization` | `text` | no | `'none'::text` | — |
| 15 | `index_configuration` | `jsonb` | no | `'{}'::jsonb` | — |
| 16 | `provider_routing_policy` | `jsonb` | no | `'{}'::jsonb` | — |
| 17 | `publication_lifecycle` | `text` | no | `'draft'::text` | _curated:_ Publication state of this version, distinct from space_publication.status. |
| 18 | `publication_decision_id` | `uuid` | yes | — | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- unique (vector_space_id, version)
- check `vector_space_version_dims_check`: `(dims > 0)`
- check `vector_space_version_distance_operator_check`: `(distance_operator = ANY (ARRAY['cosine'::text, 'inner_product'::text, 'l2'::text]))`
- check `vector_space_version_precision_check`: `("precision" = ANY (ARRAY['halfvec'::text, 'vector'::text]))`
- check `vector_space_version_publication_lifecycle_check`: `(publication_lifecycle = ANY (ARRAY['draft'::text, 'evaluated'::text, 'approved'::text, 'publishing'::text, 'published'::text, 'superseded'…`

## Relationships

Outbound: `projection_procedure_id` → [`retrieval.projection_procedure`](projection_procedure.md)`.id`; `promotion_gate_eval_id` → [`evaluation.eval_run`](../evaluation/eval_run.md)`.id`; `vector_space_id` → [`retrieval.vector_space`](vector_space.md)`.id` (+tenant) on delete cascade.
Inbound: [`evaluation.eval_run`](../evaluation/eval_run.md).space_version_id, [`evaluation.regression_baseline`](../evaluation/regression_baseline.md).vector_space_version_id, [`evaluation.review_task`](../evaluation/review_task.md).vector_space_version_id, [`retrieval.embedding_run`](embedding_run.md).vector_space_version_id, [`retrieval.space_publication`](space_publication.md).vector_space_version_id, [`retrieval.vector_item`](vector_item.md).space_version_id, [`retrieval.vector_item_embedding_1536`](vector_item_embedding_1536.md).vector_space_version_id, [`retrieval.vector_store_space`](vector_store_space.md).active_space_version_id.
Polymorphic target of: [`evaluation.eval_run`](../evaluation/eval_run.md) (check constraint eval_run_exactly_one_target), [`evaluation.review_task`](../evaluation/review_task.md) (check constraint review_task_exactly_one_subject).

## Indexes

`vector_space_version_tenant_id_uq` unique; `vector_space_version_vector_space_id_version_key` unique

## Triggers

_None._

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`executor_service`: INSERT, SELECT, UPDATE; `service_role`: INSERT, SELECT, UPDATE. None: `anon`, `app_reader`, `authenticated`, `control_plane`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Named queries: `q:retrieval.hybrid_search`.
- Direct SELECT: `executor_service`.

## Write path

- Direct DML: `executor_service`.
- Via functions (best effort): [`retrieval.publish_vector_space`](../../functions/retrieval/publish_vector_space.md), [`retrieval.rollback_vector_space`](../../functions/retrieval/rollback_vector_space.md).

## TypeScript

insert: `Database["retrieval"]["Tables"]["vector_space_version"]["Insert"]`; row: `Database["retrieval"]["Tables"]["vector_space_version"]["Row"]`; update: `Database["retrieval"]["Tables"]["vector_space_version"]["Update"]`

## Examples

Search a version id

```bash
knowledge db query retrieval.hybrid_search --param filters={} --param limit=20 --param query_text=OpenAI API pricing 2026 --param vector_space_version_id=0192b100-0000-7000-8000-000000000001
```
Pass this table's id, not vector_space.id.

Defined in: `20260826001000_retrieval.sql`.
