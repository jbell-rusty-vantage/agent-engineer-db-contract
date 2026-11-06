---
id: "fn:evaluation.guard_verification_benchmark_comparison_terminal_artifact()"
kind: function
schema: evaluation
name: guard_verification_benchmark_comparison_terminal_artifact
domain: evaluation
overloads: ["fn:evaluation.guard_verification_benchmark_comparison_terminal_artifact()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: [benchmark comparison terminal success requires dedicated publication artifact]
touches: { reads: [evaluation.verification_benchmark_comparison, knowledge_service.operation], writes: [] }
tokens: [evaluation, guard_verification_benchmark_comparison_terminal_artifact, evaluation.guard_verification_benchmark_comparison_terminal_artifact]
defined_in: ["20260906031200_verification_benchmark_comparison_terminal_artifact_type.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# evaluation.guard_verification_benchmark_comparison_terminal_artifact

Domain `evaluation`.

## guard_verification_benchmark_comparison_terminal_artifact() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `benchmark comparison terminal success requires dedicated publication artifact`.

Touches (best effort): reads [`evaluation.verification_benchmark_comparison`](../../relations/evaluation/verification_benchmark_comparison.md), [`knowledge_service.operation`](../../relations/knowledge_service/operation.md); writes —; calls [`orchestration.verification_artifact_is_admitted`](../orchestration/verification_artifact_is_admitted.md).

Defined in: `20260906031200_verification_benchmark_comparison_terminal_artifact_type.sql`.
