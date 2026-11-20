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
workspace_fingerprint: "sha256:db20bac4d9e82d9b94cd2f3b580d4c145bcc3820969fdd572c6e7868ecca53fd"
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
