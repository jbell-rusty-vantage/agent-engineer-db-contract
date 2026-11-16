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
workspace_fingerprint: "sha256:94ffe6a458de74a3cfebdee4fb31f371d14c89d7eaa16cfe1ab1cae9dc94743b"
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
