---
id: "fn:api.hybrid_knowledge_search_1536(uuid,text,halfvec,jsonb,int4,int4,int4,text[],uuid[],text[],text[],timestamptz,int8,int2,uuid)"
kind: function
schema: api
name: hybrid_knowledge_search_1536
domain: api-surface
overloads: ["fn:api.hybrid_knowledge_search_1536(uuid,text,halfvec,jsonb,int4,int4,int4,text[],uuid[],text[],text[],timestamptz,int8,int2,uuid)"]
security: definer
volatility: volatile
executors: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: [query text length must be between 1 and 4096, result/candidate/RRF bounds are invalid, unsupported hard filter, valid app.tenant_id context is required, vector-space version is not actively published for this tenant]
touches: { reads: [retrieval.space_publication, retrieval.vector_item, retrieval.vector_item_embedding_1536, retrieval.vector_space, retrieval.vector_space_version, retrieval.vector_store_space], writes: [] }
tokens: [api, hybrid_knowledge_search_1536, api.hybrid_knowledge_search_1536]
defined_in: ["20260903010400_atomic_publication_and_hybrid_retrieval.sql", "20260912011000_km_10_api.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# api.hybrid_knowledge_search_1536

Domain `api-surface`.

## hybrid_knowledge_search_1536(uuid, text, halfvec, jsonb, integer, integer, integer, text[], uuid[], text[], text[], timestamp with time zone, bigint, smallint, uuid) → TABLE(vector_item_id uuid, search_projection_id uuid, search_text text, source_kind text, fused_score double precision, channel_scores jsonb)

function, volatile, security definer, language plpgsql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_vector_space_version_id` | `uuid` | — | — |
| `p_query_text` | `text` | — | — |
| `p_query_embedding` | `halfvec` | — | — |
| `p_filters` | `jsonb` | `'{}'::jsonb` | — |
| `p_result_limit` | `integer` | `20` | — |
| `p_candidate_limit` | `integer` | `100` | — |
| `p_rrf_k` | `integer` | `60` | — |
| `p_spaces` | `text[]` | `NULL::text[]` | — |
| `p_entity_ids` | `uuid[]` | `NULL::uuid[]` | — |
| `p_document_types` | `text[]` | `NULL::text[]` | — |
| `p_content_kinds` | `text[]` | `NULL::text[]` | — |
| `p_as_of` | `timestamp with time zone` | `NULL::timestamp with time zone` | — |
| `p_knowledge_seq` | `bigint` | `NULL::bigint` | — |
| `p_min_assurance` | `smallint` | `NULL::smallint` | — |
| `p_publication_id` | `uuid` | `NULL::uuid` | — |

Execute: `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `query text length must be between 1 and 4096`; `result/candidate/RRF bounds are invalid`; `unsupported hard filter`; `valid app.tenant_id context is required`; `vector-space version is not actively published for this tenant`.

Touches (best effort): reads [`retrieval.space_publication`](../../relations/retrieval/space_publication.md), [`retrieval.vector_item`](../../relations/retrieval/vector_item.md), [`retrieval.vector_item_embedding_1536`](../../relations/retrieval/vector_item_embedding_1536.md), [`retrieval.vector_space`](../../relations/retrieval/vector_space.md), [`retrieval.vector_space_version`](../../relations/retrieval/vector_space_version.md), [`retrieval.vector_store_space`](../../relations/retrieval/vector_store_space.md); writes —; calls [`util.current_tenant_id`](../util/current_tenant_id.md).

Named queries: `q:retrieval.hybrid_search`.

TypeScript: `Database["api"]["Functions"]["hybrid_knowledge_search_1536"]`.

Defined in: `20260903010400_atomic_publication_and_hybrid_retrieval.sql`, `20260912011000_km_10_api.sql`.
