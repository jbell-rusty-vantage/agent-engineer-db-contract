---
id: "fn:product.actor()"
kind: function
schema: product
name: actor
domain: access
lens: ours
overloads: ["fn:product.actor()"]
security: invoker
volatility: stable
executors: []
raises: []
touches: { reads: [], writes: [] }
tokens: [product, actor, product.actor]
defined_in: ["20261105010300_product_api.sql"]
workspace_fingerprint: "sha256:3cbce2e1f51948facb352a727c22966b1e5ceea4646ae43b07860ce6e83127b4"
---
# product.actor

Domain `access`, lens `ours`.

## actor() → uuid

function, stable, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: no configured role.

Touches (best effort): reads —; writes —; calls [`product.claims`](claims.md), [`product.fail`](fail.md).

TypeScript: `Database["product"]["Functions"]["actor"]`.

Defined in: `20261105010300_product_api.sql`.
