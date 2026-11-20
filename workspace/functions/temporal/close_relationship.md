---
id: "fn:temporal.close_relationship(uuid,text,text,uuid,timestamptz,uuid,uuid)"
kind: function
schema: temporal
name: close_relationship
domain: temporal-facts
lens: corpus
overloads: ["fn:temporal.close_relationship(uuid,text,text,uuid,timestamptz,uuid,uuid)"]
security: definer
volatility: volatile
executors: [executor_service, service_role]
raises: [a correction reason belongs to a correction, a world ending of a temporal relationship needs p_world_end, closed kind is world_change or correction, correction requires a reason, current relationship not found, no open knowledge batch]
touches: { reads: [taxonomy.relationship_kind, temporal.correction_reason, temporal.segment, temporal.stream], writes: [catalog.relationship] }
tokens: [temporal, close_relationship, temporal.close_relationship]
defined_in: ["20261119120000_build09_rv01_change_reasons_identity_proposals.sql"]
workspace_fingerprint: "sha256:cb1a65412d0fb43423d4f775d78507ab4b320e27f820adab0423446aac89f036"
---
# temporal.close_relationship

Domain `temporal-facts`, lens `corpus`.

## close_relationship(uuid, text, text, uuid, timestamp with time zone, uuid, uuid) → void

function, volatile, security definer, language plpgsql, config `search_path=""`. End an edge. correction: the edge was wrong; it leaves current knowledge with a coded reason. world_change: the edge was true and ended; an edge that carries world time keeps its row and its relationship_active fact ends at p_world_end with the cause event.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_relationship` | `uuid` | — | — |
| `p_closed_kind` | `text` | — | — |
| `p_reason` | `text` | `NULL::text` | — |
| `p_event` | `uuid` | `NULL::uuid` | — |
| `p_world_end` | `timestamp with time zone` | `NULL::timestamp with time zone` | — |
| `p_extent` | `uuid` | `NULL::uuid` | — |
| `p_claim` | `uuid` | `NULL::uuid` | — |

Execute: `executor_service`, `service_role`.

Raises (mechanically extracted): `a correction reason belongs to a correction`; `a world ending of a temporal relationship needs p_world_end`; `closed kind is world_change or correction`; `correction requires a reason`; `current relationship not found`; `no open knowledge batch`.

Touches (best effort): reads [`taxonomy.relationship_kind`](../../relations/taxonomy/relationship_kind.md), [`temporal.correction_reason`](../../relations/temporal/correction_reason.md), [`temporal.segment`](../../relations/temporal/segment.md), [`temporal.stream`](../../relations/temporal/stream.md); writes [`catalog.relationship`](../../relations/catalog/relationship.md); calls [`temporal.assert_state`](assert_state.md), [`temporal.close_segment`](close_segment.md), [`temporal.current_k`](current_k.md), [`util.current_tenant_id`](../util/current_tenant_id.md).

TypeScript: `Database["temporal"]["Functions"]["close_relationship"]`.

Defined in: `20261119120000_build09_rv01_change_reasons_identity_proposals.sql`.
