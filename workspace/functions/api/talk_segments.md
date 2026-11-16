---
id: "fn:api.talk_segments(uuid,int4,int4,text)"
kind: function
schema: api
name: talk_segments
domain: api-surface
lens: corpus
overloads: ["fn:api.talk_segments(uuid,int4,int4,text)"]
security: definer
volatility: stable
executors: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [catalog.work, content.document, content.document_about_entity, content.document_node, content.document_representation, content.document_version], writes: [] }
tokens: [api, talk_segments, api.talk_segments]
defined_in: ["20261108120000_build08_r2_knowledge_continuum.sql", "20261108120400_build08_r2_fixups4.sql", "20261110140000_build08_loop3_libraries_talks_capabilities.sql", part4_views_seeds.sql]
workspace_fingerprint: "sha256:216c4ae7230478c8e60934da25c852e10680d6caed71a662962ea3c0ac1676d3"
---
# api.talk_segments

Domain `api-surface`, lens `corpus`.

## talk_segments(uuid, integer, integer, text) → TABLE(node_id uuid, unit_kind text, start_ms integer, end_ms integer, slide_n integer, text text, document_id uuid, representation_id uuid, logical_key text, deep_link text)

function, stable, security definer, language sql, config `search_path=""`. Transcript segments, slides and write-up chapters of a talk in time order; deep_link is the video URL at the segment start (the video is a link, never bytes).

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_talk` | `uuid` | — | — |
| `p_from_ms` | `integer` | `NULL::integer` | — |
| `p_to_ms` | `integer` | `NULL::integer` | — |
| `p_query` | `text` | `NULL::text` | — |

Execute: `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Touches (best effort): reads [`catalog.work`](../../relations/catalog/work.md), [`content.document`](../../relations/content/document.md), [`content.document_about_entity`](../../relations/content/document_about_entity.md), [`content.document_node`](../../relations/content/document_node.md), [`content.document_representation`](../../relations/content/document_representation.md), [`content.document_version`](../../relations/content/document_version.md); writes —; calls [`api.timecode_link`](timecode_link.md), [`util.current_tenant_id`](../util/current_tenant_id.md).

Named queries: `q:content.talk_segments`.

TypeScript: `Database["api"]["Functions"]["talk_segments"]`.

Defined in: `20261108120000_build08_r2_knowledge_continuum.sql`, `20261108120400_build08_r2_fixups4.sql`, `20261110140000_build08_loop3_libraries_talks_capabilities.sql`, `part4_views_seeds.sql`.
