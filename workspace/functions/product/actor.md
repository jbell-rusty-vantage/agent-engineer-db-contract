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
workspace_fingerprint: "sha256:027ab2b6133d5d59318c478f06d832d89f937e563c387539f37fb3d7668818a8"
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
