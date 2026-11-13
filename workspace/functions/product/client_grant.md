---
id: "fn:product.client_grant(text,uuid)"
kind: function
schema: product
name: client_grant
domain: access
lens: ours
overloads: ["fn:product.client_grant(text,uuid)"]
security: invoker
volatility: volatile
executors: []
raises: []
touches: { reads: [], writes: [access.client_grant] }
tokens: [product, client_grant, product.client_grant]
defined_in: ["20261105010300_product_api.sql"]
workspace_fingerprint: "sha256:78aebf069f0925cf906c3997f4050a5a9e69eae7bcc29ce2060a813d8a02d4a9"
---
# product.client_grant

Domain `access`, lens `ours`.

## client_grant(text, uuid) → access.client_grant

function, volatile, security invoker, language plpgsql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `op_scope` | `text` | — | — |
| `ws` | `uuid` | — | — |

Execute: no configured role.

Touches (best effort): reads —; writes [`access.client_grant`](../../relations/access/client_grant.md); calls [`product.actor`](actor.md), [`product.fail`](fail.md), [`product.sha256_text`](sha256_text.md), [`product.tenant`](tenant.md).

TypeScript: `Database["product"]["Functions"]["client_grant"]`.

Defined in: `20261105010300_product_api.sql`.
