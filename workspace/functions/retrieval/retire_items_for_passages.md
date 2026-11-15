---
id: "fn:retrieval.retire_items_for_passages(uuid[])"
kind: function
schema: retrieval
name: retire_items_for_passages
domain: library
lens: corpus
overloads: ["fn:retrieval.retire_items_for_passages(uuid[])"]
security: definer
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [retrieval.projection_target], writes: [retrieval.vector_item] }
tokens: [retrieval, retire_items_for_passages, retrieval.retire_items_for_passages]
defined_in: ["20261108120000_build08_r2_knowledge_continuum.sql", part3_retrieval.sql]
workspace_fingerprint: "sha256:195a7bf46350274849f7ac517bb02381bbf8851afdacebee2c17dad0d348934c"
---
# retrieval.retire_items_for_passages

Domain `library`, lens `corpus`.

## retire_items_for_passages(uuid[]) → integer

function, volatile, security definer, language plpgsql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_passage_ids` | `uuid[]` | — | — |

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Touches (best effort): reads [`retrieval.projection_target`](../../relations/retrieval/projection_target.md); writes [`retrieval.vector_item`](../../relations/retrieval/vector_item.md); calls —.

TypeScript: `Database["retrieval"]["Functions"]["retire_items_for_passages"]`.

Defined in: `20261108120000_build08_r2_knowledge_continuum.sql`, `part3_retrieval.sql`.
