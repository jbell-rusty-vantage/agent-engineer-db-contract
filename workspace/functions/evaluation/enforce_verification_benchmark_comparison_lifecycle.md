---
id: "fn:evaluation.enforce_verification_benchmark_comparison_lifecycle()"
kind: function
schema: evaluation
name: enforce_verification_benchmark_comparison_lifecycle
domain: evaluation
lens: machinery
overloads: ["fn:evaluation.enforce_verification_benchmark_comparison_lifecycle()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: [benchmark comparison permits only complete then seal transitions, benchmark comparisons are append-only]
touches: { reads: [], writes: [] }
tokens: [evaluation, enforce_verification_benchmark_comparison_lifecycle, evaluation.enforce_verification_benchmark_comparison_lifecycle]
defined_in: ["20260906030500_verification_benchmark_comparison_lifecycle.sql"]
workspace_fingerprint: "sha256:195a7bf46350274849f7ac517bb02381bbf8851afdacebee2c17dad0d348934c"
---
# evaluation.enforce_verification_benchmark_comparison_lifecycle

Domain `evaluation`, lens `machinery`.

## enforce_verification_benchmark_comparison_lifecycle() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `benchmark comparison permits only complete then seal transitions`; `benchmark comparisons are append-only`.

Defined in: `20260906030500_verification_benchmark_comparison_lifecycle.sql`.
