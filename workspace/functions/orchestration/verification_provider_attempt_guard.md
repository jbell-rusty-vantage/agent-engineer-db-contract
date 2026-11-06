---
id: "fn:orchestration.verification_provider_attempt_guard()"
kind: function
schema: orchestration
name: verification_provider_attempt_guard
domain: orchestration-ledger
overloads: ["fn:orchestration.verification_provider_attempt_guard()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: [provider reconciliation settlement transition mismatch, verification provider attempt immutable identity, verification provider attempt state transition invalid, verification provider attempts are append-only, verification provider response evidence immutable]
touches: { reads: [orchestration.verification_provider_reconciliation], writes: [] }
tokens: [orchestration, verification_provider_attempt_guard, orchestration.verification_provider_attempt_guard]
defined_in: ["20260906010000_verification_provider_budget_accounting.sql", "20260906012000_harden_verification_provider_accounting.sql", "20260906013000_verification_provider_dispatch_fence.sql", "20260906014000_provider_accounting_identity_overrun_rls.sql", "20260906032900_verification_provider_reconciliation_missing_response.sql", "20260907013000_verification_semantic_provider_observation.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# orchestration.verification_provider_attempt_guard

Domain `orchestration-ledger`.

## verification_provider_attempt_guard() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `provider reconciliation settlement transition mismatch`; `verification provider attempt immutable identity`; `verification provider attempt state transition invalid`; `verification provider attempts are append-only`; `verification provider response evidence immutable`.

Touches (best effort): reads [`orchestration.verification_provider_reconciliation`](../../relations/orchestration/verification_provider_reconciliation.md); writes —; calls —.

Defined in: `20260906010000_verification_provider_budget_accounting.sql`, `20260906012000_harden_verification_provider_accounting.sql`, `20260906013000_verification_provider_dispatch_fence.sql`, `20260906014000_provider_accounting_identity_overrun_rls.sql`, `20260906032900_verification_provider_reconciliation_missing_response.sql`, `20260907013000_verification_semantic_provider_observation.sql`.
