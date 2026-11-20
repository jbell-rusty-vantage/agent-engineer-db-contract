---
id: "rel:evaluation.verification_benchmark_comparison#details"
kind: details
schema: evaluation
name: verification_benchmark_comparison
of: "rel:evaluation.verification_benchmark_comparison"
workspace_fingerprint: "sha256:db20bac4d9e82d9b94cd2f3b580d4c145bcc3820969fdd572c6e7868ecca53fd"
---
# evaluation.verification_benchmark_comparison — details

Spill-over from [the main page](verification_benchmark_comparison.md).

## Relationships

Outbound: `tenant_id,baseline_publication_artifact_id` → [`orchestration.artifact`](../orchestration/artifact.md)`.tenant_id,id` on delete restrict; `tenant_id,candidate_publication_artifact_id` → [`orchestration.artifact`](../orchestration/artifact.md)`.tenant_id,id` on delete restrict; `tenant_id,profile_artifact_id` → [`orchestration.artifact`](../orchestration/artifact.md)`.tenant_id,id` on delete restrict; `tenant_id,publication_artifact_id` → [`orchestration.artifact`](../orchestration/artifact.md)`.tenant_id,id` on delete restrict; `tenant_id,result_artifact_id` → [`orchestration.artifact`](../orchestration/artifact.md)`.tenant_id,id` on delete restrict; `tenant_id,candidate_run_id` → [`evaluation.verification_benchmark_run`](verification_benchmark_run.md)`.tenant_id,id` on delete restrict; `tenant_id,baseline_run_id` → [`evaluation.verification_benchmark_run`](verification_benchmark_run.md)`.tenant_id,id` on delete restrict; `tenant_id,operation_id` → [`knowledge_service.operation`](../knowledge_service/operation.md)`.tenant_id,id` on delete restrict.
Inbound: none.

## Indexes

| Index | Definition |
| --- | --- |
| `verification_benchmark_comparison_tenant_id_id_key` | `CREATE UNIQUE INDEX verification_benchmark_comparison_tenant_id_id_key ON evaluation.verification_benchmark_comparison USING btree (tenant_id, id)` |
| `verification_benchmark_comparison_tenant_id_operation_id_key` | `CREATE UNIQUE INDEX verification_benchmark_comparison_tenant_id_operation_id_key ON evaluation.verification_benchmark_comparison USING btree (tenant_id, operation_id)` |

## Triggers

- `artifact_retirement_2793df0bc457373312f506f2` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md): `CREATE TRIGGER artifact_retirement_2793df0bc457373312f506f2 BEFORE INSERT OR UPDATE ON evaluation.verification_benchmark_comparison FOR EACH ROW EXECUTE FUNCTION orchestration.guard_retired_artifact_reference('[{"local": "tenant_id", "parent": "tenant_id"}, {"local": "candidate_publication_artifact_id", "parent": "id"}]')`
- `artifact_retirement_484f6830ae82d12ccb1d1ce9` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md): `CREATE TRIGGER artifact_retirement_484f6830ae82d12ccb1d1ce9 BEFORE INSERT OR UPDATE ON evaluation.verification_benchmark_comparison FOR EACH ROW EXECUTE FUNCTION orchestration.guard_retired_artifact_reference('[{"local": "tenant_id", "parent": "tenant_id"}, {"local": "baseline_publication_artifact_id", "parent": "id"}]')`
- `artifact_retirement_5920b38d9f9dbee0056d415d` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md): `CREATE TRIGGER artifact_retirement_5920b38d9f9dbee0056d415d BEFORE INSERT OR UPDATE ON evaluation.verification_benchmark_comparison FOR EACH ROW EXECUTE FUNCTION orchestration.guard_retired_artifact_reference('[{"local": "tenant_id", "parent": "tenant_id"}, {"local": "publication_artifact_id", "parent": "id"}]')`
- `artifact_retirement_b95772d9fc022ad2b657f64a` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md): `CREATE TRIGGER artifact_retirement_b95772d9fc022ad2b657f64a BEFORE INSERT OR UPDATE ON evaluation.verification_benchmark_comparison FOR EACH ROW EXECUTE FUNCTION orchestration.guard_retired_artifact_reference('[{"local": "tenant_id", "parent": "tenant_id"}, {"local": "profile_artifact_id", "parent": "id"}]')`
- `artifact_retirement_e8da9ab59a00e56b121155c3` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md): `CREATE TRIGGER artifact_retirement_e8da9ab59a00e56b121155c3 BEFORE INSERT OR UPDATE ON evaluation.verification_benchmark_comparison FOR EACH ROW EXECUTE FUNCTION orchestration.guard_retired_artifact_reference('[{"local": "tenant_id", "parent": "tenant_id"}, {"local": "result_artifact_id", "parent": "id"}]')`
- `verification_benchmark_comparison_claim` → [`evaluation.validate_verification_benchmark_comparison_claim`](../../functions/evaluation/validate_verification_benchmark_comparison_claim.md): `CREATE TRIGGER verification_benchmark_comparison_claim BEFORE INSERT OR UPDATE ON evaluation.verification_benchmark_comparison FOR EACH ROW EXECUTE FUNCTION evaluation.validate_verification_benchmark_comparison_claim()`
- `verification_benchmark_comparison_custody` → [`evaluation.validate_verification_benchmark_comparison_custody`](../../functions/evaluation/validate_verification_benchmark_comparison_custody.md): `CREATE TRIGGER verification_benchmark_comparison_custody BEFORE INSERT OR UPDATE ON evaluation.verification_benchmark_comparison FOR EACH ROW EXECUTE FUNCTION evaluation.validate_verification_benchmark_comparison_custody()`
- `verification_benchmark_comparison_immutable` → [`evaluation.enforce_verification_benchmark_comparison_lifecycle`](../../functions/evaluation/enforce_verification_benchmark_comparison_lifecycle.md): `CREATE TRIGGER verification_benchmark_comparison_immutable BEFORE DELETE OR UPDATE ON evaluation.verification_benchmark_comparison FOR EACH ROW EXECUTE FUNCTION evaluation.enforce_verification_benchmark_comparison_lifecycle()`
- `verification_benchmark_comparison_semantic_binding` → [`evaluation.validate_verification_benchmark_comparison_semantic_binding`](../../functions/evaluation/validate_verification_benchmark_comparison_semantic_binding.md): `CREATE TRIGGER verification_benchmark_comparison_semantic_binding BEFORE INSERT OR UPDATE ON evaluation.verification_benchmark_comparison FOR EACH ROW EXECUTE FUNCTION evaluation.validate_verification_benchmark_comparison_semantic_binding()`
- `verification_benchmark_comparison_validate` → [`evaluation.validate_verification_benchmark_comparison`](../../functions/evaluation/validate_verification_benchmark_comparison.md): `CREATE TRIGGER verification_benchmark_comparison_validate BEFORE INSERT OR UPDATE ON evaluation.verification_benchmark_comparison FOR EACH ROW EXECUTE FUNCTION evaluation.validate_verification_benchmark_comparison()`

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `control_plane`: using `(tenant_id = util.current_tenant_id())`; with check `(tenant_id = util.current_tenant_id())`
