---
id: "fn:api.product_scope(text)"
kind: function
schema: api
name: product_scope
domain: api-surface
lens: corpus
overloads: ["fn:api.product_scope(text)"]
security: definer
volatility: volatile
executors: [authenticated]
raises: []
touches: { reads: [access.client_grant], writes: [] }
tokens: [api, product_scope, api.product_scope]
defined_in: ["20261115130000_build08_d82_signed_in_knowledge_reads.sql", "20261115130200_build08_d82_product_scope.sql"]
workspace_fingerprint: "sha256:1632162dedd33f48177992e3e5ad79c363556a7b68ee650fc7e68b2bb3855da4"
---
# api.product_scope

Domain `api-surface`, lens `corpus`.

## product_scope(text) → jsonb

function, volatile, security definer, language plpgsql, config `search_path=""`. The client-grant check of api.product_read for a named scope (read, author, learn, library, assess), for reads composed outside it (D-82): raises AUTH_REQUIRED, CLIENT_GRANT_INVALID or CLIENT_SCOPE_DENIED like the product operations; returns the principal and the grant that applies (clientGrantId is null when the request carries no client token).

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_scope` | `text` | — | — |

Execute: `authenticated`.

Touches (best effort): reads [`access.client_grant`](../../relations/access/client_grant.md); writes —; calls [`product.actor`](../product/actor.md), [`product.client_grant`](../product/client_grant.md), [`product.fail`](../product/fail.md).

TypeScript: `Database["api"]["Functions"]["product_scope"]`.

Defined in: `20261115130000_build08_d82_signed_in_knowledge_reads.sql`, `20261115130200_build08_d82_product_scope.sql`.
