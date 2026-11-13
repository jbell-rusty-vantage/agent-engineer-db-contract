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
workspace_fingerprint: "sha256:78aebf069f0925cf906c3997f4050a5a9e69eae7bcc29ce2060a813d8a02d4a9"
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
