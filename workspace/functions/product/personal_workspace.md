---
id: "fn:product.personal_workspace(uuid)"
kind: function
schema: product
name: personal_workspace
domain: product-operations
lens: ours
overloads: ["fn:product.personal_workspace(uuid)"]
security: invoker
volatility: volatile
executors: []
raises: []
touches: { reads: [], writes: [authoring.workspace, authoring.workspace_member] }
tokens: [product, personal_workspace, product.personal_workspace]
defined_in: ["20261105010300_product_api.sql"]
workspace_fingerprint: "sha256:027ab2b6133d5d59318c478f06d832d89f937e563c387539f37fb3d7668818a8"
---
# product.personal_workspace

Domain `product-operations`, lens `ours`.

## personal_workspace(uuid) → uuid

function, volatile, security invoker, language plpgsql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p` | `uuid` | — | — |

Execute: no configured role.

Touches (best effort): reads —; writes [`authoring.workspace`](../../relations/authoring/workspace.md), [`authoring.workspace_member`](../../relations/authoring/workspace_member.md); calls [`product.tenant`](tenant.md).

TypeScript: `Database["product"]["Functions"]["personal_workspace"]`.

Defined in: `20261105010300_product_api.sql`.
