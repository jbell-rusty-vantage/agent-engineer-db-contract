---
id: "rel:content.document_representation#details"
kind: details
schema: content
name: document_representation
of: "rel:content.document_representation"
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# content.document_representation — details

Spill-over from [the main page](document_representation.md).

## Relationships

Outbound: `tenant_id,artifact_id` → [`orchestration.artifact`](../orchestration/artifact.md)`.tenant_id,id` on delete restrict; `tenant_id,document_version_id` → [`content.document_version`](document_version.md)`.tenant_id,id` on delete restrict; `tenant_id,supersedes_id` → [`content.document_representation`](document_representation.md)`.tenant_id,id` on delete restrict; `tenant_id,transformation_run_id` → [`content.transformation_run`](transformation_run.md)`.tenant_id,id` on delete restrict.
Inbound: [`content.conversion_evaluation`](conversion_evaluation.md).representation_id, [`content.document_node`](document_node.md).representation_id, [`content.document_representation`](document_representation.md).supersedes_id, [`content.document_summary`](document_summary.md).derived_from_representation_id|representation_id, [`content.representation_decision`](representation_decision.md).representation_id, [`content.transformation_input`](transformation_input.md).representation_id, [`content.transformation_output`](transformation_output.md).representation_id, [`evidence.extraction_run`](../evidence/extraction_run.md).representation_id, [`retrieval.chunk_set`](../retrieval/chunk_set.md).representation_id, [`retrieval.packet_member`](../retrieval/packet_member.md).source_representation_id, [`retrieval.vector_store_document`](../retrieval/vector_store_document.md).representation_id.

## Indexes

| Index | Definition |
| --- | --- |
| `document_representation_tenant_id_id_key` | `CREATE UNIQUE INDEX document_representation_tenant_id_id_key ON content.document_representation USING btree (tenant_id, id)` |
| `representation_version_idx` | `CREATE INDEX representation_version_idx ON content.document_representation USING btree (tenant_id, document_version_id, created_at DESC)` |

## Triggers

- `artifact_retirement_b4c43d45f45a0674ce9260bf` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md): `CREATE TRIGGER artifact_retirement_b4c43d45f45a0674ce9260bf BEFORE INSERT OR UPDATE ON content.document_representation FOR EACH ROW EXECUTE FUNCTION orchestration.guard_retired_artifact_reference('[{"local": "tenant_id", "parent": "tenant_id"}, {"local": "artifact_id", "parent": "id"}]')`
- `document_representation_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md): `CREATE TRIGGER document_representation_immutable BEFORE DELETE OR UPDATE ON content.document_representation FOR EACH ROW EXECUTE FUNCTION util.reject_mutation()`
- `predecessor_direction` → [`util.validate_predecessor`](../../functions/util/validate_predecessor.md): `CREATE TRIGGER predecessor_direction BEFORE INSERT ON content.document_representation FOR EACH ROW EXECUTE FUNCTION util.validate_predecessor('supersedes_id')`

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: using `(tenant_id = util.current_tenant_id())`; with check `(tenant_id = util.current_tenant_id())`
