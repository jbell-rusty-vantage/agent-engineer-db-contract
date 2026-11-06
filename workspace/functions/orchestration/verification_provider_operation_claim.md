---
id: "fn:orchestration.verification_provider_operation_claim()"
kind: function
schema: orchestration
name: verification_provider_operation_claim
domain: orchestration-ledger
overloads: ["fn:orchestration.verification_provider_operation_claim()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: [provider attempt active closed-scope lease claim required, provider attempt dispatch fence mismatch, provider attempt operation scope cannot be removed, provider attempt provider artifact binding is inadmissible, provider attempt reservation fence mismatch, provider reconciliation settlement transition mismatch, scoped provider attempt must begin reserved]
touches: { reads: [orchestration.verification_provider_reconciliation], writes: [] }
tokens: [orchestration, verification_provider_operation_claim, orchestration.verification_provider_operation_claim]
defined_in: ["20260906031300_verification_provider_operation_scope.sql", "20260906032800_verification_provider_reconciliation_ledger.sql", "20260907013000_verification_semantic_provider_observation.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# orchestration.verification_provider_operation_claim

Domain `orchestration-ledger`.

## verification_provider_operation_claim() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `provider attempt active closed-scope lease claim required`; `provider attempt dispatch fence mismatch`; `provider attempt operation scope cannot be removed`; `provider attempt provider artifact binding is inadmissible`; `provider attempt reservation fence mismatch`; `provider reconciliation settlement transition mismatch`; `scoped provider attempt must begin reserved`.

Touches (best effort): reads [`orchestration.verification_provider_reconciliation`](../../relations/orchestration/verification_provider_reconciliation.md); writes —; calls [`orchestration.verification_provider_artifacts_are_admitted`](verification_provider_artifacts_are_admitted.md), [`orchestration.verification_provider_scope_tuple_is_live`](verification_provider_scope_tuple_is_live.md).

Defined in: `20260906031300_verification_provider_operation_scope.sql`, `20260906032800_verification_provider_reconciliation_ledger.sql`, `20260907013000_verification_semantic_provider_observation.sql`.
