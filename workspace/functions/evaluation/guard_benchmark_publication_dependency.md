---
id: "fn:evaluation.guard_benchmark_publication_dependency()"
kind: function
schema: evaluation
name: guard_benchmark_publication_dependency
domain: evaluation
lens: machinery
overloads: ["fn:evaluation.guard_benchmark_publication_dependency()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: [published benchmark dataset versions are immutable, published benchmark datasets are immutable, published benchmark evaluation runs are immutable, published benchmark experiments are immutable]
touches: { reads: [evaluation.eval_run, evaluation.experiment_arm, evaluation.verification_benchmark_arm_publication], writes: [] }
tokens: [evaluation, guard_benchmark_publication_dependency, evaluation.guard_benchmark_publication_dependency]
defined_in: ["20260906030000_verification_benchmark_arm_publication.sql", "20260906030300_verification_benchmark_published_dataset_immutable.sql"]
workspace_fingerprint: "sha256:fbf5703bf7a6f6131c452444ee949f1feec1bbe813c78d772fb3886b510815b9"
---
# evaluation.guard_benchmark_publication_dependency

Domain `evaluation`, lens `machinery`.

## guard_benchmark_publication_dependency() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `published benchmark dataset versions are immutable`; `published benchmark datasets are immutable`; `published benchmark evaluation runs are immutable`; `published benchmark experiments are immutable`.

Touches (best effort): reads [`evaluation.eval_run`](../../relations/evaluation/eval_run.md), [`evaluation.experiment_arm`](../../relations/evaluation/experiment_arm.md), [`evaluation.verification_benchmark_arm_publication`](../../relations/evaluation/verification_benchmark_arm_publication.md); writes —; calls —.

Defined in: `20260906030000_verification_benchmark_arm_publication.sql`, `20260906030300_verification_benchmark_published_dataset_immutable.sql`.
