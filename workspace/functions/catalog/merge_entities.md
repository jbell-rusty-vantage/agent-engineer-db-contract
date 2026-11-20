---
id: "fn:catalog.merge_entities(uuid,uuid,uuid,text,text,uuid)"
kind: function
schema: catalog
name: merge_entities
domain: identity
lens: corpus
overloads: ["fn:catalog.merge_entities(uuid,uuid,uuid,text,text,uuid)"]
security: definer
volatility: volatile
executors: [executor_service, service_role]
raises: ["merge: % is not a reason for a merge", "merge: a record cannot be merged into itself", "merge: both records must be of the same kind (% and %)", "merge: no record %", "merge: record % is % and cannot be merged again", "merge: the winner % is %, not active", no open knowledge batch]
touches: { reads: [catalog.identity_move, catalog.relationship, temporal.correction_reason, temporal.segment, temporal.stream], writes: [catalog.entity, catalog.entity_alias, catalog.entity_identifier, catalog.entity_merge, temporal.event] }
tokens: [catalog, merge_entities, catalog.merge_entities]
defined_in: ["20261119120000_build09_rv01_change_reasons_identity_proposals.sql"]
workspace_fingerprint: "sha256:cb1a65412d0fb43423d4f775d78507ab4b320e27f820adab0423446aac89f036"
---
# catalog.merge_entities

Domain `identity`, lens `corpus`.

## merge_entities(uuid, uuid, uuid, text, text, uuid) → jsonb

function, volatile, security definer, language plpgsql, config `search_path=""`. Merge a duplicate record into its twin, inside an open knowledge batch. Facts and edges close on the loser and reopen on the winner as corrections (duplicate_record); where both hold a fact for the same time the winner's stays. Identifiers, names and other references move; rows a table refuses to change stay and are logged. Same kind only. Undo with catalog.undo_merge.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_loser` | `uuid` | — | — |
| `p_winner` | `uuid` | — | — |
| `p_receipt` | `uuid` | — | — |
| `p_reason` | `text` | `'duplicate_record'::text` | — |
| `p_note` | `text` | `NULL::text` | — |
| `p_proposal` | `uuid` | `NULL::uuid` | — |

Execute: `executor_service`, `service_role`.

Raises (mechanically extracted): `merge: % is not a reason for a merge`; `merge: a record cannot be merged into itself`; `merge: both records must be of the same kind (% and %)`; `merge: no record %`; `merge: record % is % and cannot be merged again`; `merge: the winner % is %, not active`; `no open knowledge batch`.

Touches (best effort): reads [`catalog.identity_move`](../../relations/catalog/identity_move.md), [`catalog.relationship`](../../relations/catalog/relationship.md), [`temporal.correction_reason`](../../relations/temporal/correction_reason.md), [`temporal.segment`](../../relations/temporal/segment.md), [`temporal.stream`](../../relations/temporal/stream.md); writes [`catalog.entity`](../../relations/catalog/entity.md), [`catalog.entity_alias`](../../relations/catalog/entity_alias.md), [`catalog.entity_identifier`](../../relations/catalog/entity_identifier.md), [`catalog.entity_merge`](../../relations/catalog/entity_merge.md), [`temporal.event`](../../relations/temporal/event.md); calls [`catalog._ensure_stream`](_ensure_stream.md), [`catalog._log_move`](_log_move.md), [`catalog._move_relationship`](_move_relationship.md), [`catalog._move_segment`](_move_segment.md), [`catalog._repoint_references`](_repoint_references.md), [`temporal.current_k`](../temporal/current_k.md), [`util.current_tenant_id`](../util/current_tenant_id.md), [`util.uuidv7`](../util/uuidv7.md).

TypeScript: `Database["catalog"]["Functions"]["merge_entities"]`.

Defined in: `20261119120000_build09_rv01_change_reasons_identity_proposals.sql`.
