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
workspace_fingerprint: "sha256:4ca964568389f6bca66099cb3a109cf6e895892ead47d26c6c89b292b0e91e75"
---
# evaluation.enforce_verification_benchmark_checkpoint_immutable

Domain `evaluation`, lens `machinery`.

## enforce_verification_benchmark_checkpoint_immutable() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `benchmark checkpoints are append-only`.

Defined in: `20260906029000_verification_benchmark_durable_run.sql`.
