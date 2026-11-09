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
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [catalog.entity, content.document, content.document_node, content.document_version, content.unit_change, temporal.event, temporal.event_occurrence, temporal.knowledge_batch, temporal.segment, temporal.stream], writes: [] }
tokens: [api, changes_since, api.changes_since]
defined_in: ["20261108120000_build08_r2_knowledge_continuum.sql", part4_views_seeds.sql]
workspace_fingerprint: "sha256:0bdaf1f915461feecb08d7ad5612fcb8db9039b883dd9c6e7e9be6d621251eee"
---
# api.changes_since

Domain `api-surface`, lens `corpus`.

## changes_since(timestamp with time zone, text[], text[], text[]) → TABLE(change_source text, change_kind text, learned_at timestamp with time zone, knowledge_seq bigint, world_from timestamp with time zone, subject_entity_id uuid, subject text, stream_kind text, scope_key text, old_value jsonb, new_value jsonb, document_id uuid, document_title text, logical_key text, unit_kind text, changed_attributes jsonb, claim_id uuid)

function, stable, security definer, language sql, config `search_path=""`. L2 both clocks: what changed since a date, as facts opened/replaced (with the old value), events, and unit-level diffs of refreshed documents; learned_at is when we recorded it, world_from is when it holds in the world.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_since` | `timestamp with time zone` | — | — |
| `p_stream_kinds` | `text[]` | `NULL::text[]` | — |
| `p_entity_kinds` | `text[]` | `NULL::text[]` | — |
| `p_document_types` | `text[]` | `NULL::text[]` | — |

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Touches (best effort): reads [`catalog.entity`](../../relations/catalog/entity.md), [`content.document`](../../relations/content/document.md), [`content.document_node`](../../relations/content/document_node.md), [`content.document_version`](../../relations/content/document_version.md), [`content.unit_change`](../../relations/content/unit_change.md), [`temporal.event`](../../relations/temporal/event.md), [`temporal.event_occurrence`](../../relations/temporal/event_occurrence.md), [`temporal.knowledge_batch`](../../relations/temporal/knowledge_batch.md), [`temporal.segment`](../../relations/temporal/segment.md), [`temporal.stream`](../../relations/temporal/stream.md); writes —; calls [`util.current_tenant_id`](../util/current_tenant_id.md).

Named queries: `q:facts.changes_since`.

TypeScript: `Database["api"]["Functions"]["changes_since"]`.

Defined in: `20261108120000_build08_r2_knowledge_continuum.sql`, `part4_views_seeds.sql`.
