---
id: "fn:product.readable_revision(uuid,uuid)"
kind: function
schema: product
name: readable_revision
domain: library
lens: ours
overloads: ["fn:product.readable_revision(uuid,uuid)"]
security: invoker
volatility: stable
executors: []
raises: []
touches: { reads: [authoring.distribution_offer, authoring.release_item, authoring.work_revision], writes: [] }
tokens: [product, readable_revision, product.readable_revision]
defined_in: ["20261105010300_product_api.sql"]
workspace_fingerprint: "sha256:fbf5703bf7a6f6131c452444ee949f1feec1bbe813c78d772fb3886b510815b9"
---
# product.readable_revision

Domain `library`, lens `ours`.

## readable_revision(uuid, uuid) → boolean

function, stable, security invoker, language sql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `rid` | `uuid` | — | — |
| `p` | `uuid` | — | — |

Execute: no configured role.

Touches (best effort): reads [`authoring.distribution_offer`](../../relations/authoring/distribution_offer.md), [`authoring.release_item`](../../relations/authoring/release_item.md), [`authoring.work_revision`](../../relations/authoring/work_revision.md); writes —; calls [`product.can_read_offer`](can_read_offer.md), [`product.role_in`](role_in.md).

TypeScript: `Database["product"]["Functions"]["readable_revision"]`.

Defined in: `20261105010300_product_api.sql`.
