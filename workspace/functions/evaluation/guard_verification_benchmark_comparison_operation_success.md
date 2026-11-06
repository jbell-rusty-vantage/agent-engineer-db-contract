---
id: "fn:evaluation.guard_verification_benchmark_comparison_operation_success()"
kind: function
schema: evaluation
name: guard_verification_benchmark_comparison_operation_success
domain: evaluation
overloads: ["fn:evaluation.guard_verification_benchmark_comparison_operation_success()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: [benchmark comparison operation success requires one exact sealed receipt]
touches: { reads: [evaluation.verification_benchmark_comparison, knowledge_service.operation_step, knowledge_service.receipt], writes: [] }
tokens: [evaluation, guard_verification_benchmark_comparison_operation_success, evaluation.guard_verification_benchmark_comparison_operation_success]
defined_in: ["20260906030900_verification_benchmark_comparison_terminal_success.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# evaluation.guard_verification_benchmark_comparison_operation_success

Domain `evaluation`.

## guard_verification_benchmark_comparison_operation_success() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `benchmark comparison operation success requires one exact sealed receipt`.

Touches (best effort): reads [`evaluation.verification_benchmark_comparison`](../../relations/evaluation/verification_benchmark_comparison.md), [`knowledge_service.operation_step`](../../relations/knowledge_service/operation_step.md), [`knowledge_service.receipt`](../../relations/knowledge_service/receipt.md); writes —; calls —.

Defined in: `20260906030900_verification_benchmark_comparison_terminal_success.sql`.
