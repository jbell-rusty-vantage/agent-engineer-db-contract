---
id: "fn:product.dispatch_research_read(uuid,text,jsonb,uuid)"
kind: function
schema: product
name: dispatch_research_read
domain: product-operations
lens: ours
overloads: ["fn:product.dispatch_research_read(uuid,text,jsonb,uuid)"]
security: invoker
volatility: stable
executors: []
raises: []
touches: { reads: [authoring.revision_binding, authoring.revision_block, authoring.work, authoring.work_revision, dataset.cell, dataset.proposal, dataset.row, inquiry.acceptance, inquiry.assertion, inquiry.delivery, inquiry.obligation, inquiry.support, inquiry.watch], writes: [] }
tokens: [product, dispatch_research_read, product.dispatch_research_read]
defined_in: ["20261105010300_product_api.sql"]
workspace_fingerprint: "sha256:216c4ae7230478c8e60934da25c852e10680d6caed71a662962ea3c0ac1676d3"
---
# product.dispatch_research_read

Domain `product-operations`, lens `ours`.

## dispatch_research_read(uuid, text, jsonb, uuid) → jsonb

function, stable, security invoker, language plpgsql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `ws` | `uuid` | — | — |
| `op` | `text` | — | — |
| `pl` | `jsonb` | — | — |
| `p` | `uuid` | — | — |

Execute: no configured role.

Touches (best effort): reads [`authoring.revision_binding`](../../relations/authoring/revision_binding.md), [`authoring.revision_block`](../../relations/authoring/revision_block.md), [`authoring.work`](../../relations/authoring/work.md), [`authoring.work_revision`](../../relations/authoring/work_revision.md), [`dataset.cell`](../../relations/dataset/cell.md), [`dataset.proposal`](../../relations/dataset/proposal.md), [`dataset.row`](../../relations/dataset/row.md), [`inquiry.acceptance`](../../relations/inquiry/acceptance.md), [`inquiry.assertion`](../../relations/inquiry/assertion.md), [`inquiry.delivery`](../../relations/inquiry/delivery.md), [`inquiry.obligation`](../../relations/inquiry/obligation.md), [`inquiry.support`](../../relations/inquiry/support.md), [`inquiry.watch`](../../relations/inquiry/watch.md); writes —; calls [`product.dataset_content_sha256`](dataset_content_sha256.md), [`product.dataset_draft_no`](dataset_draft_no.md), [`product.dataset_snapshot`](dataset_snapshot.md), [`product.fail`](fail.md), [`product.readable_revision`](readable_revision.md), [`product.require_role`](require_role.md), [`product.support_counts`](support_counts.md), [`product.support_detail`](support_detail.md).

TypeScript: `Database["product"]["Functions"]["dispatch_research_read"]`.

Defined in: `20261105010300_product_api.sql`.
