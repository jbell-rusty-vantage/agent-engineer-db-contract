---
id: "fn:api.entity_history(uuid)"
kind: function
schema: api
name: entity_history
domain: identity
lens: corpus
overloads: ["fn:api.entity_history(uuid)"]
security: definer
volatility: stable
executors: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [catalog.entity, catalog.entity_alias, catalog.entity_identifier, catalog.entity_merge, catalog.entity_split, catalog.entity_split_part, catalog.relationship, temporal.event, temporal.event_occurrence, temporal.knowledge_batch, temporal.segment, temporal.stream], writes: [] }
tokens: [api, entity_history, api.entity_history]
defined_in: ["20261119120000_build09_rv01_change_reasons_identity_proposals.sql"]
workspace_fingerprint: "sha256:cb1a65412d0fb43423d4f775d78507ab4b320e27f820adab0423446aac89f036"
---
# api.entity_history

Domain `identity`, lens `corpus`.

## entity_history(uuid) → TABLE(item_kind text, world_from timestamp with time zone, world_to timestamp with time zone, learned_at timestamp with time zone, details jsonb)

function, stable, security definer, language sql, config `search_path=""`. What happened to one identity: names through time, aliases, identifiers, renames and other identity events, successors and stewards with their world intervals, and merges and splits of its record.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_entity` | `uuid` | — | — |

Execute: `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Touches (best effort): reads [`catalog.entity`](../../relations/catalog/entity.md), [`catalog.entity_alias`](../../relations/catalog/entity_alias.md), [`catalog.entity_identifier`](../../relations/catalog/entity_identifier.md), [`catalog.entity_merge`](../../relations/catalog/entity_merge.md), [`catalog.entity_split`](../../relations/catalog/entity_split.md), [`catalog.entity_split_part`](../../relations/catalog/entity_split_part.md), [`catalog.relationship`](../../relations/catalog/relationship.md), [`temporal.event`](../../relations/temporal/event.md), [`temporal.event_occurrence`](../../relations/temporal/event_occurrence.md), [`temporal.knowledge_batch`](../../relations/temporal/knowledge_batch.md), [`temporal.segment`](../../relations/temporal/segment.md), [`temporal.stream`](../../relations/temporal/stream.md); writes —; calls [`catalog.canonical_entity`](../catalog/canonical_entity.md), [`util.current_tenant_id`](../util/current_tenant_id.md).

TypeScript: `Database["api"]["Functions"]["entity_history"]`.

Defined in: `20261119120000_build09_rv01_change_reasons_identity_proposals.sql`.
