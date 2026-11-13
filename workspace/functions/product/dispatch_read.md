---
id: "fn:product.dispatch_read(uuid,text,jsonb,uuid)"
kind: function
schema: product
name: dispatch_read
domain: product-operations
lens: ours
overloads: ["fn:product.dispatch_read(uuid,text,jsonb,uuid)"]
security: invoker
volatility: stable
executors: []
raises: []
touches: { reads: [authoring.asset_scope, authoring.distribution, authoring.distribution_offer, authoring.release_item, authoring.revision_binding, authoring.revision_block, authoring.work, authoring.work_revision, authoring.workspace, authoring.workspace_member, conversation.message, conversation.thread, curriculum.requirement, learning.assessment_result, learning.credit, learning.criterion_result, learning.enrollment, learning.evidence_grant, learning.grading_run, learning.release_adoption, learning.submission, library.passage, library.resource_control], writes: [] }
tokens: [product, dispatch_read, product.dispatch_read]
defined_in: ["20261105010300_product_api.sql", "20261108120000_build08_r2_knowledge_continuum.sql", part3b_product.sql]
workspace_fingerprint: "sha256:78aebf069f0925cf906c3997f4050a5a9e69eae7bcc29ce2060a813d8a02d4a9"
---
# product.dispatch_read

Domain `product-operations`, lens `ours`.

## dispatch_read(uuid, text, jsonb, uuid) → jsonb

function, stable, security invoker, language plpgsql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `ws` | `uuid` | — | — |
| `op` | `text` | — | — |
| `pl` | `jsonb` | — | — |
| `p` | `uuid` | — | — |

Execute: no configured role.

Touches (best effort): reads [`authoring.asset_scope`](../../relations/authoring/asset_scope.md), [`authoring.distribution`](../../relations/authoring/distribution.md), [`authoring.distribution_offer`](../../relations/authoring/distribution_offer.md), [`authoring.release_item`](../../relations/authoring/release_item.md), [`authoring.revision_binding`](../../relations/authoring/revision_binding.md), [`authoring.revision_block`](../../relations/authoring/revision_block.md), [`authoring.work`](../../relations/authoring/work.md), [`authoring.work_revision`](../../relations/authoring/work_revision.md), [`authoring.workspace`](../../relations/authoring/workspace.md), [`authoring.workspace_member`](../../relations/authoring/workspace_member.md), [`conversation.message`](../../relations/conversation/message.md), [`conversation.thread`](../../relations/conversation/thread.md), [`curriculum.requirement`](../../relations/curriculum/requirement.md), [`learning.assessment_result`](../../relations/learning/assessment_result.md), [`learning.credit`](../../relations/learning/credit.md), [`learning.criterion_result`](../../relations/learning/criterion_result.md), [`learning.enrollment`](../../relations/learning/enrollment.md), [`learning.evidence_grant`](../../relations/learning/evidence_grant.md), [`learning.grading_run`](../../relations/learning/grading_run.md), [`learning.release_adoption`](../../relations/learning/release_adoption.md), [`learning.submission`](../../relations/learning/submission.md), [`library.passage`](../../relations/library/passage.md), [`library.resource_control`](../../relations/library/resource_control.md); writes —; calls [`api.search_unified`](../api/search_unified.md), [`product.can_read_offer`](can_read_offer.md), [`product.dispatch_research_read`](dispatch_research_read.md), [`product.exposure`](exposure.md), [`product.fail`](fail.md), [`product.readable_revision`](readable_revision.md), [`product.require_role`](require_role.md), [`product.restricted`](restricted.md), [`product.role_in`](role_in.md), [`product.tenant`](tenant.md).

TypeScript: `Database["product"]["Functions"]["dispatch_read"]`.

Defined in: `20261105010300_product_api.sql`, `20261108120000_build08_r2_knowledge_continuum.sql`, `part3b_product.sql`.
