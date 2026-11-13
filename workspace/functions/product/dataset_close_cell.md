---
id: "fn:product.dataset_close_cell(uuid,uuid,uuid,int4)"
kind: function
schema: product
name: dataset_close_cell
domain: product-operations
lens: ours
overloads: ["fn:product.dataset_close_cell(uuid,uuid,uuid,int4)"]
security: invoker
volatility: volatile
executors: []
raises: []
touches: { reads: [], writes: [dataset.cell] }
tokens: [product, dataset_close_cell, product.dataset_close_cell]
defined_in: ["20261105010300_product_api.sql"]
workspace_fingerprint: "sha256:78aebf069f0925cf906c3997f4050a5a9e69eae7bcc29ce2060a813d8a02d4a9"
---
# product.dataset_close_cell

Domain `product-operations`, lens `ours`.

## dataset_close_cell(uuid, uuid, uuid, integer) → void

function, volatile, security invoker, language sql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `dw` | `uuid` | — | — |
| `rk` | `uuid` | — | — |
| `fk` | `uuid` | — | — |
| `n` | `integer` | — | — |

Execute: no configured role.

Touches (best effort): reads —; writes [`dataset.cell`](../../relations/dataset/cell.md); calls —.

TypeScript: `Database["product"]["Functions"]["dataset_close_cell"]`.

Defined in: `20261105010300_product_api.sql`.
