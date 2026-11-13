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
workspace_fingerprint: "sha256:4ca964568389f6bca66099cb3a109cf6e895892ead47d26c6c89b292b0e91e75"
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
