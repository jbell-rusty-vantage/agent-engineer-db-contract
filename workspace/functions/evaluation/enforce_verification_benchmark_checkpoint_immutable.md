---
id: "fn:evaluation.enforce_verification_benchmark_checkpoint_immutable()"
kind: function
schema: evaluation
name: enforce_verification_benchmark_checkpoint_immutable
domain: evaluation
lens: machinery
overloads: ["fn:evaluation.enforce_verification_benchmark_checkpoint_immutable()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: [benchmark checkpoints are append-only]
touches: { reads: [], writes: [] }
tokens: [evaluation, enforce_verification_benchmark_checkpoint_immutable, evaluation.enforce_verification_benchmark_checkpoint_immutable]
defined_in: ["20260906029000_verification_benchmark_durable_run.sql"]
workspace_fingerprint: "sha256:3cbce2e1f51948facb352a727c22966b1e5ceea4646ae43b07860ce6e83127b4"
---
# evaluation.enforce_verification_benchmark_checkpoint_immutable

Domain `evaluation`, lens `machinery`.

## enforce_verification_benchmark_checkpoint_immutable() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `benchmark checkpoints are append-only`.

Defined in: `20260906029000_verification_benchmark_durable_run.sql`.
