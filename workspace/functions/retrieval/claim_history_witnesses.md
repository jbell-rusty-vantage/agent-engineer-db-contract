---
id: "fn:retrieval.claim_history_witnesses(uuid,int8)"
kind: function
schema: retrieval
name: claim_history_witnesses
domain: retrieval
overloads: ["fn:retrieval.claim_history_witnesses(uuid,int8)"]
security: definer
volatility: stable
executors: [control_plane, executor_service, service_role]
raises: []
touches: { reads: [corpus.relationship, evidence.segment_support, temporal.event, temporal.event_occurrence, temporal.knowledge_head, temporal.segment, temporal.stream], writes: [] }
tokens: [retrieval, claim_history_witnesses, retrieval.claim_history_witnesses]
defined_in: ["20260914011100_retrieval_history.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# retrieval.claim_history_witnesses

Domain `retrieval`.

## claim_history_witnesses(uuid, bigint) → TABLE(claim_id uuid, segment_id uuid, event_occurrence_id uuid, support_id uuid, entity_ids uuid[], world_interval tstzrange, k_from bigint, k_to bigint)

function, stable, security definer, language sql, config `search_path=""`. Accepted temporal witnesses of a claim at knowledge sequence K with their world intervals and entity anchors.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_claim` | `uuid` | — | — |
| `p_k` | `bigint` | — | — |

Execute: `control_plane`, `executor_service`, `service_role`.

Touches (best effort): reads [`corpus.relationship`](../../relations/corpus/relationship.md), [`evidence.segment_support`](../../relations/evidence/segment_support.md), [`temporal.event`](../../relations/temporal/event.md), [`temporal.event_occurrence`](../../relations/temporal/event_occurrence.md), [`temporal.knowledge_head`](../../relations/temporal/knowledge_head.md), [`temporal.segment`](../../relations/temporal/segment.md), [`temporal.stream`](../../relations/temporal/stream.md); writes —; calls [`util.current_tenant_id`](../util/current_tenant_id.md).

TypeScript: `Database["retrieval"]["Functions"]["claim_history_witnesses"]`.

Defined in: `20260914011100_retrieval_history.sql`.
