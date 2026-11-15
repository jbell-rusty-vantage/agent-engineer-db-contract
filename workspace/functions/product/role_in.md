---
id: "fn:product.role_in(uuid,uuid)"
kind: function
schema: product
name: role_in
domain: access
lens: ours
overloads: ["fn:product.role_in(uuid,uuid)"]
security: invoker
volatility: stable
executors: []
raises: []
touches: { reads: [authoring.workspace_member], writes: [] }
tokens: [product, role_in, product.role_in]
defined_in: ["20261105010300_product_api.sql"]
workspace_fingerprint: "sha256:195a7bf46350274849f7ac517bb02381bbf8851afdacebee2c17dad0d348934c"
---
# product.role_in

Domain `access`, lens `ours`.

## role_in(uuid, uuid) → text

function, stable, security invoker, language sql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `ws` | `uuid` | — | — |
| `p` | `uuid` | — | — |

Execute: no configured role.

Touches (best effort): reads [`authoring.workspace_member`](../../relations/authoring/workspace_member.md); writes —; calls [`product.tenant`](tenant.md).

TypeScript: `Database["product"]["Functions"]["role_in"]`.

Defined in: `20261105010300_product_api.sql`.
