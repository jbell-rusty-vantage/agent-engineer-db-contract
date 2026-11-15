---
id: "fn:product.band_rank(text)"
kind: function
schema: product
name: band_rank
domain: learning
lens: ours
overloads: ["fn:product.band_rank(text)"]
security: invoker
volatility: immutable
executors: []
raises: []
touches: { reads: [], writes: [] }
tokens: [product, band_rank, product.band_rank]
defined_in: ["20261105010300_product_api.sql"]
workspace_fingerprint: "sha256:195a7bf46350274849f7ac517bb02381bbf8851afdacebee2c17dad0d348934c"
---
# product.band_rank

Domain `learning`, lens `ours`.

## band_rank(text) → integer

function, immutable, security invoker, language sql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `b` | `text` | — | — |

Execute: no configured role.

TypeScript: `Database["product"]["Functions"]["band_rank"]`.

Defined in: `20261105010300_product_api.sql`.
