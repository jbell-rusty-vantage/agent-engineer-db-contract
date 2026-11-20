---
id: "fn:api.changes_since(timestamptz,text[],text[],text[])"
kind: function
schema: api
name: changes_since
domain: api-surface
lens: corpus
overloads: ["fn:api.changes_since(timestamptz,text[],text[],text[])"]
security: definer
volatility: stable
executors: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [catalog.entity, catalog.entity_merge, catalog.entity_split, catalog.entity_split_part, catalog.identity_move, catalog.relationship, content.document, content.document_node, content.document_version, content.unit_change, temporal.event, temporal.event_occurrence, temporal.knowledge_batch, temporal.segment, temporal.stream], writes: [] }
tokens: [api, changes_since, api.changes_since]
defined_in: ["20261108120000_build08_r2_knowledge_continuum.sql", "20261109130000_build08_loop2_numbers_compute_apis.sql", "20261119120000_build09_rv01_change_reasons_identity_proposals.sql", part4_views_seeds.sql]
workspace_fingerprint: "sha256:cb1a65412d0fb43423d4f775d78507ab4b320e27f820adab0423446aac89f036"
---
# api.changes_since

Domain `api-surface`, lens `corpus`.

## changes_since(timestamp with time zone, text[], text[], text[]) → TABLE(change_source text, change_kind text, learned_at timestamp with time zone, knowledge_seq bigint, world_from timestamp with time zone, subject_entity_id uuid, subject text, stream_kind text, scope_key text, old_value jsonb, new_value jsonb, document_id uuid, document_title text, logical_key text, unit_kind text, changed_attributes jsonb, claim_id uuid, revision_kind text, correction_reason text, cause_event_id uuid, cause_event_kind text)

function, stable, security definer, language sql, config `search_path=""`. What we learned after p_since: facts (each a world_change or a correction with its reason and cause event; cut pieces are not listed), events, unit changes, edges opened and closed (scope_key carries the relationship kind), and merges and splits of records.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_since` | `timestamp with time zone` | — | — |
| `p_stream_kinds` | `text[]` | `NULL::text[]` | — |
| `p_entity_kinds` | `text[]` | `NULL::text[]` | — |
| `p_document_types` | `text[]` | `NULL::text[]` | — |

Execute: `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Touches (best effort): reads [`catalog.entity`](../../relations/catalog/entity.md), [`catalog.entity_merge`](../../relations/catalog/entity_merge.md), [`catalog.entity_split`](../../relations/catalog/entity_split.md), [`catalog.entity_split_part`](../../relations/catalog/entity_split_part.md), [`catalog.identity_move`](../../relations/catalog/identity_move.md), [`catalog.relationship`](../../relations/catalog/relationship.md), [`content.document`](../../relations/content/document.md), [`content.document_node`](../../relations/content/document_node.md), [`content.document_version`](../../relations/content/document_version.md), [`content.unit_change`](../../relations/content/unit_change.md), [`temporal.event`](../../relations/temporal/event.md), [`temporal.event_occurrence`](../../relations/temporal/event_occurrence.md), [`temporal.knowledge_batch`](../../relations/temporal/knowledge_batch.md), [`temporal.segment`](../../relations/temporal/segment.md), [`temporal.stream`](../../relations/temporal/stream.md); writes —; calls [`util.current_tenant_id`](../util/current_tenant_id.md).

Named queries: `q:facts.changes_since`.

TypeScript: `Database["api"]["Functions"]["changes_since"]`.

Defined in: `20261108120000_build08_r2_knowledge_continuum.sql`, `20261109130000_build08_loop2_numbers_compute_apis.sql`, `20261119120000_build09_rv01_change_reasons_identity_proposals.sql`, `part4_views_seeds.sql`.
