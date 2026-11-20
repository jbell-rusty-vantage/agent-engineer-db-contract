---
id: "rel:orchestration.verification_provider_attempt#details"
kind: details
schema: orchestration
name: verification_provider_attempt
of: "rel:orchestration.verification_provider_attempt"
workspace_fingerprint: "sha256:db20bac4d9e82d9b94cd2f3b580d4c145bcc3820969fdd572c6e7868ecca53fd"
---
# orchestration.verification_provider_attempt — details

Spill-over from [the main page](verification_provider_attempt.md).

## Relationships

Outbound: `tenant_id,operation_step_id` → [`knowledge_service.operation_step`](../knowledge_service/operation_step.md)`.tenant_id,id` on delete restrict; `tenant_id,operation_id` → [`knowledge_service.operation`](../knowledge_service/operation.md)`.tenant_id,id` on delete restrict; `tenant_id,profile_artifact_id` → [`orchestration.artifact`](artifact.md)`.tenant_id,id` on delete restrict; `tenant_id,request_artifact_id` → [`orchestration.artifact`](artifact.md)`.tenant_id,id`; `tenant_id,response_artifact_id` → [`orchestration.artifact`](artifact.md)`.tenant_id,id`; `tenant_id,budget_id` → [`orchestration.verification_provider_budget`](verification_provider_budget.md)`.tenant_id,id`.
Inbound: [`orchestration.verification_provider_reconciliation`](verification_provider_reconciliation.md).provider_attempt_id, [`orchestration.verification_provider_response_capture`](verification_provider_response_capture.md).provider_attempt_id, [`orchestration.verification_semantic_response_observation`](verification_semantic_response_observation.md).provider_attempt_id, [`orchestration.verification_structured_extraction`](verification_structured_extraction.md).provider_attempt_id.

## Indexes

| Index | Definition |
| --- | --- |
| `verification_provider_attempt_budget_idx` | `CREATE INDEX verification_provider_attempt_budget_idx ON orchestration.verification_provider_attempt USING btree (tenant_id, budget_id, created_at DESC)` |
| `verification_provider_attempt_dispatch_fence_idx` | `CREATE UNIQUE INDEX verification_provider_attempt_dispatch_fence_idx ON orchestration.verification_provider_attempt USING btree (tenant_id, dispatch_fence) WHERE (dispatch_fence IS NOT NULL)` |
| `verification_provider_attempt_legacy_request_ordinal_uq` | `CREATE UNIQUE INDEX verification_provider_attempt_legacy_request_ordinal_uq ON orchestration.verification_provider_attempt USING btree (tenant_id, request_sha256, attempt_ordinal) WHERE (operation_id IS NULL)` |
| `verification_provider_attempt_scoped_operation_ordinal_uq` | `CREATE UNIQUE INDEX verification_provider_attempt_scoped_operation_ordinal_uq ON orchestration.verification_provider_attempt USING btree (tenant_id, operation_id, attempt_ordinal) WHERE ((operation_id IS NOT NULL) AND (semantic_request_sha256 IS NULL))` |
| `verification_provider_attempt_semantic_request_ordinal_uq` | `CREATE UNIQUE INDEX verification_provider_attempt_semantic_request_ordinal_uq ON orchestration.verification_provider_attempt USING btree (tenant_id, operation_id, semantic_request_sha256, attempt_ordinal) WHERE (semantic_request_sha256 IS NOT NULL)` |
| `verification_provider_attempt_tenant_id_id_key` | `CREATE UNIQUE INDEX verification_provider_attempt_tenant_id_id_key ON orchestration.verification_provider_attempt USING btree (tenant_id, id)` |

## Triggers

