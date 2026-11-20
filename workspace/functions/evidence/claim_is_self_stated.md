---
id: "fn:evidence.claim_is_self_stated(uuid)"
kind: function
schema: evidence
name: claim_is_self_stated
domain: evidence
lens: evidence
overloads: ["fn:evidence.claim_is_self_stated(uuid)"]
security: definer
volatility: stable
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [evidence.attribution, evidence.claim, evidence.source_assessment], writes: [] }
tokens: [evidence, claim_is_self_stated, evidence.claim_is_self_stated]
defined_in: ["20261113160000_build08_loop5_followups.sql", "20261113160000_build08_loop5_ranking_rules_revalidation_triage.sql"]
workspace_fingerprint: "sha256:db20bac4d9e82d9b94cd2f3b580d4c145bcc3820969fdd572c6e7868ecca53fd"
---
# evidence.claim_is_self_stated

Domain `evidence`, lens `evidence`.

## claim_is_self_stated(uuid) → boolean

function, stable, security definer, language sql, config `search_path=""`. Loop 5: a claim stated by this system (structured.source_role own_experiment, or attributed to an entity whose prior role is own_experiment). Our probes checking it is self-verification (D-61).

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_claim` | `uuid` | — | — |

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Touches (best effort): reads [`evidence.attribution`](../../relations/evidence/attribution.md), [`evidence.claim`](../../relations/evidence/claim.md), [`evidence.source_assessment`](../../relations/evidence/source_assessment.md); writes —; calls —.

TypeScript: `Database["evidence"]["Functions"]["claim_is_self_stated"]`.

Defined in: `20261113160000_build08_loop5_followups.sql`, `20261113160000_build08_loop5_ranking_rules_revalidation_triage.sql`.
