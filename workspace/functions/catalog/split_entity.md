---
id: "fn:catalog.split_entity(uuid,jsonb,uuid,text,text,uuid,bool)"
kind: function
schema: catalog
name: split_entity
domain: identity
lens: corpus
overloads: ["fn:catalog.split_entity(uuid,jsonb,uuid,text,text,uuid,bool)"]
security: definer
volatility: volatile
executors: [executor_service, service_role]
raises: [no open knowledge batch, "split: % is not a closed edge of the mixed record", "split: % is not a current edge of the mixed record", "split: % is not a fact stream of the mixed record", "split: % is not a reason for a split", "split: % is not an identifier of the mixed record", "split: % is not the edge that replaced it on the part", "split: a part cannot be the mixed record itself", "split: no part record %", "split: no record %", "split: p_parts is an array of at least one part", "split: part % must be an active record of kind %", "split: record % is %, not active"]
touches: { reads: [catalog.identity_move, temporal.correction_reason, temporal.segment, temporal.stream], writes: [catalog.entity, catalog.entity_identifier, catalog.entity_split, catalog.entity_split_part, catalog.relationship] }
tokens: [catalog, split_entity, catalog.split_entity]
defined_in: ["20261119120000_build09_rv01_change_reasons_identity_proposals.sql"]
workspace_fingerprint: "sha256:db20bac4d9e82d9b94cd2f3b580d4c145bcc3820969fdd572c6e7868ecca53fd"
---
# catalog.split_entity

Domain `identity`, lens `corpus`.

## split_entity(uuid, jsonb, uuid, text, text, uuid, boolean) → jsonb

function, volatile, security definer, language plpgsql, config `search_path=""`. Split a record that mixed several things, inside an open knowledge batch. Each part names the edges, fact streams and identifiers that move to it (as corrections, wrong_entity); "adopt" records moves made earlier by hand; "references":"all" repoints every other table to that part. p_retire_source retires a record that was nothing but the mix.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_source` | `uuid` | — | — |
| `p_parts` | `jsonb` | — | — |
| `p_receipt` | `uuid` | — | — |
| `p_reason` | `text` | `'mixed_record'::text` | — |
| `p_note` | `text` | `NULL::text` | — |
| `p_proposal` | `uuid` | `NULL::uuid` | — |
| `p_retire_source` | `boolean` | `false` | — |

Execute: `executor_service`, `service_role`.

Raises (mechanically extracted): `no open knowledge batch`; `split: % is not a closed edge of the mixed record`; `split: % is not a current edge of the mixed record`; `split: % is not a fact stream of the mixed record`; `split: % is not a reason for a split`; `split: % is not an identifier of the mixed record`; `split: % is not the edge that replaced it on the part`; `split: a part cannot be the mixed record itself`; `split: no part record %`; `split: no record %`; `split: p_parts is an array of at least one part`; `split: part % must be an active record of kind %`; `split: record % is %, not active`.

Touches (best effort): reads [`catalog.identity_move`](../../relations/catalog/identity_move.md), [`temporal.correction_reason`](../../relations/temporal/correction_reason.md), [`temporal.segment`](../../relations/temporal/segment.md), [`temporal.stream`](../../relations/temporal/stream.md); writes [`catalog.entity`](../../relations/catalog/entity.md), [`catalog.entity_identifier`](../../relations/catalog/entity_identifier.md), [`catalog.entity_split`](../../relations/catalog/entity_split.md), [`catalog.entity_split_part`](../../relations/catalog/entity_split_part.md), [`catalog.relationship`](../../relations/catalog/relationship.md); calls [`catalog._ensure_stream`](_ensure_stream.md), [`catalog._log_move`](_log_move.md), [`catalog._move_relationship`](_move_relationship.md), [`catalog._move_segment`](_move_segment.md), [`catalog._repoint_references`](_repoint_references.md), [`temporal.current_k`](../temporal/current_k.md), [`util.current_tenant_id`](../util/current_tenant_id.md), [`util.uuidv7`](../util/uuidv7.md).

TypeScript: `Database["catalog"]["Functions"]["split_entity"]`.

Defined in: `20261119120000_build09_rv01_change_reasons_identity_proposals.sql`.
