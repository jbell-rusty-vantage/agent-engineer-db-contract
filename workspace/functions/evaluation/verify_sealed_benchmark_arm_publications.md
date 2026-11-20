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
workspace_fingerprint: "sha256:cb1a65412d0fb43423d4f775d78507ab4b320e27f820adab0423446aac89f036"
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
