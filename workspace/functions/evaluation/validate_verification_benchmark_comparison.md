---
id: "fn:evaluation.validate_verification_benchmark_comparison()"
kind: function
schema: evaluation
name: validate_verification_benchmark_comparison
domain: evaluation
overloads: ["fn:evaluation.validate_verification_benchmark_comparison()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: [benchmark comparison canonical operation binding mismatch, benchmark comparison lifecycle timestamp invalid, benchmark comparison must initialize running, benchmark comparison profile artifact binding mismatch, benchmark comparison publication artifact binding mismatch, benchmark comparison requires exact completed input publications, benchmark comparison result artifact or gate binding mismatch]
touches: { reads: [evaluation.verification_benchmark_arm_publication, evaluation.verification_benchmark_run, knowledge_service.operation, knowledge_service.operation_step, knowledge_service.receipt], writes: [] }
tokens: [evaluation, validate_verification_benchmark_comparison, evaluation.validate_verification_benchmark_comparison]
defined_in: ["20260906030500_verification_benchmark_comparison_lifecycle.sql", "20260906030700_verification_benchmark_comparison_publication_type.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# evaluation.validate_verification_benchmark_comparison

Domain `evaluation`.

## validate_verification_benchmark_comparison() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `benchmark comparison canonical operation binding mismatch`; `benchmark comparison lifecycle timestamp invalid`; `benchmark comparison must initialize running`; `benchmark comparison profile artifact binding mismatch`; `benchmark comparison publication artifact binding mismatch`; `benchmark comparison requires exact completed input publications`; `benchmark comparison result artifact or gate binding mismatch`.

Touches (best effort): reads [`evaluation.verification_benchmark_arm_publication`](../../relations/evaluation/verification_benchmark_arm_publication.md), [`evaluation.verification_benchmark_run`](../../relations/evaluation/verification_benchmark_run.md), [`knowledge_service.operation`](../../relations/knowledge_service/operation.md), [`knowledge_service.operation_step`](../../relations/knowledge_service/operation_step.md), [`knowledge_service.receipt`](../../relations/knowledge_service/receipt.md); writes —; calls [`orchestration.verification_artifact_is_admitted`](../orchestration/verification_artifact_is_admitted.md).

Defined in: `20260906030500_verification_benchmark_comparison_lifecycle.sql`, `20260906030700_verification_benchmark_comparison_publication_type.sql`.