- `artifact_retirement_1b738cfd4c1d15ff9a189011` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md): `CREATE TRIGGER artifact_retirement_1b738cfd4c1d15ff9a189011 BEFORE INSERT OR UPDATE ON orchestration.verification_provider_attempt FOR EACH ROW EXECUTE FUNCTION orchestration.guard_retired_artifact_reference('[{"local": "tenant_id", "parent": "tenant_id"}, {"local": "request_artifact_id", "parent": "id"}]')`
- `artifact_retirement_45d7ff20dba8b381a884abb4` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md): `CREATE TRIGGER artifact_retirement_45d7ff20dba8b381a884abb4 BEFORE INSERT OR UPDATE ON orchestration.verification_provider_attempt FOR EACH ROW EXECUTE FUNCTION orchestration.guard_retired_artifact_reference('[{"local": "tenant_id", "parent": "tenant_id"}, {"local": "response_artifact_id", "parent": "id"}]')`
- `artifact_retirement_9200d98417907621fee69324` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md): `CREATE TRIGGER artifact_retirement_9200d98417907621fee69324 BEFORE INSERT OR UPDATE ON orchestration.verification_provider_attempt FOR EACH ROW EXECUTE FUNCTION orchestration.guard_retired_artifact_reference('[{"local": "tenant_id", "parent": "tenant_id"}, {"local": "profile_artifact_id", "parent": "id"}]')`
- `verification_provider_attempt_artifact_admission` → [`orchestration.validate_verification_provider_artifacts`](../../functions/orchestration/validate_verification_provider_artifacts.md): `CREATE TRIGGER verification_provider_attempt_artifact_admission BEFORE INSERT OR UPDATE ON orchestration.verification_provider_attempt FOR EACH ROW EXECUTE FUNCTION orchestration.validate_verification_provider_artifacts()`
- `verification_provider_attempt_immutable` → [`orchestration.verification_provider_attempt_guard`](../../functions/orchestration/verification_provider_attempt_guard.md): `CREATE TRIGGER verification_provider_attempt_immutable BEFORE DELETE OR UPDATE ON orchestration.verification_provider_attempt FOR EACH ROW EXECUTE FUNCTION orchestration.verification_provider_attempt_guard()`
- `verification_provider_attempt_operation_claim` → [`orchestration.verification_provider_operation_claim`](../../functions/orchestration/verification_provider_operation_claim.md): `CREATE TRIGGER verification_provider_attempt_operation_claim BEFORE INSERT OR UPDATE ON orchestration.verification_provider_attempt FOR EACH ROW EXECUTE FUNCTION orchestration.verification_provider_operation_claim()`
- `verification_provider_attempt_scope_guard` → [`orchestration.verification_provider_attempt_scope_guard`](../../functions/orchestration/verification_provider_attempt_scope_guard.md): `CREATE TRIGGER verification_provider_attempt_scope_guard BEFORE DELETE OR UPDATE ON orchestration.verification_provider_attempt FOR EACH ROW EXECUTE FUNCTION orchestration.verification_provider_attempt_scope_guard()`
- `verification_provider_semantic_identity` → [`orchestration.verification_provider_semantic_identity`](../../functions/orchestration/verification_provider_semantic_identity.md): `CREATE TRIGGER verification_provider_semantic_identity BEFORE INSERT OR UPDATE ON orchestration.verification_provider_attempt FOR EACH ROW EXECUTE FUNCTION orchestration.verification_provider_semantic_identity()`
- `z_verification_semantic_dispatch_context` → [`orchestration.verification_semantic_dispatch_context`](../../functions/orchestration/verification_semantic_dispatch_context.md): `CREATE TRIGGER z_verification_semantic_dispatch_context BEFORE INSERT OR UPDATE ON orchestration.verification_provider_attempt FOR EACH ROW EXECUTE FUNCTION orchestration.verification_semantic_dispatch_context()`

## Row-level security

Enabled.
- `verification_provider_attempt_bounded_role_access` (ALL) for `control_plane`, `executor_service`, `verifier_agent`: using `(tenant_id = util.current_tenant_id())`; with check `(tenant_id = util.current_tenant_id())`
- `verification_provider_attempt_reader_access` (SELECT) for `app_reader`: using `(tenant_id = util.current_tenant_id())`
