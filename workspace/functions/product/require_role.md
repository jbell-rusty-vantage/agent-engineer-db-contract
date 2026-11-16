---
id: "fn:product.require_role(uuid,uuid,text[])"
kind: function
schema: product
name: require_role
domain: access
lens: ours
overloads: ["fn:product.require_role(uuid,uuid,text[])"]
security: invoker
volatility: stable
executors: []
raises: []
touches: { reads: [], writes: [] }
tokens: [product, require_role, product.require_role]
defined_in: ["20261105010300_product_api.sql"]
workspace_fingerprint: "sha256:ccec60ca7715c4edc1685d828a7324ce66fa6f9af95ad2a789d9a2fc6418dc0e"
---
# product.require_role

Domain `access`, lens `ours`.

## require_role(uuid, uuid, text[]) → text

function, stable, security invoker, language plpgsql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `ws` | `uuid` | — | — |
| `p` | `uuid` | — | — |
| `allowed` | `text[]` | — | — |

Execute: no configured role.

Touches (best effort): reads —; writes —; calls [`product.fail`](fail.md), [`product.role_in`](role_in.md).

TypeScript: `Database["product"]["Functions"]["require_role"]`.

Defined in: `20261105010300_product_api.sql`.
