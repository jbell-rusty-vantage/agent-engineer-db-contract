---
id: "fn:product.tenant()"
kind: function
schema: product
name: tenant
domain: product-operations
lens: ours
overloads: ["fn:product.tenant()"]
security: invoker
volatility: stable
executors: []
raises: []
touches: { reads: [], writes: [] }
tokens: [product, tenant, product.tenant]
defined_in: ["20261105010300_product_api.sql"]
workspace_fingerprint: "sha256:cb1a65412d0fb43423d4f775d78507ab4b320e27f820adab0423446aac89f036"
---
# product.tenant

Domain `product-operations`, lens `ours`.

## tenant() → uuid

function, stable, security invoker, language sql, config `search_path=""`.

No arguments.

Execute: no configured role.

Touches (best effort): reads —; writes —; calls [`util.default_tenant_id`](../util/default_tenant_id.md).

TypeScript: `Database["product"]["Functions"]["tenant"]`.

Defined in: `20261105010300_product_api.sql`.
