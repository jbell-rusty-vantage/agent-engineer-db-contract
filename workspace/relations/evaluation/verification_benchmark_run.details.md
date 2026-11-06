---
id: "rel:evaluation.verification_benchmark_run#details"
kind: details
schema: evaluation
name: verification_benchmark_run
of: "rel:evaluation.verification_benchmark_run"
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# evaluation.verification_benchmark_run — details

Spill-over from [the main page](verification_benchmark_run.md).

## Relationships

Outbound: `tenant_id,dataset_artifact_id` → [`orchestration.artifact`](../orchestration/artifact.md)`.tenant_id,id` on delete restrict; `tenant_id,experiment_artifact_id` → [`orchestration.artifact`](../orchestration/artifact.md)`.tenant_id,id` on delete restrict; `tenant_id,operation_id` → [`knowledge_service.operation`](../knowledge_service/operation.md)`.tenant_id,id` on delete restrict; `tenant_id,run_manifest_artifact_id` → [`orchestration.artifact`](../orchestration/artifact.md)`.tenant_id,id` on delete restrict.
Inbound: [`evaluation.verification_benchmark_arm_publication`](verification_benchmark_arm_publication.md).benchmark_run_id, [`evaluation.verification_benchmark_checkpoint`](verification_benchmark_checkpoint.md).benchmark_run_id, [`evaluation.verification_benchmark_comparison`](verification_benchmark_comparison.md).candidate_run_id|baseline_run_id.

## Indexes

| Index | Definition |
| --- | --- |
| `verification_benchmark_run_tenant_id_id_key` | `CREATE UNIQUE INDEX verification_benchmark_run_tenant_id_id_key ON evaluation.verification_benchmark_run USING btree (tenant_id, id)` |
| `verification_benchmark_run_tenant_id_operation_id_key` | `CREATE UNIQUE INDEX verification_benchmark_run_tenant_id_operation_id_key ON evaluation.verification_benchmark_run USING btree (tenant_id, operation_id)` |

## Triggers

- `artifact_retirement_0bfc78136b9bd1f74d3fb7e0` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md): `CREATE TRIGGER artifact_retirement_0bfc78136b9bd1f74d3fb7e0 BEFORE INSERT OR UPDATE ON evaluation.verification_benchmark_run FOR EACH ROW EXECUTE FUNCTION orchestration.guard_retired_artifact_reference('[{"local": "tenant_id", "parent": "tenant_id"}, {"local": "dataset_artifact_id", "parent": "id"}]')`
- `artifact_retirement_281e1b0731dd5ef055d73126` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md): `CREATE TRIGGER artifact_retirement_281e1b0731dd5ef055d73126 BEFORE INSERT OR UPDATE ON evaluation.verification_benchmark_run FOR EACH ROW EXECUTE FUNCTION orchestration.guard_retired_artifact_reference('[{"local": "tenant_id", "parent": "tenant_id"}, {"local": "run_manifest_artifact_id", "parent": "id"}]')`
- `artifact_retirement_608be7e29e89d76c8e87aca5` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md): `CREATE TRIGGER artifact_retirement_608be7e29e89d76c8e87aca5 BEFORE INSERT OR UPDATE ON evaluation.verification_benchmark_run FOR EACH ROW EXECUTE FUNCTION orchestration.guard_retired_artifact_reference('[{"local": "tenant_id", "parent": "tenant_id"}, {"local": "experiment_artifact_id", "parent": "id"}]')`
- `verification_benchmark_run_arm_publications_complete` → [`evaluation.verify_sealed_benchmark_arm_publications`](../../functions/evaluation/verify_sealed_benchmark_arm_publications.md) (constraint trigger, deferred): `CREATE CONSTRAINT TRIGGER verification_benchmark_run_arm_publications_complete AFTER UPDATE OF status ON evaluation.verification_benchmark_run DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION evaluation.verify_sealed_benchmark_arm_publications()`
- `verification_benchmark_run_immutable` → [`evaluation.enforce_verification_benchmark_run_lifecycle`](../../functions/evaluation/enforce_verification_benchmark_run_lifecycle.md): `CREATE TRIGGER verification_benchmark_run_immutable BEFORE DELETE OR UPDATE ON evaluation.verification_benchmark_run FOR EACH ROW EXECUTE FUNCTION evaluation.enforce_verification_benchmark_run_lifecycle()`
- `verification_benchmark_run_validate` → [`evaluation.validate_verification_benchmark_run`](../../functions/evaluation/validate_verification_benchmark_run.md): `CREATE TRIGGER verification_benchmark_run_validate BEFORE INSERT OR UPDATE ON evaluation.verification_benchmark_run FOR EACH ROW EXECUTE FUNCTION evaluation.validate_verification_benchmark_run()`

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `control_plane`: using `(tenant_id = util.current_tenant_id())`; with check `(tenant_id = util.current_tenant_id())`
