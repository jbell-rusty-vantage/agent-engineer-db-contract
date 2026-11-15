---
id: "fn:product.band(uuid)"
kind: function
schema: product
name: band
domain: learning
lens: ours
overloads: ["fn:product.band(uuid)"]
security: invoker
volatility: stable
executors: []
raises: []
touches: { reads: [access.account_profile], writes: [] }
tokens: [product, band, product.band]
defined_in: ["20261105010300_product_api.sql"]
workspace_fingerprint: "sha256:195a7bf46350274849f7ac517bb02381bbf8851afdacebee2c17dad0d348934c"
---
# product.band

Domain `learning`, lens `ours`.

## band(uuid) → text

function, stable, security invoker, language sql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p` | `uuid` | — | — |

Execute: no configured role.

Touches (best effort): reads [`access.account_profile`](../../relations/access/account_profile.md); writes —; calls [`product.policy`](policy.md), [`product.tenant`](tenant.md).

TypeScript: `Database["product"]["Functions"]["band"]`.

Defined in: `20261105010300_product_api.sql`.
