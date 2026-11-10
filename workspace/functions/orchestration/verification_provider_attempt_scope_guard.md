---
id: "fn:orchestration.verification_provider_attempt_scope_guard()"
kind: function
schema: orchestration
name: verification_provider_attempt_scope_guard
domain: orchestration-ledger
lens: machinery
overloads: ["fn:orchestration.verification_provider_attempt_scope_guard()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: [provider attempt operation scope is immutable, verification provider attempt scope identity immutable, verification provider dispatch fence immutable]
touches: { reads: [], writes: [] }
tokens: [orchestration, verification_provider_attempt_scope_guard, orchestration.verification_provider_attempt_scope_guard]
defined_in: ["20260906031300_verification_provider_operation_scope.sql"]
workspace_fingerprint: "sha256:027ab2b6133d5d59318c478f06d832d89f937e563c387539f37fb3d7668818a8"
---
# orchestration.verification_provider_attempt_scope_guard

Domain `orchestration-ledger`, lens `machinery`.

## verification_provider_attempt_scope_guard() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `provider attempt operation scope is immutable`; `verification provider attempt scope identity immutable`; `verification provider dispatch fence immutable`.

Defined in: `20260906031300_verification_provider_operation_scope.sql`.
