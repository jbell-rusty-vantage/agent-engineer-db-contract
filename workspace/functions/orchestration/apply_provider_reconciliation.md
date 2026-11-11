---
id: "fn:orchestration.apply_provider_reconciliation()"
kind: function
schema: orchestration
name: apply_provider_reconciliation
domain: orchestration-ledger
lens: machinery
overloads: ["fn:orchestration.apply_provider_reconciliation()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [], writes: [orchestration.verification_provider_attempt, orchestration.verification_provider_budget] }
tokens: [orchestration, apply_provider_reconciliation, orchestration.apply_provider_reconciliation]
defined_in: ["20260906032800_verification_provider_reconciliation_ledger.sql"]
workspace_fingerprint: "sha256:fbf5703bf7a6f6131c452444ee949f1feec1bbe813c78d772fb3886b510815b9"
---
# orchestration.apply_provider_reconciliation

Domain `orchestration-ledger`, lens `machinery`.

## apply_provider_reconciliation() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Touches (best effort): reads —; writes [`orchestration.verification_provider_attempt`](../../relations/orchestration/verification_provider_attempt.md), [`orchestration.verification_provider_budget`](../../relations/orchestration/verification_provider_budget.md); calls —.

Defined in: `20260906032800_verification_provider_reconciliation_ledger.sql`.
