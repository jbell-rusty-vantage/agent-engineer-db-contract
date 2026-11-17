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
workspace_fingerprint: "sha256:3cbce2e1f51948facb352a727c22966b1e5ceea4646ae43b07860ce6e83127b4"
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
