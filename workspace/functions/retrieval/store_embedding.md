---
id: "fn:retrieval.store_embedding(uuid,halfvec,text)"
kind: function
schema: retrieval
name: store_embedding
domain: retrieval
lens: corpus
overloads: ["fn:retrieval.store_embedding(uuid,halfvec,text)"]
security: definer
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: ["unknown vector item %"]
touches: { reads: [retrieval.vector_item, retrieval.vector_space, retrieval.vector_space_version], writes: [retrieval.vector_item_embedding_1536] }
tokens: [retrieval, store_embedding, retrieval.store_embedding]
defined_in: ["20261108120000_build08_r2_knowledge_continuum.sql", part3_retrieval.sql]
workspace_fingerprint: "sha256:195a7bf46350274849f7ac517bb02381bbf8851afdacebee2c17dad0d348934c"
---
# retrieval.store_embedding

Domain `retrieval`, lens `corpus`.

## store_embedding(uuid, halfvec, text) → void

function, volatile, security definer, language plpgsql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_vector_item` | `uuid` | — | — |
| `p_embedding` | `halfvec` | — | — |
| `p_embedding_sha256` | `text` | — | — |

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `unknown vector item %`.

Touches (best effort): reads [`retrieval.vector_item`](../../relations/retrieval/vector_item.md), [`retrieval.vector_space`](../../relations/retrieval/vector_space.md), [`retrieval.vector_space_version`](../../relations/retrieval/vector_space_version.md); writes [`retrieval.vector_item_embedding_1536`](../../relations/retrieval/vector_item_embedding_1536.md); calls —.

TypeScript: `Database["retrieval"]["Functions"]["store_embedding"]`.

Defined in: `20261108120000_build08_r2_knowledge_continuum.sql`, `part3_retrieval.sql`.
