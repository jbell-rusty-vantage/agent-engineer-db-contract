---
id: "fn:evaluation.validate_verification_benchmark_comparison_claim()"
kind: function
schema: evaluation
name: validate_verification_benchmark_comparison_claim
domain: evaluation
overloads: ["fn:evaluation.validate_verification_benchmark_comparison_claim()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: [benchmark comparison active lease claim required, benchmark comparison operation not active]
touches: { reads: [knowledge_service.lease, knowledge_service.operation, knowledge_service.operation_step], writes: [] }
tokens: [evaluation, validate_verification_benchmark_comparison_claim, evaluation.validate_verification_benchmark_comparison_claim]
defined_in: ["20260906031000_verification_benchmark_comparison_claim.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# evaluation.validate_verification_benchmark_comparison_claim

Domain `evaluation`.

## validate_verification_benchmark_comparison_claim() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `benchmark comparison active lease claim required`; `benchmark comparison operation not active`.

Touches (best effort): reads [`knowledge_service.lease`](../../relations/knowledge_service/lease.md), [`knowledge_service.operation`](../../relations/knowledge_service/operation.md), [`knowledge_service.operation_step`](../../relations/knowledge_service/operation_step.md); writes —; calls —.

Defined in: `20260906031000_verification_benchmark_comparison_claim.sql`.
