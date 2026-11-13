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
workspace_fingerprint: "sha256:4ca964568389f6bca66099cb3a109cf6e895892ead47d26c6c89b292b0e91e75"
---
# orchestration.verification_provider_attempt_scope_guard

Domain `orchestration-ledger`, lens `machinery`.

## verification_provider_attempt_scope_guard() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `provider attempt operation scope is immutable`; `verification provider attempt scope identity immutable`; `verification provider dispatch fence immutable`.

Defined in: `20260906031300_verification_provider_operation_scope.sql`.
