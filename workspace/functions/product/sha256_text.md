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
workspace_fingerprint: "sha256:027ab2b6133d5d59318c478f06d832d89f937e563c387539f37fb3d7668818a8"
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
