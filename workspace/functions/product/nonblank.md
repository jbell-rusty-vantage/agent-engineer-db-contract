---
id: "fn:product.nonblank(text)"
kind: function
schema: product
name: nonblank
domain: product-operations
lens: ours
overloads: ["fn:product.nonblank(text)"]
security: invoker
volatility: immutable
executors: []
raises: []
touches: { reads: [], writes: [] }
tokens: [product, nonblank, product.nonblank]
defined_in: ["20261105010100_product_foundation.sql"]
workspace_fingerprint: "sha256:ccec60ca7715c4edc1685d828a7324ce66fa6f9af95ad2a789d9a2fc6418dc0e"
---
# product.nonblank

Domain `product-operations`, lens `ours`.

## nonblank(text) → boolean

function, immutable, security invoker, language sql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `t` | `text` | — | — |

Execute: no configured role.

TypeScript: `Database["product"]["Functions"]["nonblank"]`.

Defined in: `20261105010100_product_foundation.sql`.
