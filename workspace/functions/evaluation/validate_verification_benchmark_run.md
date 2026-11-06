---
id: "fn:evaluation.validate_verification_benchmark_run()"
kind: function
schema: evaluation
name: validate_verification_benchmark_run
domain: evaluation
overloads: ["fn:evaluation.validate_verification_benchmark_run()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: [benchmark checkpoint plan duplicate key, benchmark checkpoint plan entry invalid, benchmark checkpoint plan shape mismatch, benchmark dataset artifact binding mismatch, benchmark experiment artifact binding mismatch, benchmark operation admitted input binding mismatch, benchmark run manifest artifact binding mismatch]
touches: { reads: [knowledge_service.operation, orchestration.artifact], writes: [] }
tokens: [evaluation, validate_verification_benchmark_run, evaluation.validate_verification_benchmark_run]
defined_in: ["20260906029000_verification_benchmark_durable_run.sql", "20260906029300_verification_benchmark_nullsafe_request_binding.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# evaluation.validate_verification_benchmark_run

Domain `evaluation`.

## validate_verification_benchmark_run() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `benchmark checkpoint plan duplicate key`; `benchmark checkpoint plan entry invalid`; `benchmark checkpoint plan shape mismatch`; `benchmark dataset artifact binding mismatch`; `benchmark experiment artifact binding mismatch`; `benchmark operation admitted input binding mismatch`; `benchmark run manifest artifact binding mismatch`.

Touches (best effort): reads [`knowledge_service.operation`](../../relations/knowledge_service/operation.md), [`orchestration.artifact`](../../relations/orchestration/artifact.md); writes —; calls —.

Defined in: `20260906029000_verification_benchmark_durable_run.sql`, `20260906029300_verification_benchmark_nullsafe_request_binding.sql`.
