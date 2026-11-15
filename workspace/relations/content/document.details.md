---
id: "rel:content.document#details"
kind: details
schema: content
name: document
of: "rel:content.document"
workspace_fingerprint: "sha256:195a7bf46350274849f7ac517bb02381bbf8851afdacebee2c17dad0d348934c"
---
# content.document — details

Spill-over from [the main page](document.md).

## Relationships

Outbound: `document_type_code` → [`content.document_type`](document_type.md)`.code`; `source_role_code` → [`content.source_role`](source_role.md)`.code`; `tenant_id,canonical_source_id` → [`evidence.source`](../evidence/source.md)`.tenant_id,id` on delete restrict; `tenant_id,created_by_attempt_id` → [`orchestration.attempt`](../orchestration/attempt.md)`.tenant_id,id` on delete restrict; `tenant_id,supersedes_id` → [`content.document`](document.md)`.tenant_id,id` on delete restrict; `work_entity_id` → [`catalog.entity`](../catalog/entity.md)`.id`.
Inbound: [`content.document`](document.md).supersedes_id, [`content.document_about_entity`](document_about_entity.md).document_id, [`content.document_identifier`](document_identifier.md).document_id, [`content.document_kind_assignment`](document_kind_assignment.md).document_id, [`content.document_version`](document_version.md).document_id, [`content.refresh_check`](refresh_check.md).document_id, [`content.unit_change`](unit_change.md).document_id, [`retrieval.vector_store_document`](../retrieval/vector_store_document.md).document_id.

## Indexes

| Index | Definition |
| --- | --- |
| `document_tenant_id_id_key` | `CREATE UNIQUE INDEX document_tenant_id_id_key ON content.document USING btree (tenant_id, id)` |
| `document_title_trgm_idx` | `CREATE INDEX document_title_trgm_idx ON content.document USING gin (canonical_title gin_trgm_ops)` |

## Triggers

- `document_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md): `CREATE TRIGGER document_immutable BEFORE DELETE OR UPDATE ON content.document FOR EACH ROW EXECUTE FUNCTION util.reject_mutation()`
- `document_work_integrity` → [`content.check_document_work`](../../functions/content/check_document_work.md): `CREATE TRIGGER document_work_integrity BEFORE INSERT OR UPDATE ON content.document FOR EACH ROW EXECUTE FUNCTION content.check_document_work()`
- `predecessor_direction` → [`util.validate_predecessor`](../../functions/util/validate_predecessor.md): `CREATE TRIGGER predecessor_direction BEFORE INSERT ON content.document FOR EACH ROW EXECUTE FUNCTION util.validate_predecessor('supersedes_id')`

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: using `(tenant_id = util.current_tenant_id())`; with check `(tenant_id = util.current_tenant_id())`
