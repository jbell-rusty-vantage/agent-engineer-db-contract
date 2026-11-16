---
id: "fn:product.processing_allowed(uuid,text,text)"
kind: function
schema: product
name: processing_allowed
domain: access
lens: ours
overloads: ["fn:product.processing_allowed(uuid,text,text)"]
security: invoker
volatility: stable
executors: []
raises: []
touches: { reads: [access.processing_authorization], writes: [] }
tokens: [product, processing_allowed, product.processing_allowed]
defined_in: ["20261105010300_product_api.sql"]
workspace_fingerprint: "sha256:1632162dedd33f48177992e3e5ad79c363556a7b68ee650fc7e68b2bb3855da4"
---
# product.processing_allowed

Domain `access`, lens `ours`.

## processing_allowed(uuid, text, text) → boolean

function, stable, security invoker, language sql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p` | `uuid` | — | — |
| `cls` | `text` | — | — |
| `pkey` | `text` | — | — |

Execute: no configured role.

Touches (best effort): reads [`access.processing_authorization`](../../relations/access/processing_authorization.md); writes —; calls [`product.band`](band.md), [`product.policy`](policy.md), [`product.tenant`](tenant.md).

TypeScript: `Database["product"]["Functions"]["processing_allowed"]`.

Defined in: `20261105010300_product_api.sql`.
