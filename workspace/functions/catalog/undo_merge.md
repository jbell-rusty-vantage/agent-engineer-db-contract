---
id: "fn:catalog.undo_merge(uuid,uuid,text)"
kind: function
schema: catalog
name: undo_merge
domain: identity
lens: corpus
overloads: ["fn:catalog.undo_merge(uuid,uuid,text)"]
security: definer
volatility: volatile
executors: [executor_service, service_role]
raises: [no open knowledge batch, the moved fact was replaced since the merge, "undo: no merge %", "undo: the record is no longer merged into that winner"]
touches: { reads: [catalog.entity_identifier, temporal.segment], writes: [catalog.entity, catalog.entity_alias, catalog.entity_merge, catalog.identity_move, catalog.relationship, temporal.event] }
tokens: [catalog, undo_merge, catalog.undo_merge]
defined_in: ["20261119120000_build09_rv01_change_reasons_identity_proposals.sql"]
workspace_fingerprint: "sha256:cb1a65412d0fb43423d4f775d78507ab4b320e27f820adab0423446aac89f036"
---
# catalog.undo_merge

Domain `identity`, lens `corpus`.

## undo_merge(uuid, uuid, text) → jsonb

function, volatile, security definer, language plpgsql, config `search_path=""`. Reverse a merge from its move log, inside an open knowledge batch. History keeps both the merge and its undoing.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_merge` | `uuid` | — | — |
| `p_receipt` | `uuid` | — | — |
| `p_note` | `text` | `NULL::text` | — |

Execute: `executor_service`, `service_role`.

Raises (mechanically extracted): `no open knowledge batch`; `the moved fact was replaced since the merge`; `undo: no merge %`; `undo: the record is no longer merged into that winner`.

Touches (best effort): reads [`catalog.entity_identifier`](../../relations/catalog/entity_identifier.md), [`temporal.segment`](../../relations/temporal/segment.md); writes [`catalog.entity`](../../relations/catalog/entity.md), [`catalog.entity_alias`](../../relations/catalog/entity_alias.md), [`catalog.entity_merge`](../../relations/catalog/entity_merge.md), [`catalog.identity_move`](../../relations/catalog/identity_move.md), [`catalog.relationship`](../../relations/catalog/relationship.md), [`temporal.event`](../../relations/temporal/event.md); calls [`catalog._carry_relationship_streams`](_carry_relationship_streams.md), [`catalog._move_relationship`](_move_relationship.md), [`catalog._move_segment`](_move_segment.md), [`catalog._reopen_segment`](_reopen_segment.md), [`temporal.current_k`](../temporal/current_k.md), [`util.current_tenant_id`](../util/current_tenant_id.md).

TypeScript: `Database["catalog"]["Functions"]["undo_merge"]`.

Defined in: `20261119120000_build09_rv01_change_reasons_identity_proposals.sql`.
