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
workspace_fingerprint: "sha256:fbf5703bf7a6f6131c452444ee949f1feec1bbe813c78d772fb3886b510815b9"
---
# evaluation.guard_verification_freeze

Domain `evaluation`, lens `machinery`.

## guard_verification_freeze() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `frozen verification evaluation records are append-only`; `frozen verification evaluation records are immutable`.

Defined in: `20260905010000_verification_persistence_contract.sql`.
