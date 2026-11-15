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
workspace_fingerprint: "sha256:195a7bf46350274849f7ac517bb02381bbf8851afdacebee2c17dad0d348934c"
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
