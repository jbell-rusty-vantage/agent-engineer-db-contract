---
id: "fn:product.insert_revision(uuid,work,uuid,uuid,jsonb)"
kind: function
schema: product
name: insert_revision
domain: authoring
lens: ours
overloads: ["fn:product.insert_revision(uuid,work,uuid,uuid,jsonb)"]
security: invoker
volatility: volatile
executors: []
raises: []
touches: { reads: [authoring.asset_scope, authoring.distribution_offer, authoring.file_set, authoring.release_item, authoring.revision_block, authoring.work, authoring.workspace, evidence.claim], writes: [authoring.revision_binding, authoring.runtime_requirement, authoring.work_revision, curriculum.outcome, curriculum.outcome_alignment, curriculum.part, curriculum.prerequisite, curriculum.requirement, curriculum.requirement_option, inquiry.assertion] }
tokens: [product, insert_revision, product.insert_revision]
defined_in: ["20261105010300_product_api.sql"]
workspace_fingerprint: "sha256:0bdaf1f915461feecb08d7ad5612fcb8db9039b883dd9c6e7e9be6d621251eee"
---
# product.insert_revision

Domain `authoring`, lens `ours`.

## insert_revision(uuid, authoring.work, uuid, uuid, jsonb) → uuid

function, volatile, security invoker, language plpgsql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `ws` | `uuid` | — | — |
| `w` | `authoring.work` | — | — |
| `p` | `uuid` | — | — |
| `parent` | `uuid` | — | — |
| `spec` | `jsonb` | — | — |

Execute: no configured role.

Touches (best effort): reads [`authoring.asset_scope`](../../relations/authoring/asset_scope.md), [`authoring.distribution_offer`](../../relations/authoring/distribution_offer.md), [`authoring.file_set`](../../relations/authoring/file_set.md), [`authoring.release_item`](../../relations/authoring/release_item.md), [`authoring.revision_block`](../../relations/authoring/revision_block.md), [`authoring.work`](../../relations/authoring/work.md), [`authoring.workspace`](../../relations/authoring/workspace.md), [`evidence.claim`](../../relations/evidence/claim.md); writes [`authoring.revision_binding`](../../relations/authoring/revision_binding.md), [`authoring.runtime_requirement`](../../relations/authoring/runtime_requirement.md), [`authoring.work_revision`](../../relations/authoring/work_revision.md), [`curriculum.outcome`](../../relations/curriculum/outcome.md), [`curriculum.outcome_alignment`](../../relations/curriculum/outcome_alignment.md), [`curriculum.part`](../../relations/curriculum/part.md), [`curriculum.prerequisite`](../../relations/curriculum/prerequisite.md), [`curriculum.requirement`](../../relations/curriculum/requirement.md), [`curriculum.requirement_option`](../../relations/curriculum/requirement_option.md), [`inquiry.assertion`](../../relations/inquiry/assertion.md); calls [`product.can_read_offer`](can_read_offer.md), [`product.fail`](fail.md), [`product.readable_revision`](readable_revision.md), [`product.revision_digest`](revision_digest.md), [`product.role_in`](role_in.md), [`product.tenant`](tenant.md), [`product.validate_body`](validate_body.md), [`product.walk_blocks`](walk_blocks.md), [`util.uuidv7`](../util/uuidv7.md).

TypeScript: `Database["product"]["Functions"]["insert_revision"]`.

Defined in: `20261105010300_product_api.sql`.
