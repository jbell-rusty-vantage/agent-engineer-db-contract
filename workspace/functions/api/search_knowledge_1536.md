---
id: "fn:api.search_knowledge_1536(uuid,halfvec,int4)"
kind: function
schema: api
name: search_knowledge_1536
domain: api-surface
overloads: ["fn:api.search_knowledge_1536(uuid,halfvec,int4)"]
security: definer
volatility: stable
executors: [app_reader, authenticated, service_role]
raises: [p_limit must be between 1 and 200, valid app.tenant_id context is required, vector space version is not published for the active tenant]
touches: { reads: [retrieval.vector_item, retrieval.vector_item_embedding_1536, retrieval.vector_space_version], writes: [] }
tokens: [api, search_knowledge_1536, api.search_knowledge_1536]
defined_in: ["20260903010200_knowledge_runtime_security.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# api.search_knowledge_1536

Domain `api-surface`.

## search_knowledge_1536(uuid, halfvec, integer) → TABLE(vector_item_id uuid, search_projection_id uuid, score double precision, search_text text)

function, stable, security definer, language plpgsql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_vector_space_version_id` | `uuid` | — | — |
| `p_query` | `halfvec` | — | — |
| `p_limit` | `integer` | `20` | — |

Execute: `app_reader`, `authenticated`, `service_role`.

Raises (mechanically extracted): `p_limit must be between 1 and 200`; `valid app.tenant_id context is required`; `vector space version is not published for the active tenant`.

Touches (best effort): reads [`retrieval.vector_item`](../../relations/retrieval/vector_item.md), [`retrieval.vector_item_embedding_1536`](../../relations/retrieval/vector_item_embedding_1536.md), [`retrieval.vector_space_version`](../../relations/retrieval/vector_space_version.md); writes —; calls [`util.current_tenant_id`](../util/current_tenant_id.md).

TypeScript: `Database["api"]["Functions"]["search_knowledge_1536"]`.

Defined in: `20260903010200_knowledge_runtime_security.sql`.
