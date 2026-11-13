---
id: "fn:evidence.enforce_claim_association_proposed()"
kind: function
schema: evidence
name: enforce_claim_association_proposed
domain: evidence
lens: machinery
overloads: ["fn:evidence.enforce_claim_association_proposed()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: [typed entity associations may be added only while claim is proposed]
touches: { reads: [evidence.claim], writes: [] }
tokens: [evidence, enforce_claim_association_proposed, evidence.enforce_claim_association_proposed]
defined_in: ["20260829195623_lock_typed_claim_associations.sql"]
workspace_fingerprint: "sha256:78aebf069f0925cf906c3997f4050a5a9e69eae7bcc29ce2060a813d8a02d4a9"
---
# evidence.enforce_claim_association_proposed

Domain `evidence`, lens `machinery`.

## enforce_claim_association_proposed() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`. Freezes typed claim meaning before review; later retargeting requires a superseding claim.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `typed entity associations may be added only while claim is proposed`.

Touches (best effort): reads [`evidence.claim`](../../relations/evidence/claim.md); writes —; calls —.

Defined in: `20260829195623_lock_typed_claim_associations.sql`.
