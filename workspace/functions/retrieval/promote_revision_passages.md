---
id: "fn:retrieval.promote_revision_passages(uuid)"
kind: function
schema: retrieval
name: promote_revision_passages
domain: retrieval
lens: corpus
overloads: ["fn:retrieval.promote_revision_passages(uuid)"]
security: definer
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [library.passage, retrieval.projection_target], writes: [retrieval.vector_item, retrieval.vector_item_embedding_1536] }
tokens: [retrieval, promote_revision_passages, retrieval.promote_revision_passages]
defined_in: ["20261113160000_build08_loop5_followups.sql", "20261113160000_build08_loop5_ranking_rules_revalidation_triage.sql"]
workspace_fingerprint: "sha256:195a7bf46350274849f7ac517bb02381bbf8851afdacebee2c17dad0d348934c"
---
# retrieval.promote_revision_passages

Domain `retrieval`, lens `corpus`.

## promote_revision_passages(uuid) → integer

function, volatile, security definer, language plpgsql, config `search_path=""`. Loop 5: the active search items of a released revision's passages get a successor at tier T1 (our content), same text, projection and embedding; the draft item is superseded. A workspace draft has no tier.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_revision` | `uuid` | — | — |

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Touches (best effort): reads [`library.passage`](../../relations/library/passage.md), [`retrieval.projection_target`](../../relations/retrieval/projection_target.md); writes [`retrieval.vector_item`](../../relations/retrieval/vector_item.md), [`retrieval.vector_item_embedding_1536`](../../relations/retrieval/vector_item_embedding_1536.md); calls —.

TypeScript: `Database["retrieval"]["Functions"]["promote_revision_passages"]`.

Defined in: `20261113160000_build08_loop5_followups.sql`, `20261113160000_build08_loop5_ranking_rules_revalidation_triage.sql`.
