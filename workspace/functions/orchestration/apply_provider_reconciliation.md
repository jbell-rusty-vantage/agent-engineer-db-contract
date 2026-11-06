---
id: "fn:orchestration.apply_provider_reconciliation()"
kind: function
schema: orchestration
name: apply_provider_reconciliation
domain: orchestration-ledger
overloads: ["fn:orchestration.apply_provider_reconciliation()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [], writes: [orchestration.verification_provider_attempt, orchestration.verification_provider_budget] }
tokens: [orchestration, apply_provider_reconciliation, orchestration.apply_provider_reconciliation]
defined_in: ["20260906032800_verification_provider_reconciliation_ledger.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# orchestration.apply_provider_reconciliation

Domain `orchestration-ledger`.

## apply_provider_reconciliation() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Touches (best effort): reads —; writes [`orchestration.verification_provider_attempt`](../../relations/orchestration/verification_provider_attempt.md), [`orchestration.verification_provider_budget`](../../relations/orchestration/verification_provider_budget.md); calls —.

Defined in: `20260906032800_verification_provider_reconciliation_ledger.sql`.
