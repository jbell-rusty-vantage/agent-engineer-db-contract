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
workspace_fingerprint: "sha256:fbf5703bf7a6f6131c452444ee949f1feec1bbe813c78d772fb3886b510815b9"
---
# product.claims

Domain `product-operations`, lens `ours`.

## claims() → jsonb

function, stable, security invoker, language sql, config `search_path=""`.

No arguments.

Execute: no configured role.

TypeScript: `Database["product"]["Functions"]["claims"]`.

Defined in: `20261105010300_product_api.sql`.
