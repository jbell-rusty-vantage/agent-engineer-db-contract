---
id: "fn:retrieval.promote_release_passages(uuid)"
kind: function
schema: retrieval
name: promote_release_passages
domain: retrieval
lens: corpus
overloads: ["fn:retrieval.promote_release_passages(uuid)"]
security: definer
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [authoring.release_item], writes: [] }
tokens: [retrieval, promote_release_passages, retrieval.promote_release_passages]
defined_in: ["20261113160000_build08_loop5_followups.sql", "20261113160000_build08_loop5_ranking_rules_revalidation_triage.sql"]
workspace_fingerprint: "sha256:195a7bf46350274849f7ac517bb02381bbf8851afdacebee2c17dad0d348934c"
---
# retrieval.promote_release_passages

Domain `retrieval`, lens `corpus`.

## promote_release_passages(uuid) → integer

function, volatile, security definer, language sql, config `search_path=""`. Loop 5: promote the passages of every revision a release includes to T1.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_release` | `uuid` | — | — |

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Touches (best effort): reads [`authoring.release_item`](../../relations/authoring/release_item.md); writes —; calls [`retrieval.promote_revision_passages`](promote_revision_passages.md).

TypeScript: `Database["retrieval"]["Functions"]["promote_release_passages"]`.

Defined in: `20261113160000_build08_loop5_followups.sql`, `20261113160000_build08_loop5_ranking_rules_revalidation_triage.sql`.
