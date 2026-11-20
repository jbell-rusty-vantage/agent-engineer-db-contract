---
id: "fn:product.claims()"
kind: function
schema: product
name: claims
domain: product-operations
lens: ours
overloads: ["fn:product.claims()"]
security: invoker
volatility: stable
executors: []
raises: []
touches: { reads: [], writes: [] }
tokens: [product, claims, product.claims]
defined_in: ["20261105010300_product_api.sql"]
workspace_fingerprint: "sha256:cb1a65412d0fb43423d4f775d78507ab4b320e27f820adab0423446aac89f036"
---
# product.claims

Domain `product-operations`, lens `ours`.

## claims() → jsonb

function, stable, security invoker, language sql, config `search_path=""`.

No arguments.

Execute: no configured role.

TypeScript: `Database["product"]["Functions"]["claims"]`.

Defined in: `20261105010300_product_api.sql`.
