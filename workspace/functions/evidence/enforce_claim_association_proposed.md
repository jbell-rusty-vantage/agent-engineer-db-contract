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
workspace_fingerprint: "sha256:ccec60ca7715c4edc1685d828a7324ce66fa6f9af95ad2a789d9a2fc6418dc0e"
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
