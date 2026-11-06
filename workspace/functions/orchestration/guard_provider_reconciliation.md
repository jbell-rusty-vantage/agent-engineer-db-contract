---
id: "fn:orchestration.guard_provider_reconciliation()"
kind: function
schema: orchestration
name: guard_provider_reconciliation
domain: orchestration-ledger
overloads: ["fn:orchestration.guard_provider_reconciliation()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: [provider reconciliation canonical hash mismatch, provider reconciliation is immutable, provider reconciliation original attempt missing, provider reconciliation original identity or authority mismatch, provider reconciliation registered artifact mismatch, provider reconciliation terminal operation required, semantic provider reconciliation canonical hash mismatch, semantic provider reconciliation capture handle mismatch, semantic provider reconciliation capture ledger mismatch, semantic provider reconciliation custody state mismatch, semantic provider reconciliation expired after custody reads, semantic provider reconciliation observation handle mismatch, semantic provider reconciliation observation ledger mismatch, semantic provider reconciliation omits existing observation, semantic provider reconciliation original attempt missing, semantic provider reconciliation original identity or authority mismatch, semantic provider reconciliation parent roles alias, semantic provider reconciliation registered artifact mismatch, semantic provider reconciliation terminal operation required, unknown provider reconciliation schema]
touches: { reads: [knowledge_service.operation, knowledge_service.operation_step, orchestration.artifact, orchestration.verification_artifact_metadata, orchestration.verification_provider_attempt, orchestration.verification_provider_budget, orchestration.verification_provider_response_capture, orchestration.verification_semantic_response_observation, orchestration.verification_structured_extraction_execution], writes: [] }
tokens: [orchestration, guard_provider_reconciliation, orchestration.guard_provider_reconciliation]
defined_in: ["20260906032800_verification_provider_reconciliation_ledger.sql", "20260906033000_verification_provider_reconciliation_success.sql", "20260907013000_verification_semantic_provider_observation.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# orchestration.guard_provider_reconciliation

Domain `orchestration-ledger`.

## guard_provider_reconciliation() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `provider reconciliation canonical hash mismatch`; `provider reconciliation is immutable`; `provider reconciliation original attempt missing`; `provider reconciliation original identity or authority mismatch`; `provider reconciliation registered artifact mismatch`; `provider reconciliation terminal operation required`; `semantic provider reconciliation canonical hash mismatch`; `semantic provider reconciliation capture handle mismatch`; `semantic provider reconciliation capture ledger mismatch`; `semantic provider reconciliation custody state mismatch`; `semantic provider reconciliation expired after custody reads`; `semantic provider reconciliation observation handle mismatch`; `semantic provider reconciliation observation ledger mismatch`; `semantic provider reconciliation omits existing observation`; `semantic provider reconciliation original attempt missing`; `semantic provider reconciliation original identity or authority mismatch`; `semantic provider reconciliation parent roles alias`; `semantic provider reconciliation registered artifact mismatch`; `semantic provider reconciliation terminal operation required`; `unknown provider reconciliation schema`.

Touches (best effort): reads [`knowledge_service.operation`](../../relations/knowledge_service/operation.md), [`knowledge_service.operation_step`](../../relations/knowledge_service/operation_step.md), [`orchestration.artifact`](../../relations/orchestration/artifact.md), [`orchestration.verification_artifact_metadata`](../../relations/orchestration/verification_artifact_metadata.md), [`orchestration.verification_provider_attempt`](../../relations/orchestration/verification_provider_attempt.md), [`orchestration.verification_provider_budget`](../../relations/orchestration/verification_provider_budget.md), [`orchestration.verification_provider_response_capture`](../../relations/orchestration/verification_provider_response_capture.md), [`orchestration.verification_semantic_response_observation`](../../relations/orchestration/verification_semantic_response_observation.md), [`orchestration.verification_structured_extraction_execution`](../../relations/orchestration/verification_structured_extraction_execution.md); writes —; calls [`orchestration.provider_reconciliation_handle_matches`](provider_reconciliation_handle_matches.md), [`orchestration.structured_extraction_receipt_json`](structured_extraction_receipt_json.md), [`orchestration.verification_artifact_is_admitted`](verification_artifact_is_admitted.md).

Defined in: `20260906032800_verification_provider_reconciliation_ledger.sql`, `20260906033000_verification_provider_reconciliation_success.sql`, `20260907013000_verification_semantic_provider_observation.sql`.
