---
id: "fn:catalog._move_relationship(uuid,uuid,uuid,text)"
kind: function
schema: catalog
name: _move_relationship
domain: identity
lens: corpus
overloads: ["fn:catalog._move_relationship(uuid,uuid,uuid,text)"]
security: invoker
volatility: volatile
executors: []
raises: []
touches: { reads: [], writes: [catalog.relationship] }
tokens: [catalog, _move_relationship, catalog._move_relationship]
defined_in: ["20261119120000_build09_rv01_change_reasons_identity_proposals.sql"]
workspace_fingerprint: "sha256:db20bac4d9e82d9b94cd2f3b580d4c145bcc3820969fdd572c6e7868ecca53fd"
---
# catalog._move_relationship

Domain `identity`, lens `corpus`.

## _move_relationship(uuid, uuid, uuid, text) → uuid

function, volatile, security invoker, language plpgsql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_relationship` | `uuid` | — | — |
| `p_from` | `uuid` | — | — |
| `p_to` | `uuid` | — | — |
| `p_reason` | `text` | — | — |

Execute: no configured role.

Touches (best effort): reads —; writes [`catalog.relationship`](../../relations/catalog/relationship.md); calls [`catalog._carry_relationship_streams`](_carry_relationship_streams.md), [`temporal.current_k`](../temporal/current_k.md), [`util.current_tenant_id`](../util/current_tenant_id.md).

TypeScript: `Database["catalog"]["Functions"]["_move_relationship"]`.

Defined in: `20261119120000_build09_rv01_change_reasons_identity_proposals.sql`.
