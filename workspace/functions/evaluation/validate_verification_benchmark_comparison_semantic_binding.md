---
id: "fn:evaluation.validate_verification_benchmark_comparison_semantic_binding()"
kind: function
schema: evaluation
name: validate_verification_benchmark_comparison_semantic_binding
domain: evaluation
lens: machinery
overloads: ["fn:evaluation.validate_verification_benchmark_comparison_semantic_binding()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: [benchmark comparison publication semantic binding mismatch, benchmark comparison result semantic binding mismatch, benchmark comparison runtime artifact digest required]
touches: { reads: [orchestration.verification_artifact_metadata], writes: [] }
tokens: [evaluation, validate_verification_benchmark_comparison_semantic_binding, evaluation.validate_verification_benchmark_comparison_semantic_binding]
defined_in: ["20260906031100_verification_benchmark_comparison_semantic_binding.sql"]
workspace_fingerprint: "sha256:78aebf069f0925cf906c3997f4050a5a9e69eae7bcc29ce2060a813d8a02d4a9"
---
# evaluation.validate_verification_benchmark_comparison_semantic_binding

Domain `evaluation`, lens `machinery`.

## validate_verification_benchmark_comparison_semantic_binding() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `benchmark comparison publication semantic binding mismatch`; `benchmark comparison result semantic binding mismatch`; `benchmark comparison runtime artifact digest required`.

Touches (best effort): reads [`orchestration.verification_artifact_metadata`](../../relations/orchestration/verification_artifact_metadata.md); writes —; calls —.

Defined in: `20260906031100_verification_benchmark_comparison_semantic_binding.sql`.
