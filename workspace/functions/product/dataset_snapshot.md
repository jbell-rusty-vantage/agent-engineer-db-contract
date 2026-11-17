---
id: "fn:product.dataset_snapshot(uuid,int4)"
kind: function
schema: product
name: dataset_snapshot
domain: inquiry
lens: ours
overloads: ["fn:product.dataset_snapshot(uuid,int4)"]
security: invoker
volatility: stable
executors: []
raises: []
touches: { reads: [dataset.cell, dataset.field, dataset.row], writes: [] }
tokens: [product, dataset_snapshot, product.dataset_snapshot]
defined_in: ["20261105010300_product_api.sql"]
workspace_fingerprint: "sha256:3cbce2e1f51948facb352a727c22966b1e5ceea4646ae43b07860ce6e83127b4"
---
# product.dataset_snapshot

Domain `inquiry`, lens `ours`.

## dataset_snapshot(uuid, integer) → jsonb

function, stable, security invoker, language sql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `dw` | `uuid` | — | — |
| `n` | `integer` | — | — |

Execute: no configured role.

Touches (best effort): reads [`dataset.cell`](../../relations/dataset/cell.md), [`dataset.field`](../../relations/dataset/field.md), [`dataset.row`](../../relations/dataset/row.md); writes —; calls —.

TypeScript: `Database["product"]["Functions"]["dataset_snapshot"]`.

Defined in: `20261105010300_product_api.sql`.
