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
workspace_fingerprint: "sha256:78aebf069f0925cf906c3997f4050a5a9e69eae7bcc29ce2060a813d8a02d4a9"
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
