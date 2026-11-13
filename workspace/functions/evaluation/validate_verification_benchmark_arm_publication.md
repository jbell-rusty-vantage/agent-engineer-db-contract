---
id: "fn:evaluation.validate_verification_benchmark_arm_publication()"
kind: function
schema: evaluation
name: validate_verification_benchmark_arm_publication
domain: evaluation
lens: machinery
overloads: ["fn:evaluation.validate_verification_benchmark_arm_publication()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: [benchmark arm publication artifact binding mismatch, benchmark arm publication eval run binding mismatch, benchmark arm publication is outside the persisted checkpoint plan, benchmark arm publication operation missing, benchmark arm publication requires its exact sealed benchmark operation]
touches: { reads: [evaluation.eval_dataset_version, evaluation.eval_run, evaluation.experiment, evaluation.experiment_arm, evaluation.verification_benchmark_run, knowledge_service.operation], writes: [] }
tokens: [evaluation, validate_verification_benchmark_arm_publication, evaluation.validate_verification_benchmark_arm_publication]
defined_in: ["20260906030000_verification_benchmark_arm_publication.sql", "20260906030200_verification_benchmark_publication_dataset_binding.sql"]
workspace_fingerprint: "sha256:78aebf069f0925cf906c3997f4050a5a9e69eae7bcc29ce2060a813d8a02d4a9"
---
# evaluation.validate_verification_benchmark_arm_publication

Domain `evaluation`, lens `machinery`.

## validate_verification_benchmark_arm_publication() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `benchmark arm publication artifact binding mismatch`; `benchmark arm publication eval run binding mismatch`; `benchmark arm publication is outside the persisted checkpoint plan`; `benchmark arm publication operation missing`; `benchmark arm publication requires its exact sealed benchmark operation`.

Touches (best effort): reads [`evaluation.eval_dataset_version`](../../relations/evaluation/eval_dataset_version.md), [`evaluation.eval_run`](../../relations/evaluation/eval_run.md), [`evaluation.experiment`](../../relations/evaluation/experiment.md), [`evaluation.experiment_arm`](../../relations/evaluation/experiment_arm.md), [`evaluation.verification_benchmark_run`](../../relations/evaluation/verification_benchmark_run.md), [`knowledge_service.operation`](../../relations/knowledge_service/operation.md); writes —; calls [`orchestration.verification_artifact_is_admitted`](../orchestration/verification_artifact_is_admitted.md).

Defined in: `20260906030000_verification_benchmark_arm_publication.sql`, `20260906030200_verification_benchmark_publication_dataset_binding.sql`.
