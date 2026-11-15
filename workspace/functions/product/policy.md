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
workspace_fingerprint: "sha256:195a7bf46350274849f7ac517bb02381bbf8851afdacebee2c17dad0d348934c"
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
