---
id: "fn:product.walk_blocks(uuid,jsonb,uuid,uuid)"
kind: function
schema: product
name: walk_blocks
domain: authoring
lens: ours
overloads: ["fn:product.walk_blocks(uuid,jsonb,uuid,uuid)"]
security: invoker
volatility: volatile
executors: []
raises: []
touches: { reads: [authoring.block_type, authoring.deployment, authoring.revision_binding, authoring.work, authoring.work_revision], writes: [authoring.revision_block] }
tokens: [product, walk_blocks, product.walk_blocks]
defined_in: ["20261105010300_product_api.sql"]
workspace_fingerprint: "sha256:db20bac4d9e82d9b94cd2f3b580d4c145bcc3820969fdd572c6e7868ecca53fd"
---
# product.walk_blocks

Domain `authoring`, lens `ours`.

## walk_blocks(uuid, jsonb, uuid, uuid) → void

function, volatile, security invoker, language plpgsql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `rid` | `uuid` | — | — |
| `blocks` | `jsonb` | — | — |
| `parent` | `uuid` | — | — |
| `p` | `uuid` | — | — |

Execute: no configured role.

Touches (best effort): reads [`authoring.block_type`](../../relations/authoring/block_type.md), [`authoring.deployment`](../../relations/authoring/deployment.md), [`authoring.revision_binding`](../../relations/authoring/revision_binding.md), [`authoring.work`](../../relations/authoring/work.md), [`authoring.work_revision`](../../relations/authoring/work_revision.md); writes [`authoring.revision_block`](../../relations/authoring/revision_block.md); calls [`product.fail`](fail.md), [`product.nonblank`](nonblank.md), [`product.readable_revision`](readable_revision.md), [`product.sha256_text`](sha256_text.md), [`product.walk_blocks`](walk_blocks.md).

TypeScript: `Database["product"]["Functions"]["walk_blocks"]`.

Defined in: `20261105010300_product_api.sql`.
