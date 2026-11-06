---
id: "fn:evaluation.validate_verification_benchmark_checkpoint()"
kind: function
schema: evaluation
name: validate_verification_benchmark_checkpoint
domain: evaluation
overloads: ["fn:evaluation.validate_verification_benchmark_checkpoint()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: [benchmark checkpoint is outside its immutable running plan, benchmark checkpoint result is outside its immutable plan, benchmark checkpoint timestamp invalid]
touches: { reads: [evaluation.verification_benchmark_run], writes: [] }
tokens: [evaluation, validate_verification_benchmark_checkpoint, evaluation.validate_verification_benchmark_checkpoint]
defined_in: ["20260906029000_verification_benchmark_durable_run.sql", "20260906029100_verification_benchmark_checkpoint_running_only.sql", "20260906029400_verification_benchmark_checkpoint_result_binding.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# evaluation.validate_verification_benchmark_checkpoint

Domain `evaluation`.

## validate_verification_benchmark_checkpoint() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `benchmark checkpoint is outside its immutable running plan`; `benchmark checkpoint result is outside its immutable plan`; `benchmark checkpoint timestamp invalid`.

Touches (best effort): reads [`evaluation.verification_benchmark_run`](../../relations/evaluation/verification_benchmark_run.md); writes —; calls —.

Defined in: `20260906029000_verification_benchmark_durable_run.sql`, `20260906029100_verification_benchmark_checkpoint_running_only.sql`, `20260906029400_verification_benchmark_checkpoint_result_binding.sql`.
