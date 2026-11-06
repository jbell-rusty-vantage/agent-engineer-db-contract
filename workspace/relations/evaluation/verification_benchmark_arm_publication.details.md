---
id: "rel:evaluation.verification_benchmark_arm_publication#details"
kind: details
schema: evaluation
name: verification_benchmark_arm_publication
of: "rel:evaluation.verification_benchmark_arm_publication"
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# evaluation.verification_benchmark_arm_publication — details

Spill-over from [the main page](verification_benchmark_arm_publication.md).

## Relationships

Outbound: `tenant_id,configuration_artifact_id` → [`orchestration.artifact`](../orchestration/artifact.md)`.tenant_id,id` on delete restrict; `tenant_id,policy_artifact_id` → [`orchestration.artifact`](../orchestration/artifact.md)`.tenant_id,id` on delete restrict; `tenant_id,publication_manifest_artifact_id` → [`orchestration.artifact`](../orchestration/artifact.md)`.tenant_id,id` on delete restrict; `tenant_id,experiment_arm_id` → [`evaluation.experiment_arm`](experiment_arm.md)`.tenant_id,id` on delete restrict; `tenant_id,benchmark_run_id` → [`evaluation.verification_benchmark_run`](verification_benchmark_run.md)`.tenant_id,id` on delete restrict; `tenant_id,operation_id` → [`knowledge_service.operation`](../knowledge_service/operation.md)`.tenant_id,id` on delete restrict; `tenant_id,eval_run_id` → [`evaluation.eval_run`](eval_run.md)`.tenant_id,id` on delete restrict.
Inbound: none.

## Indexes

| Index | Definition |
| --- | --- |
| `verification_benchmark_arm_pu_tenant_id_benchmark_run_id_be_key` | `CREATE UNIQUE INDEX verification_benchmark_arm_pu_tenant_id_benchmark_run_id_be_key ON evaluation.verification_benchmark_arm_publication USING btree (tenant_id, benchmark_run_id, benchmark_arm_id)` |
| `verification_benchmark_arm_pu_tenant_id_benchmark_run_id_ex_key` | `CREATE UNIQUE INDEX verification_benchmark_arm_pu_tenant_id_benchmark_run_id_ex_key ON evaluation.verification_benchmark_arm_publication USING btree (tenant_id, benchmark_run_id, experiment_arm_id)` |
| `verification_benchmark_arm_publicatio_tenant_id_eval_run_id_key` | `CREATE UNIQUE INDEX verification_benchmark_arm_publicatio_tenant_id_eval_run_id_key ON evaluation.verification_benchmark_arm_publication USING btree (tenant_id, eval_run_id)` |
| `verification_benchmark_arm_publication_tenant_id_id_key` | `CREATE UNIQUE INDEX verification_benchmark_arm_publication_tenant_id_id_key ON evaluation.verification_benchmark_arm_publication USING btree (tenant_id, id)` |

## Triggers

- `artifact_retirement_21d6250956bc8b3d3886db90` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md): `CREATE TRIGGER artifact_retirement_21d6250956bc8b3d3886db90 BEFORE INSERT OR UPDATE ON evaluation.verification_benchmark_arm_publication FOR EACH ROW EXECUTE FUNCTION orchestration.guard_retired_artifact_reference('[{"local": "tenant_id", "parent": "tenant_id"}, {"local": "configuration_artifact_id", "parent": "id"}]')`
- `artifact_retirement_7256ab444770f6cd417e4104` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md): `CREATE TRIGGER artifact_retirement_7256ab444770f6cd417e4104 BEFORE INSERT OR UPDATE ON evaluation.verification_benchmark_arm_publication FOR EACH ROW EXECUTE FUNCTION orchestration.guard_retired_artifact_reference('[{"local": "tenant_id", "parent": "tenant_id"}, {"local": "publication_manifest_artifact_id", "parent": "id"}]')`
- `artifact_retirement_975f49b3ab6f197833466ea9` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md): `CREATE TRIGGER artifact_retirement_975f49b3ab6f197833466ea9 BEFORE INSERT OR UPDATE ON evaluation.verification_benchmark_arm_publication FOR EACH ROW EXECUTE FUNCTION orchestration.guard_retired_artifact_reference('[{"local": "tenant_id", "parent": "tenant_id"}, {"local": "policy_artifact_id", "parent": "id"}]')`
- `verification_benchmark_arm_publication_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md): `CREATE TRIGGER verification_benchmark_arm_publication_immutable BEFORE DELETE OR UPDATE ON evaluation.verification_benchmark_arm_publication FOR EACH ROW EXECUTE FUNCTION util.reject_mutation()`
- `verification_benchmark_arm_publication_validate` → [`evaluation.validate_verification_benchmark_arm_publication`](../../functions/evaluation/validate_verification_benchmark_arm_publication.md): `CREATE TRIGGER verification_benchmark_arm_publication_validate BEFORE INSERT OR UPDATE ON evaluation.verification_benchmark_arm_publication FOR EACH ROW EXECUTE FUNCTION evaluation.validate_verification_benchmark_arm_publication()`

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `control_plane`: using `(tenant_id = util.current_tenant_id())`; with check `(tenant_id = util.current_tenant_id())`
