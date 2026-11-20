---
id: "fn:catalog._repoint_references(uuid,uuid,uuid,uuid)"
kind: function
schema: catalog
name: _repoint_references
domain: identity
lens: corpus
overloads: ["fn:catalog._repoint_references(uuid,uuid,uuid,uuid)"]
security: invoker
volatility: volatile
executors: []
raises: []
touches: { reads: [catalog.entity, catalog.entity_alias, catalog.entity_identifier, catalog.entity_merge, catalog.entity_split, catalog.entity_split_part, catalog.relationship, catalog.work, orchestration.operation_receipt_target, temporal.event, temporal.segment, temporal.stream], writes: [] }
tokens: [catalog, _repoint_references, catalog._repoint_references]
defined_in: ["20261119120000_build09_rv01_change_reasons_identity_proposals.sql"]
workspace_fingerprint: "sha256:db20bac4d9e82d9b94cd2f3b580d4c145bcc3820969fdd572c6e7868ecca53fd"
---
# catalog._repoint_references

Domain `identity`, lens `corpus`.

## _repoint_references(uuid, uuid, uuid, uuid) → integer

function, volatile, security invoker, language plpgsql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_from` | `uuid` | — | — |
| `p_to` | `uuid` | — | — |
| `p_merge` | `uuid` | — | — |
| `p_split` | `uuid` | — | — |

Execute: no configured role.

Touches (best effort): reads [`catalog.entity`](../../relations/catalog/entity.md), [`catalog.entity_alias`](../../relations/catalog/entity_alias.md), [`catalog.entity_identifier`](../../relations/catalog/entity_identifier.md), [`catalog.entity_merge`](../../relations/catalog/entity_merge.md), [`catalog.entity_split`](../../relations/catalog/entity_split.md), [`catalog.entity_split_part`](../../relations/catalog/entity_split_part.md), [`catalog.relationship`](../../relations/catalog/relationship.md), [`catalog.work`](../../relations/catalog/work.md), [`orchestration.operation_receipt_target`](../../relations/orchestration/operation_receipt_target.md), [`temporal.event`](../../relations/temporal/event.md), [`temporal.segment`](../../relations/temporal/segment.md), [`temporal.stream`](../../relations/temporal/stream.md); writes —; calls [`catalog._log_move`](_log_move.md), [`catalog._row_key`](_row_key.md).

TypeScript: `Database["catalog"]["Functions"]["_repoint_references"]`.

Defined in: `20261119120000_build09_rv01_change_reasons_identity_proposals.sql`.
