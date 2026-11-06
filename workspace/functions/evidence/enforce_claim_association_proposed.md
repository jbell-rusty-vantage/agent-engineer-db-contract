---
id: "fn:evidence.enforce_claim_association_proposed()"
kind: function
schema: evidence
name: enforce_claim_association_proposed
domain: evidence
overloads: ["fn:evidence.enforce_claim_association_proposed()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: [typed entity associations may be added only while claim is proposed]
touches: { reads: [evidence.claim], writes: [] }
tokens: [evidence, enforce_claim_association_proposed, evidence.enforce_claim_association_proposed]
defined_in: ["20260829195623_lock_typed_claim_associations.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# evidence.enforce_claim_association_proposed

Domain `evidence`.

## enforce_claim_association_proposed() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`. Freezes typed claim meaning before review; later retargeting requires a superseding claim.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `typed entity associations may be added only while claim is proposed`.

Touches (best effort): reads [`evidence.claim`](../../relations/evidence/claim.md); writes —; calls —.

Defined in: `20260829195623_lock_typed_claim_associations.sql`.
