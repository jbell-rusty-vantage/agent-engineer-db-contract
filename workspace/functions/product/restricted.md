---
id: "fn:product.restricted(uuid,uuid,text[])"
kind: function
schema: product
name: restricted
domain: access
lens: ours
overloads: ["fn:product.restricted(uuid,uuid,text[])"]
security: invoker
volatility: stable
executors: []
raises: []
touches: { reads: [access.source_restriction, evidence.source_capture], writes: [] }
tokens: [product, restricted, product.restricted]
defined_in: ["20261105010300_product_api.sql"]
workspace_fingerprint: "sha256:1632162dedd33f48177992e3e5ad79c363556a7b68ee650fc7e68b2bb3855da4"
---
# product.restricted

Domain `access`, lens `ours`.

## restricted(uuid, uuid, text[]) → boolean

function, stable, security invoker, language sql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `cap` | `uuid` | — | — |
| `art` | `uuid` | — | — |
| `effects` | `text[]` | — | — |

Execute: no configured role.

Touches (best effort): reads [`access.source_restriction`](../../relations/access/source_restriction.md), [`evidence.source_capture`](../../relations/evidence/source_capture.md); writes —; calls [`product.tenant`](tenant.md).

TypeScript: `Database["product"]["Functions"]["restricted"]`.

Defined in: `20261105010300_product_api.sql`.
