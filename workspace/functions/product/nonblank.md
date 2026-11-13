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
workspace_fingerprint: "sha256:78aebf069f0925cf906c3997f4050a5a9e69eae7bcc29ce2060a813d8a02d4a9"
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
