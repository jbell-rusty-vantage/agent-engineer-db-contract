---
id: "fn:retrieval.index_text_item(text,text,uuid,text,text,int2,text,uuid,uuid[],text,text,uuid,uuid,text,tstzrange,int8,uuid,text,timestamptz,int4,int4,text,int2)"
kind: function
schema: retrieval
name: index_text_item
domain: library
lens: corpus
overloads: ["fn:retrieval.index_text_item(text,text,uuid,text,text,int2,text,uuid,uuid[],text,text,uuid,uuid,text,tstzrange,int8,uuid,text,timestamptz,int4,int4,text,int2)"]
security: definer
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: [empty text cannot be indexed, private items need a workspace, "unknown vector space %"]
touches: { reads: [catalog.entity, retrieval.projection_procedure, retrieval.vector_space, retrieval.vector_space_version], writes: [retrieval.projection_target, retrieval.search_projection, retrieval.vector_item] }
tokens: [retrieval, index_text_item, retrieval.index_text_item]
defined_in: ["20261108120000_build08_r2_knowledge_continuum.sql", "20261110140000_build08_loop3_libraries_talks_capabilities.sql", part3_retrieval.sql]
workspace_fingerprint: "sha256:1632162dedd33f48177992e3e5ad79c363556a7b68ee650fc7e68b2bb3855da4"
---
# retrieval.index_text_item

Domain `library`, lens `corpus`.

## index_text_item(text, text, uuid, text, text, smallint, text, uuid, uuid[], text, text, uuid, uuid, text, tstzrange, bigint, uuid, text, timestamp with time zone, integer, integer, text, smallint) → uuid

function, volatile, security definer, language plpgsql, config `search_path=""`. The one way a text becomes searchable: upserts the projection target, the search projection and an active vector item in the named space with lens/tier/facets. Idempotent on identical text.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_space_slug` | `text` | — | — |
| `p_target_kind` | `text` | — | — |
| `p_target_id` | `uuid` | — | — |
| `p_text` | `text` | — | — |
| `p_lens` | `text` | — | — |
| `p_source_tier` | `smallint` | — | — |
| `p_content_kind` | `text` | — | — |
| `p_entity_id` | `uuid` | `NULL::uuid` | — |
| `p_secondary_entity_ids` | `uuid[]` | `'{}'::uuid[]` | — |
| `p_document_type_code` | `text` | `NULL::text` | — |
| `p_unit_kind` | `text` | `NULL::text` | — |
| `p_document_id` | `uuid` | `NULL::uuid` | — |
| `p_document_version_id` | `uuid` | `NULL::uuid` | — |
| `p_source_role_code` | `text` | `NULL::text` | — |
| `p_valid_during` | `tstzrange` | `NULL::tstzrange` | — |
| `p_knowledge_seq` | `bigint` | `NULL::bigint` | — |
| `p_workspace_id` | `uuid` | `NULL::uuid` | — |
| `p_language` | `text` | `'en'::text` | — |
| `p_observed_at` | `timestamp with time zone` | `NULL::timestamp with time zone` | — |
| `p_start_ms` | `integer` | `NULL::integer` | — |
| `p_end_ms` | `integer` | `NULL::integer` | — |
| `p_contextual_prefix` | `text` | `''::text` | — |
| `p_assurance_rank` | `smallint` | `NULL::smallint` | — |

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `empty text cannot be indexed`; `private items need a workspace`; `unknown vector space %`.

Touches (best effort): reads [`catalog.entity`](../../relations/catalog/entity.md), [`retrieval.projection_procedure`](../../relations/retrieval/projection_procedure.md), [`retrieval.vector_space`](../../relations/retrieval/vector_space.md), [`retrieval.vector_space_version`](../../relations/retrieval/vector_space_version.md); writes [`retrieval.projection_target`](../../relations/retrieval/projection_target.md), [`retrieval.search_projection`](../../relations/retrieval/search_projection.md), [`retrieval.vector_item`](../../relations/retrieval/vector_item.md); calls [`util.default_tenant_id`](../util/default_tenant_id.md).

TypeScript: `Database["retrieval"]["Functions"]["index_text_item"]`.

Defined in: `20261108120000_build08_r2_knowledge_continuum.sql`, `20261110140000_build08_loop3_libraries_talks_capabilities.sql`, `part3_retrieval.sql`.
