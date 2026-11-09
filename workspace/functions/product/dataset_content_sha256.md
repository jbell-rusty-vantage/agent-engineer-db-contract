---
id: "fn:product.dataset_content_sha256(uuid,int4)"
kind: function
schema: product
name: dataset_content_sha256
domain: product-operations
lens: ours
overloads: ["fn:product.dataset_content_sha256(uuid,int4)"]
security: invoker
volatility: stable
executors: []
raises: []
touches: { reads: [], writes: [] }
tokens: [product, dataset_content_sha256, product.dataset_content_sha256]
defined_in: ["20261105010300_product_api.sql"]
workspace_fingerprint: "sha256:0bdaf1f915461feecb08d7ad5612fcb8db9039b883dd9c6e7e9be6d621251eee"
---
# product.dataset_content_sha256

Domain `product-operations`, lens `ours`.

## dataset_content_sha256(uuid, integer) → text

function, stable, security invoker, language sql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `dw` | `uuid` | — | — |
| `n` | `integer` | — | — |

Execute: no configured role.

Touches (best effort): reads —; writes —; calls [`product.dataset_snapshot`](dataset_snapshot.md), [`product.sha256_text`](sha256_text.md).

TypeScript: `Database["product"]["Functions"]["dataset_content_sha256"]`.

Defined in: `20261105010300_product_api.sql`.
