---
id: "fn:api.hybrid_knowledge_search_history_1536(uuid,text,halfvec,jsonb,int4,int4,int4,int8,uuid[],timestamptz,timestamptz,timestamptz,uuid)"
kind: function
schema: api
name: hybrid_knowledge_search_history_1536
domain: api-surface
overloads: ["fn:api.hybrid_knowledge_search_history_1536(uuid,text,halfvec,jsonb,int4,int4,int4,int8,uuid[],timestamptz,timestamptz,timestamptz,uuid)"]
security: definer
volatility: volatile
executors: [app_reader, authenticated, control_plane, executor_service, service_role]
raises: [currently authorized publication required, invalid bounded history query, knowledge sequence is outside sealed history, tenant context required]
touches: { reads: [retrieval.search_projection, retrieval.vector_item, retrieval.vector_item_embedding_1536, temporal.knowledge_head], writes: [] }
tokens: [api, hybrid_knowledge_search_history_1536, api.hybrid_knowledge_search_history_1536]
defined_in: ["20260914011100_retrieval_history.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# api.hybrid_knowledge_search_history_1536

Domain `api-surface`.

## hybrid_knowledge_search_history_1536(uuid, text, halfvec, jsonb, integer, integer, integer, bigint, uuid[], timestamp with time zone, timestamp with time zone, timestamp with time zone, uuid) → TABLE(vector_item_id uuid, search_projection_id uuid, search_text text, source_kind text, fused_score double precision, channel_scores jsonb)

function, volatile, security definer, language plpgsql, config `search_path=""`. Bounded historical hybrid retrieval at an explicit knowledge sequence and optional world scope. Requires a currently authorized publication and canonical projection eligibility.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_vector_space_version_id` | `uuid` | — | — |
| `p_query_text` | `text` | — | — |
| `p_query_embedding` | `halfvec` | — | — |
| `p_filters` | `jsonb` | `'{}'::jsonb` | — |
| `p_result_limit` | `integer` | `20` | — |
| `p_candidate_limit` | `integer` | `100` | — |
| `p_rrf_k` | `integer` | `60` | — |
| `p_knowledge_seq` | `bigint` | `NULL::bigint` | — |
| `p_entity_ids` | `uuid[]` | `NULL::uuid[]` | — |
| `p_world_at` | `timestamp with time zone` | `NULL::timestamp with time zone` | — |
| `p_world_from` | `timestamp with time zone` | `NULL::timestamp with time zone` | — |
| `p_world_to` | `timestamp with time zone` | `NULL::timestamp with time zone` | — |
| `p_publication_id` | `uuid` | `NULL::uuid` | — |

Execute: `app_reader`, `authenticated`, `control_plane`, `executor_service`, `service_role`.

Raises (mechanically extracted): `currently authorized publication required`; `invalid bounded history query`; `knowledge sequence is outside sealed history`; `tenant context required`.

Touches (best effort): reads [`retrieval.search_projection`](../../relations/retrieval/search_projection.md), [`retrieval.vector_item`](../../relations/retrieval/vector_item.md), [`retrieval.vector_item_embedding_1536`](../../relations/retrieval/vector_item_embedding_1536.md), [`temporal.knowledge_head`](../../relations/temporal/knowledge_head.md); writes —; calls [`retrieval.history_projection_matches`](../retrieval/history_projection_matches.md), [`retrieval.history_publication_authorized`](../retrieval/history_publication_authorized.md), [`util.current_tenant_id`](../util/current_tenant_id.md).

TypeScript: `Database["api"]["Functions"]["hybrid_knowledge_search_history_1536"]`.

Defined in: `20260914011100_retrieval_history.sql`.
