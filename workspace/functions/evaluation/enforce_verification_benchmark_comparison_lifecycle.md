---
id: "fn:evaluation.enforce_verification_benchmark_comparison_lifecycle()"
kind: function
schema: evaluation
name: enforce_verification_benchmark_comparison_lifecycle
domain: evaluation
overloads: ["fn:evaluation.enforce_verification_benchmark_comparison_lifecycle()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: [benchmark comparison permits only complete then seal transitions, benchmark comparisons are append-only]
touches: { reads: [], writes: [] }
tokens: [evaluation, enforce_verification_benchmark_comparison_lifecycle, evaluation.enforce_verification_benchmark_comparison_lifecycle]
defined_in: ["20260906030500_verification_benchmark_comparison_lifecycle.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# evaluation.enforce_verification_benchmark_comparison_lifecycle

Domain `evaluation`.

## enforce_verification_benchmark_comparison_lifecycle() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `benchmark comparison permits only complete then seal transitions`; `benchmark comparisons are append-only`.

Defined in: `20260906030500_verification_benchmark_comparison_lifecycle.sql`.
