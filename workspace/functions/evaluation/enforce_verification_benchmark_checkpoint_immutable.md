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
workspace_fingerprint: "sha256:ccec60ca7715c4edc1685d828a7324ce66fa6f9af95ad2a789d9a2fc6418dc0e"
---
# evaluation.enforce_verification_benchmark_checkpoint_immutable

Domain `evaluation`, lens `machinery`.

## enforce_verification_benchmark_checkpoint_immutable() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `benchmark checkpoints are append-only`.

Defined in: `20260906029000_verification_benchmark_durable_run.sql`.
