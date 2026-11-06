---
id: "rel:evidence.source_capture#details"
kind: details
schema: evidence
name: source_capture
of: "rel:evidence.source_capture"
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# evidence.source_capture — details

Spill-over from [the main page](source_capture.md).

## Relationships

Outbound: `artifact_id` → [`orchestration.artifact`](../orchestration/artifact.md)`.id` (+tenant); `capture_method` → [`evidence.capture_method`](capture_method.md)`.code`; `tenant_id,knowledge_operation_id` → [`knowledge_service.operation`](../knowledge_service/operation.md)`.tenant_id,id` on delete restrict; `produced_by_attempt_id` → [`orchestration.attempt`](../orchestration/attempt.md)`.id` (+tenant); `source_id` → [`evidence.source`](source.md)`.id` (+tenant).
Inbound: [`content.document_version_source_capture`](../content/document_version_source_capture.md).source_capture_id, [`content.transformation_input`](../content/transformation_input.md).source_capture_id, [`corpus.repository_file`](../corpus/repository_file.md).capture_id, [`corpus.repository_revision`](../corpus/repository_revision.md).capture_id, [`evaluation.eval_case_provenance`](../evaluation/eval_case_provenance.md).source_capture_id, [`evidence.locator`](locator.md).capture_id, [`evidence.source`](source.md).last_capture_id, [`evidence.source_encounter`](source_encounter.md).capture_id, [`orchestration.verification_structured_extraction`](../orchestration/verification_structured_extraction.md).capture_id.

## Indexes

| Index | Definition |
| --- | --- |
| `source_capture_artifact_uq` | `CREATE UNIQUE INDEX source_capture_artifact_uq ON evidence.source_capture USING btree (artifact_id)` |
| `source_capture_knowledge_operation_idx` | `CREATE INDEX source_capture_knowledge_operation_idx ON evidence.source_capture USING btree (tenant_id, knowledge_operation_id) WHERE (knowledge_operation_id IS NOT NULL)` |
| `source_capture_sha_idx` | `CREATE INDEX source_capture_sha_idx ON evidence.source_capture USING btree (content_sha256)` |
| `source_capture_source_idx` | `CREATE INDEX source_capture_source_idx ON evidence.source_capture USING btree (source_id, captured_at DESC)` |
| `source_capture_tenant_id_uq` | `CREATE UNIQUE INDEX source_capture_tenant_id_uq ON evidence.source_capture USING btree (tenant_id, id)` |

## Triggers

- `artifact_retirement_c08714869d5afff48b340d4a` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md): `CREATE TRIGGER artifact_retirement_c08714869d5afff48b340d4a BEFORE INSERT OR UPDATE ON evidence.source_capture FOR EACH ROW EXECUTE FUNCTION orchestration.guard_retired_artifact_reference('[{"local": "tenant_id", "parent": "tenant_id"}, {"local": "artifact_id", "parent": "id"}]')`
- `artifact_retirement_f3374d238fdcd1b81b8410c2` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md): `CREATE TRIGGER artifact_retirement_f3374d238fdcd1b81b8410c2 BEFORE INSERT OR UPDATE ON evidence.source_capture FOR EACH ROW EXECUTE FUNCTION orchestration.guard_retired_artifact_reference('[{"local": "artifact_id", "parent": "id"}]')`
- `source_capture_artifact_binding` → [`evidence.validate_capture_artifact`](../../functions/evidence/validate_capture_artifact.md): `CREATE TRIGGER source_capture_artifact_binding BEFORE INSERT ON evidence.source_capture FOR EACH ROW EXECUTE FUNCTION evidence.validate_capture_artifact()`
- `source_capture_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md): `CREATE TRIGGER source_capture_immutable BEFORE DELETE OR UPDATE ON evidence.source_capture FOR EACH ROW EXECUTE FUNCTION util.reject_mutation()`

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: using `(tenant_id = util.current_tenant_id())`; with check `(tenant_id = util.current_tenant_id())`
