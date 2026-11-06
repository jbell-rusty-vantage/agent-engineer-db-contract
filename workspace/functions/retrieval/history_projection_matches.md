---
id: "fn:retrieval.history_projection_matches(uuid,int8,uuid[],timestamptz,timestamptz,timestamptz)"
kind: function
schema: retrieval
name: history_projection_matches
domain: retrieval
overloads: ["fn:retrieval.history_projection_matches(uuid,int8,uuid[],timestamptz,timestamptz,timestamptz)"]
security: definer
volatility: stable
executors: []
raises: []
touches: { reads: [content.document_summary, content.document_summary_source, corpus.entity, evidence.claim, evidence.claim_record, evidence.claim_subject, evidence.segment_support, knowledge.record, orchestration.operation_intent, orchestration.operation_receipt, retrieval.chunk_claim_link, retrieval.chunk_entity_mention, retrieval.chunk_set, retrieval.chunk_span, retrieval.projection_target, retrieval.retrieval_chunk, retrieval.search_projection, retrieval.search_projection_chunk_support, temporal.event_occurrence, temporal.knowledge_batch, temporal.segment], writes: [] }
tokens: [retrieval, history_projection_matches, retrieval.history_projection_matches]
defined_in: ["20260914011100_retrieval_history.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# retrieval.history_projection_matches

Domain `retrieval`.

## history_projection_matches(uuid, bigint, uuid[], timestamp with time zone, timestamp with time zone, timestamp with time zone) → boolean

function, stable, security definer, language sql, config `search_path=""`. Fail-closed eligibility of one search projection at K under optional entity and world scope. Every declared chunk support must be authorized; a faithful section without an admitted claim is not historically eligible.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_projection` | `uuid` | — | — |
| `p_k` | `bigint` | — | — |
| `p_entities` | `uuid[]` | — | — |
| `p_at` | `timestamp with time zone` | — | — |
| `p_from` | `timestamp with time zone` | — | — |
| `p_to` | `timestamp with time zone` | — | — |

Execute: no configured role.

Touches (best effort): reads [`content.document_summary`](../../relations/content/document_summary.md), [`content.document_summary_source`](../../relations/content/document_summary_source.md), [`corpus.entity`](../../relations/corpus/entity.md), [`evidence.claim`](../../relations/evidence/claim.md), [`evidence.claim_record`](../../relations/evidence/claim_record.md), [`evidence.claim_subject`](../../relations/evidence/claim_subject.md), [`evidence.segment_support`](../../relations/evidence/segment_support.md), [`knowledge.record`](../../relations/knowledge/record.md), [`orchestration.operation_intent`](../../relations/orchestration/operation_intent.md), [`orchestration.operation_receipt`](../../relations/orchestration/operation_receipt.md), [`retrieval.chunk_claim_link`](../../relations/retrieval/chunk_claim_link.md), [`retrieval.chunk_entity_mention`](../../relations/retrieval/chunk_entity_mention.md), [`retrieval.chunk_set`](../../relations/retrieval/chunk_set.md), [`retrieval.chunk_span`](../../relations/retrieval/chunk_span.md), [`retrieval.projection_target`](../../relations/retrieval/projection_target.md), [`retrieval.retrieval_chunk`](../../relations/retrieval/retrieval_chunk.md), [`retrieval.search_projection`](../../relations/retrieval/search_projection.md), [`retrieval.search_projection_chunk_support`](../../relations/retrieval/search_projection_chunk_support.md), [`temporal.event_occurrence`](../../relations/temporal/event_occurrence.md), [`temporal.knowledge_batch`](../../relations/temporal/knowledge_batch.md), [`temporal.segment`](../../relations/temporal/segment.md); writes —; calls [`retrieval.claim_history_witnesses`](claim_history_witnesses.md), [`retrieval.history_claim_authorized`](history_claim_authorized.md), [`retrieval.history_receipt_k`](history_receipt_k.md), [`retrieval.history_representation_authorized`](history_representation_authorized.md), [`retrieval.history_world_matches`](history_world_matches.md), [`util.current_tenant_id`](../util/current_tenant_id.md).

TypeScript: `Database["retrieval"]["Functions"]["history_projection_matches"]`.

Defined in: `20260914011100_retrieval_history.sql`.
