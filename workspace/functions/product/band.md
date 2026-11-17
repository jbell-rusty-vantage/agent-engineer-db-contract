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
workspace_fingerprint: "sha256:3cbce2e1f51948facb352a727c22966b1e5ceea4646ae43b07860ce6e83127b4"
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
