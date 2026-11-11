---
id: "fn:orchestration.guard_artifact_registration_clock()"
kind: function
schema: orchestration
name: guard_artifact_registration_clock
domain: orchestration-ledger
lens: machinery
overloads: ["fn:orchestration.guard_artifact_registration_clock()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: [artifact custody registration clock is immutable]
touches: { reads: [], writes: [] }
tokens: [orchestration, guard_artifact_registration_clock, orchestration.guard_artifact_registration_clock]
defined_in: ["20260914010500_scoped_checkpoints.sql"]
workspace_fingerprint: "sha256:fbf5703bf7a6f6131c452444ee949f1feec1bbe813c78d772fb3886b510815b9"
---
# orchestration.guard_artifact_registration_clock

Domain `orchestration-ledger`, lens `machinery`.

## guard_artifact_registration_clock() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `artifact custody registration clock is immutable`.

Defined in: `20260914010500_scoped_checkpoints.sql`.
