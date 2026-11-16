---
id: "fn:product.sha256_text(text)"
kind: function
schema: product
name: sha256_text
domain: product-operations
lens: ours
overloads: ["fn:product.sha256_text(text)"]
security: invoker
volatility: immutable
executors: []
raises: []
touches: { reads: [], writes: [] }
tokens: [product, sha256_text, product.sha256_text]
defined_in: ["20261105010100_product_foundation.sql"]
workspace_fingerprint: "sha256:1632162dedd33f48177992e3e5ad79c363556a7b68ee650fc7e68b2bb3855da4"
---
# product.sha256_text

Domain `product-operations`, lens `ours`.

## sha256_text(text) → text

function, immutable, security invoker, language sql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `t` | `text` | — | — |

Execute: no configured role.

TypeScript: `Database["product"]["Functions"]["sha256_text"]`.

Defined in: `20261105010100_product_foundation.sql`.
