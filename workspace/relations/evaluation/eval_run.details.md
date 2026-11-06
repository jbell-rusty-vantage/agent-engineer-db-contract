---
id: "rel:evaluation.eval_run#details"
kind: details
schema: evaluation
name: eval_run
of: "rel:evaluation.eval_run"
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# evaluation.eval_run — details

Spill-over from [the main page](eval_run.md).

## Relationships

Outbound: `tenant_id,attempt_id` → [`orchestration.attempt`](../orchestration/attempt.md)`.tenant_id,id` on delete restrict; `capability_version_id` → [`orchestration.capability_version`](../orchestration/capability_version.md)`.id`; `dataset_id` → [`evaluation.eval_dataset`](eval_dataset.md)`.id`; `tenant_id,dataset_version_id` → [`evaluation.eval_dataset_version`](eval_dataset_version.md)`.tenant_id,id` on delete restrict; `tenant_id,experiment_arm_id` → [`evaluation.experiment_arm`](experiment_arm.md)`.tenant_id,id` on delete restrict; `grader_version_id` → [`evaluation.grader_version`](grader_version.md)`.id`; `tenant_id,run_manifest_artifact_id` → [`orchestration.artifact`](../orchestration/artifact.md)`.tenant_id,id` on delete restrict; `metric_definition_version_id` → [`ranking.metric_definition_version`](../ranking/metric_definition_version.md)`.id`; `tenant_id,mission_id` → [`orchestration.mission`](../orchestration/mission.md)`.tenant_id,id` on delete restrict; `tenant_id,policy_artifact_id` → [`orchestration.artifact`](../orchestration/artifact.md)`.tenant_id,id` on delete restrict; `ranking_policy_version_id` → [`ranking.ranking_policy_version`](../ranking/ranking_policy_version.md)`.id`; `space_version_id` → [`retrieval.vector_space_version`](../retrieval/vector_space_version.md)`.id`; `tenant_id,work_item_id` → [`orchestration.work_item`](../orchestration/work_item.md)`.tenant_id,id` on delete restrict.
Inbound: [`evaluation.eval_run_case_output`](eval_run_case_output.md).eval_run_id, [`evaluation.eval_score`](eval_score.md).run_id, [`evaluation.gate_result`](gate_result.md).eval_run_id, [`evaluation.metric_observation`](metric_observation.md).eval_run_id, [`evaluation.promotion_gate_result`](promotion_gate_result.md).eval_run_id, [`evaluation.regression`](regression.md).baseline_run_id|current_run_id, [`evaluation.verification_benchmark_arm_publication`](verification_benchmark_arm_publication.md).eval_run_id, [`research.report_version`](../research/report_version.md).synthesis_consistency_eval_id, [`retrieval.vector_item`](../retrieval/vector_item.md).generation_run_id, [`retrieval.vector_space_version`](../retrieval/vector_space_version.md).promotion_gate_eval_id.
Polymorphic: exactly one of `capability_version_id`, `space_version_id`, `ranking_policy_version_id`, `metric_definition_version_id`, `target_code_ref` → [`orchestration.capability_version`](../orchestration/capability_version.md) | [`ranking.metric_definition_version`](../ranking/metric_definition_version.md) | [`ranking.ranking_policy_version`](../ranking/ranking_policy_version.md) | [`retrieval.vector_space_version`](../retrieval/vector_space_version.md) — basis: check constraint eval_run_exactly_one_target.

## Indexes

| Index | Definition |
| --- | --- |
| `eval_run_dataset_idx` | `CREATE INDEX eval_run_dataset_idx ON evaluation.eval_run USING btree (dataset_id, executed_at DESC)` |
| `eval_run_target_idx` | `CREATE INDEX eval_run_target_idx ON evaluation.eval_run USING btree (target_kind, executed_at DESC)` |
| `eval_run_tenant_id_uq` | `CREATE UNIQUE INDEX eval_run_tenant_id_uq ON evaluation.eval_run USING btree (tenant_id, id)` |

## Triggers

- `artifact_retirement_19a7ccaf8daba2e09e1e01ae` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md): `CREATE TRIGGER artifact_retirement_19a7ccaf8daba2e09e1e01ae BEFORE INSERT OR UPDATE ON evaluation.eval_run FOR EACH ROW EXECUTE FUNCTION orchestration.guard_retired_artifact_reference('[{"local": "tenant_id", "parent": "tenant_id"}, {"local": "policy_artifact_id", "parent": "id"}]')`
- `artifact_retirement_3fe040c421bb092ffb719f89` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md): `CREATE TRIGGER artifact_retirement_3fe040c421bb092ffb719f89 BEFORE INSERT OR UPDATE ON evaluation.eval_run FOR EACH ROW EXECUTE FUNCTION orchestration.guard_retired_artifact_reference('[{"local": "tenant_id", "parent": "tenant_id"}, {"local": "run_manifest_artifact_id", "parent": "id"}]')`
- `eval_run_artifact_admission` → [`evaluation.validate_verification_artifact_consumer`](../../functions/evaluation/validate_verification_artifact_consumer.md): `CREATE TRIGGER eval_run_artifact_admission BEFORE INSERT OR UPDATE ON evaluation.eval_run FOR EACH ROW EXECUTE FUNCTION evaluation.validate_verification_artifact_consumer()`
- `eval_run_benchmark_publication_immutable` → [`evaluation.guard_benchmark_publication_dependency`](../../functions/evaluation/guard_benchmark_publication_dependency.md): `CREATE TRIGGER eval_run_benchmark_publication_immutable BEFORE DELETE OR UPDATE ON evaluation.eval_run FOR EACH ROW EXECUTE FUNCTION evaluation.guard_benchmark_publication_dependency()`

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: using `(tenant_id = util.current_tenant_id())`; with check `(tenant_id = util.current_tenant_id())`
