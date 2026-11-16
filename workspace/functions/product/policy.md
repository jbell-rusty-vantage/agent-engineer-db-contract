---
id: "fn:product.policy()"
kind: function
schema: product
name: policy
domain: learning
lens: ours
overloads: ["fn:product.policy()"]
security: invoker
volatility: stable
executors: []
raises: []
touches: { reads: [access.policy_version], writes: [] }
tokens: [product, policy, product.policy]
defined_in: ["20261105010300_product_api.sql"]
workspace_fingerprint: "sha256:1632162dedd33f48177992e3e5ad79c363556a7b68ee650fc7e68b2bb3855da4"
---
# product.policy

Domain `learning`, lens `ours`.

## policy() → jsonb

function, stable, security invoker, language sql, config `search_path=""`.

No arguments.

Execute: no configured role.

Touches (best effort): reads [`access.policy_version`](../../relations/access/policy_version.md); writes —; calls [`product.tenant`](tenant.md).

TypeScript: `Database["product"]["Functions"]["policy"]`.

Defined in: `20261105010300_product_api.sql`.
