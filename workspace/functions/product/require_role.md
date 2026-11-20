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
workspace_fingerprint: "sha256:cb1a65412d0fb43423d4f775d78507ab4b320e27f820adab0423446aac89f036"
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
