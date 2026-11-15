---
id: "fn:product.can_read_offer(distribution_offer,uuid)"
kind: function
schema: product
name: can_read_offer
domain: product-operations
lens: ours
overloads: ["fn:product.can_read_offer(distribution_offer,uuid)"]
security: invoker
volatility: stable
executors: []
raises: []
touches: { reads: [authoring.distribution, authoring.distribution_member, learning.enrollment, learning.release_adoption], writes: [] }
tokens: [product, can_read_offer, product.can_read_offer]
defined_in: ["20261105010300_product_api.sql"]
workspace_fingerprint: "sha256:195a7bf46350274849f7ac517bb02381bbf8851afdacebee2c17dad0d348934c"
---
# product.can_read_offer

Domain `product-operations`, lens `ours`.

## can_read_offer(authoring.distribution_offer, uuid) → boolean

function, stable, security invoker, language plpgsql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `o` | `authoring.distribution_offer` | — | — |
| `p` | `uuid` | — | — |

Execute: no configured role.

Touches (best effort): reads [`authoring.distribution`](../../relations/authoring/distribution.md), [`authoring.distribution_member`](../../relations/authoring/distribution_member.md), [`learning.enrollment`](../../relations/learning/enrollment.md), [`learning.release_adoption`](../../relations/learning/release_adoption.md); writes —; calls [`product.band`](band.md), [`product.band_rank`](band_rank.md), [`product.policy`](policy.md), [`product.role_in`](role_in.md).

TypeScript: `Database["product"]["Functions"]["can_read_offer"]`.

Defined in: `20261105010300_product_api.sql`.
