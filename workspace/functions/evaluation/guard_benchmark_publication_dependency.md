---
id: "fn:evaluation.guard_benchmark_publication_dependency()"
kind: function
schema: evaluation
name: guard_benchmark_publication_dependency
domain: evaluation
overloads: ["fn:evaluation.guard_benchmark_publication_dependency()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: [published benchmark dataset versions are immutable, published benchmark datasets are immutable, published benchmark evaluation runs are immutable, published benchmark experiments are immutable]
touches: { reads: [evaluation.eval_run, evaluation.experiment_arm, evaluation.verification_benchmark_arm_publication], writes: [] }
tokens: [evaluation, guard_benchmark_publication_dependency, evaluation.guard_benchmark_publication_dependency]
defined_in: ["20260906030000_verification_benchmark_arm_publication.sql", "20260906030300_verification_benchmark_published_dataset_immutable.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# evaluation.guard_benchmark_publication_dependency

Domain `evaluation`.

## guard_benchmark_publication_dependency() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `published benchmark dataset versions are immutable`; `published benchmark datasets are immutable`; `published benchmark evaluation runs are immutable`; `published benchmark experiments are immutable`.

Touches (best effort): reads [`evaluation.eval_run`](../../relations/evaluation/eval_run.md), [`evaluation.experiment_arm`](../../relations/evaluation/experiment_arm.md), [`evaluation.verification_benchmark_arm_publication`](../../relations/evaluation/verification_benchmark_arm_publication.md); writes —; calls —.

Defined in: `20260906030000_verification_benchmark_arm_publication.sql`, `20260906030300_verification_benchmark_published_dataset_immutable.sql`.
