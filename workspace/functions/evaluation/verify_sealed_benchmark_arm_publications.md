---
id: "fn:evaluation.verify_sealed_benchmark_arm_publications()"
kind: function
schema: evaluation
name: verify_sealed_benchmark_arm_publications
domain: evaluation
lens: machinery
overloads: ["fn:evaluation.verify_sealed_benchmark_arm_publications()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: [sealed benchmark requires one publication for each planned arm]
touches: { reads: [evaluation.verification_benchmark_arm_publication], writes: [] }
tokens: [evaluation, verify_sealed_benchmark_arm_publications, evaluation.verify_sealed_benchmark_arm_publications]
defined_in: ["20260906030000_verification_benchmark_arm_publication.sql"]
workspace_fingerprint: "sha256:3cbce2e1f51948facb352a727c22966b1e5ceea4646ae43b07860ce6e83127b4"
---
# evaluation.verify_sealed_benchmark_arm_publications

Domain `evaluation`, lens `machinery`.

## verify_sealed_benchmark_arm_publications() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `sealed benchmark requires one publication for each planned arm`.

Touches (best effort): reads [`evaluation.verification_benchmark_arm_publication`](../../relations/evaluation/verification_benchmark_arm_publication.md); writes —; calls —.

Defined in: `20260906030000_verification_benchmark_arm_publication.sql`.
