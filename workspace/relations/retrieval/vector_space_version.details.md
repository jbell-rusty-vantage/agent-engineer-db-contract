---
id: "rel:retrieval.vector_space_version#details"
kind: details
schema: retrieval
name: vector_space_version
of: "rel:retrieval.vector_space_version"
workspace_fingerprint: "sha256:4ca964568389f6bca66099cb3a109cf6e895892ead47d26c6c89b292b0e91e75"
---
# retrieval.vector_space_version — details

Spill-over from [the main page](vector_space_version.md).

## Relationships

Outbound: `projection_procedure_id` → [`retrieval.projection_procedure`](projection_procedure.md)`.id`; `promotion_gate_eval_id` → [`evaluation.eval_run`](../evaluation/eval_run.md)`.id`; `vector_space_id` → [`retrieval.vector_space`](vector_space.md)`.id` (+tenant) on delete cascade.
Inbound: [`evaluation.eval_run`](../evaluation/eval_run.md).space_version_id, [`evaluation.regression_baseline`](../evaluation/regression_baseline.md).vector_space_version_id, [`evaluation.review_task`](../evaluation/review_task.md).vector_space_version_id, [`retrieval.embedding_run`](embedding_run.md).vector_space_version_id, [`retrieval.space_publication`](space_publication.md).vector_space_version_id, [`retrieval.vector_item`](vector_item.md).space_version_id, [`retrieval.vector_item_embedding_1536`](vector_item_embedding_1536.md).vector_space_version_id, [`retrieval.vector_store_space`](vector_store_space.md).active_space_version_id.
Polymorphic target of: [`evaluation.eval_run`](../evaluation/eval_run.md) (check constraint eval_run_exactly_one_target), [`evaluation.review_task`](../evaluation/review_task.md) (check constraint review_task_exactly_one_subject).

## Indexes

| Index | Definition |
| --- | --- |
| `vector_space_version_tenant_id_uq` | `CREATE UNIQUE INDEX vector_space_version_tenant_id_uq ON retrieval.vector_space_version USING btree (tenant_id, id)` |
| `vector_space_version_vector_space_id_version_key` | `CREATE UNIQUE INDEX vector_space_version_vector_space_id_version_key ON retrieval.vector_space_version USING btree (vector_space_id, version)` |

## Triggers

_None._

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: using `(tenant_id = util.current_tenant_id())`; with check `(tenant_id = util.current_tenant_id())`
