---
id: "fn:product.dataset_work(uuid,uuid)"
kind: function
schema: product
name: dataset_work
domain: product-operations
lens: ours
overloads: ["fn:product.dataset_work(uuid,uuid)"]
security: invoker
volatility: volatile
executors: []
raises: []
touches: { reads: [authoring.work], writes: [] }
tokens: [product, dataset_work, product.dataset_work]
defined_in: ["20261105010300_product_api.sql"]
workspace_fingerprint: "sha256:78aebf069f0925cf906c3997f4050a5a9e69eae7bcc29ce2060a813d8a02d4a9"
---
# product.dataset_work

Domain `product-operations`, lens `ours`.

## dataset_work(uuid, uuid) → authoring.work

function, volatile, security invoker, language plpgsql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `ws` | `uuid` | — | — |
| `dw` | `uuid` | — | — |

Execute: no configured role.

Touches (best effort): reads [`authoring.work`](../../relations/authoring/work.md); writes —; calls [`product.fail`](fail.md).

TypeScript: `Database["product"]["Functions"]["dataset_work"]`.

Defined in: `20261105010300_product_api.sql`.
