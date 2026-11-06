---
id: "rel:evaluation.verification_benchmark_comparison#details"
kind: details
schema: evaluation
name: verification_benchmark_comparison
of: "rel:evaluation.verification_benchmark_comparison"
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# evaluation.verification_benchmark_comparison — details

Spill-over from [the main page](verification_benchmark_comparison.md).

## Constraints
- PK (id)
- unique (tenant_id, id)
- unique (tenant_id, operation_id)
- check `verification_benchmark_compa_candidate_publication_sha256_check`: `(candidate_publication_sha256 ~ '^[0-9a-f]{64}$'::text)`
- check `verification_benchmark_compar_baseline_publication_sha256_check`: `(baseline_publication_sha256 ~ '^[0-9a-f]{64}$'::text)`
- check `verification_benchmark_compari_publication_payload_sha256_check`: `(publication_payload_sha256 ~ '^[0-9a-f]{64}$'::text)`
- check `verification_benchmark_compariso_candidate_payload_sha256_check`: `(candidate_payload_sha256 ~ '^[0-9a-f]{64}$'::text)`
- check `verification_benchmark_compariso_engineering_gate_outcome_check`: `(engineering_gate_outcome = ANY (ARRAY['not_requested'::text, 'pass'::text, 'fail'::text]))`
- check `verification_benchmark_comparison_baseline_payload_sha256_check`: `(baseline_payload_sha256 ~ '^[0-9a-f]{64}$'::text)`
- check `verification_benchmark_comparison_check`: `(candidate_run_id <> baseline_run_id)`
- check `verification_benchmark_comparison_check1`: `(candidate_publication_artifact_id <> baseline_publication_artifact_id)`
- check `verification_benchmark_comparison_check2`: `(((status = 'running'::text) AND (completed_at IS NULL) AND (result_artifact_id IS NULL) AND (result_sha256 IS NULL) AND (result_digest_sha256 IS NULL) AND (engineering_gate_outcome IS NULL) AND (publication_artifact_id IS NULL) AND (publication_sha256 IS NULL) AND (publication_payload_sha256 IS NULL)) OR ((status = 'completed'::text) AND (completed_at >= started_at) AND (result_artifact_id IS NOT NULL) AND (result_sha256 IS NOT NULL) AND (result_digest_sha256 IS NOT NULL) AND (engineering_gate_outcome IS NOT NULL) AND (publication_artifact_id IS NULL) AND (publication_sha256 IS NULL) AND (publication_payload_sha256 IS NULL)) OR ((status = 'sealed'::text) AND (completed_at >= started_at) AND (result_artifact_id IS NOT NULL) AND (result_sha256 IS NOT NULL) AND (result_digest_sha256 IS NOT NULL) AND (engineering_gate_outcome IS NOT NULL) AND (publication_artifact_id IS NOT NULL) AND (publication_sha256 IS NOT NULL) AND (publication_payload_sha256 IS NOT NULL)))`
- check `verification_benchmark_comparison_completion_required`: `((status = 'running'::text) OR (completed_at IS NOT NULL))`
- check `verification_benchmark_comparison_profile_id_check`: `(profile_id = ANY (ARRAY['paired_default'::text, 'regression_gate'::text]))`
- check `verification_benchmark_comparison_profile_sha256_check`: `(profile_sha256 ~ '^[0-9a-f]{64}$'::text)`
- check `verification_benchmark_comparison_publication_sha256_check`: `(publication_sha256 ~ '^[0-9a-f]{64}$'::text)`
- check `verification_benchmark_comparison_result_digest_sha256_check`: `(result_digest_sha256 ~ '^[0-9a-f]{64}$'::text)`
- check `verification_benchmark_comparison_result_sha256_check`: `(result_sha256 ~ '^[0-9a-f]{64}$'::text)`
- check `verification_benchmark_comparison_runtime_check`: `((jsonb_typeof(runtime) = 'object'::text) AND (octet_length((runtime)::text) <= 131072))`
- check `verification_benchmark_comparison_runtime_sha256_check`: `(runtime_sha256 ~ '^[0-9a-f]{64}$'::text)`
- check `verification_benchmark_comparison_status_check`: `(status = ANY (ARRAY['running'::text, 'completed'::text, 'sealed'::text]))`

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
