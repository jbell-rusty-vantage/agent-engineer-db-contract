---
id: "fn:evaluation.guard_verification_benchmark_comparison_step_success()"
kind: function
schema: evaluation
name: guard_verification_benchmark_comparison_step_success
domain: evaluation
lens: machinery
overloads: ["fn:evaluation.guard_verification_benchmark_comparison_step_success()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: [benchmark comparison step success requires sealed comparison]
touches: { reads: [evaluation.verification_benchmark_comparison, knowledge_service.operation], writes: [] }
tokens: [evaluation, guard_verification_benchmark_comparison_step_success, evaluation.guard_verification_benchmark_comparison_step_success]
defined_in: ["20260906030900_verification_benchmark_comparison_terminal_success.sql"]
workspace_fingerprint: "sha256:78aebf069f0925cf906c3997f4050a5a9e69eae7bcc29ce2060a813d8a02d4a9"
---
# evaluation.guard_verification_benchmark_comparison_step_success

Domain `evaluation`, lens `machinery`.

## guard_verification_benchmark_comparison_step_success() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `benchmark comparison step success requires sealed comparison`.

Touches (best effort): reads [`evaluation.verification_benchmark_comparison`](../../relations/evaluation/verification_benchmark_comparison.md), [`knowledge_service.operation`](../../relations/knowledge_service/operation.md); writes —; calls —.

Defined in: `20260906030900_verification_benchmark_comparison_terminal_success.sql`.
