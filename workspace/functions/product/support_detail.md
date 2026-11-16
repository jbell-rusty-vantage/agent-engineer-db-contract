---
id: "fn:product.support_detail(support,uuid)"
kind: function
schema: product
name: support_detail
domain: inquiry
lens: ours
overloads: ["fn:product.support_detail(support,uuid)"]
security: invoker
volatility: stable
executors: []
raises: []
touches: { reads: [authoring.revision_binding, authoring.work_revision, dataset.cell, evidence.claim, inquiry.assertion, orchestration.artifact], writes: [] }
tokens: [product, support_detail, product.support_detail]
defined_in: ["20261105010300_product_api.sql"]
workspace_fingerprint: "sha256:1632162dedd33f48177992e3e5ad79c363556a7b68ee650fc7e68b2bb3855da4"
---
# product.support_detail

Domain `inquiry`, lens `ours`.

## support_detail(inquiry.support, uuid) → jsonb

function, stable, security invoker, language plpgsql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `s` | `inquiry.support` | — | — |
| `p` | `uuid` | — | — |

Execute: no configured role.

Touches (best effort): reads [`authoring.revision_binding`](../../relations/authoring/revision_binding.md), [`authoring.work_revision`](../../relations/authoring/work_revision.md), [`dataset.cell`](../../relations/dataset/cell.md), [`evidence.claim`](../../relations/evidence/claim.md), [`inquiry.assertion`](../../relations/inquiry/assertion.md), [`orchestration.artifact`](../../relations/orchestration/artifact.md); writes —; calls [`product.readable_revision`](readable_revision.md).

TypeScript: `Database["product"]["Functions"]["support_detail"]`.

Defined in: `20261105010300_product_api.sql`.
