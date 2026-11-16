---
id: "fn:product.dispatch_worker(text,jsonb)"
kind: function
schema: product
name: dispatch_worker
domain: product-operations
lens: ours
overloads: ["fn:product.dispatch_worker(text,jsonb)"]
security: invoker
volatility: volatile
executors: []
raises: []
touches: { reads: [authoring.release_item, authoring.work_revision, learning.submission, library.resource_control, retrieval.projection_target, retrieval.vector_item], writes: [access.account_profile, access.policy_version, access.provided_credential, access.source_restriction, authoring.deployment, authoring.publisher_grant, learning.assessment_result, learning.criterion_result, learning.equivalence_request, learning.grading_run, library.passage, library.preparation, orchestration.artifact] }
tokens: [product, dispatch_worker, product.dispatch_worker]
defined_in: ["20261105010300_product_api.sql", "20261108120000_build08_r2_knowledge_continuum.sql", part3b_product.sql]
workspace_fingerprint: "sha256:94ffe6a458de74a3cfebdee4fb31f371d14c89d7eaa16cfe1ab1cae9dc94743b"
---
# product.dispatch_worker

Domain `product-operations`, lens `ours`.

## dispatch_worker(text, jsonb) → jsonb

function, volatile, security invoker, language plpgsql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `op` | `text` | — | — |
| `pl` | `jsonb` | — | — |

Execute: no configured role.

Touches (best effort): reads [`authoring.release_item`](../../relations/authoring/release_item.md), [`authoring.work_revision`](../../relations/authoring/work_revision.md), [`learning.submission`](../../relations/learning/submission.md), [`library.resource_control`](../../relations/library/resource_control.md), [`retrieval.projection_target`](../../relations/retrieval/projection_target.md), [`retrieval.vector_item`](../../relations/retrieval/vector_item.md); writes [`access.account_profile`](../../relations/access/account_profile.md), [`access.policy_version`](../../relations/access/policy_version.md), [`access.provided_credential`](../../relations/access/provided_credential.md), [`access.source_restriction`](../../relations/access/source_restriction.md), [`authoring.deployment`](../../relations/authoring/deployment.md), [`authoring.publisher_grant`](../../relations/authoring/publisher_grant.md), [`learning.assessment_result`](../../relations/learning/assessment_result.md), [`learning.criterion_result`](../../relations/learning/criterion_result.md), [`learning.equivalence_request`](../../relations/learning/equivalence_request.md), [`learning.grading_run`](../../relations/learning/grading_run.md), [`library.passage`](../../relations/library/passage.md), [`library.preparation`](../../relations/library/preparation.md), [`orchestration.artifact`](../../relations/orchestration/artifact.md); calls [`product.fail`](fail.md), [`product.finalize`](finalize.md), [`product.policy`](policy.md), [`product.processing_allowed`](processing_allowed.md), [`product.sha256_text`](sha256_text.md), [`product.tenant`](tenant.md), [`retrieval.index_text_item`](../retrieval/index_text_item.md), [`retrieval.retire_items_for_passages`](../retrieval/retire_items_for_passages.md), [`retrieval.store_embedding`](../retrieval/store_embedding.md).

TypeScript: `Database["product"]["Functions"]["dispatch_worker"]`.

Defined in: `20261105010300_product_api.sql`, `20261108120000_build08_r2_knowledge_continuum.sql`, `part3b_product.sql`.
