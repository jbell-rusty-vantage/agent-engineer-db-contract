---
id: "fn:product.dataset_edit(uuid,uuid,jsonb,uuid,bool)"
kind: function
schema: product
name: dataset_edit
domain: inquiry
lens: ours
overloads: ["fn:product.dataset_edit(uuid,uuid,jsonb,uuid,bool)"]
security: invoker
volatility: volatile
executors: []
raises: []
touches: { reads: [], writes: [dataset.cell, dataset.field, dataset.row] }
tokens: [product, dataset_edit, product.dataset_edit]
defined_in: ["20261105010300_product_api.sql"]
workspace_fingerprint: "sha256:94ffe6a458de74a3cfebdee4fb31f371d14c89d7eaa16cfe1ab1cae9dc94743b"
---
# product.dataset_edit

Domain `inquiry`, lens `ours`.

## dataset_edit(uuid, uuid, jsonb, uuid, boolean) → integer

function, volatile, security invoker, language plpgsql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `ws` | `uuid` | — | — |
| `dw` | `uuid` | — | — |
| `pl` | `jsonb` | — | — |
| `p` | `uuid` | — | — |
| `human` | `boolean` | — | — |

Execute: no configured role.

Touches (best effort): reads —; writes [`dataset.cell`](../../relations/dataset/cell.md), [`dataset.field`](../../relations/dataset/field.md), [`dataset.row`](../../relations/dataset/row.md); calls [`product.check_cell_value`](check_cell_value.md), [`product.dataset_close_cell`](dataset_close_cell.md), [`product.dataset_draft_no`](dataset_draft_no.md), [`product.fail`](fail.md), [`product.tenant`](tenant.md), [`util.uuidv7`](../util/uuidv7.md).

TypeScript: `Database["product"]["Functions"]["dataset_edit"]`.

Defined in: `20261105010300_product_api.sql`.
