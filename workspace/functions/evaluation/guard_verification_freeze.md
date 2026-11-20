---
id: "fn:evaluation.guard_verification_freeze()"
kind: function
schema: evaluation
name: guard_verification_freeze
domain: evaluation
lens: machinery
overloads: ["fn:evaluation.guard_verification_freeze()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: [frozen verification evaluation records are append-only, frozen verification evaluation records are immutable]
touches: { reads: [], writes: [] }
tokens: [evaluation, guard_verification_freeze, evaluation.guard_verification_freeze]
defined_in: ["20260905010000_verification_persistence_contract.sql"]
workspace_fingerprint: "sha256:cb1a65412d0fb43423d4f775d78507ab4b320e27f820adab0423446aac89f036"
---
# evaluation.guard_verification_freeze

Domain `evaluation`, lens `machinery`.

## guard_verification_freeze() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `frozen verification evaluation records are append-only`; `frozen verification evaluation records are immutable`.

Defined in: `20260905010000_verification_persistence_contract.sql`.
