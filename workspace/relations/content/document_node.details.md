---
id: "rel:content.document_node#details"
kind: details
schema: content
name: document_node
of: "rel:content.document_node"
workspace_fingerprint: "sha256:cb1a65412d0fb43423d4f775d78507ab4b320e27f820adab0423446aac89f036"
---
# content.document_node — details

Spill-over from [the main page](document_node.md).

## Constraints
- PK (id)
- unique (tenant_id, id)
- unique (tenant_id, representation_id, parent_id, ordinal)
- unique (tenant_id, representation_id, stable_local_key)
- unique (tenant_id, representation_id, id)
- check `document_node_check`: `((parent_id IS NULL) OR (parent_id <> id))`
- check `document_node_check1`: `((end_offset IS NULL) OR ((start_offset IS NOT NULL) AND (end_offset >= start_offset)))`
- check `document_node_check2`: `((end_ms IS NULL) OR ((start_ms IS NOT NULL) AND (end_ms >= start_ms)))`
- check `document_node_normalized_content_sha256_check`: `(normalized_content_sha256 ~ '^[0-9a-f]{64}$'::text)`
- check `document_node_ordinal_check`: `(ordinal >= 0)`
- check `document_node_start_ms_check`: `((start_ms IS NULL) OR (start_ms >= 0))`
- check `document_node_start_offset_check`: `((start_offset IS NULL) OR (start_offset >= 0))`

## Relationships

Outbound: `speaker_entity_id` → [`catalog.entity`](../catalog/entity.md)`.id`; `tenant_id,artifact_id` → [`orchestration.artifact`](../orchestration/artifact.md)`.tenant_id,id` on delete restrict; `tenant_id,parent_id` → [`content.document_node`](document_node.md)`.tenant_id,id` on delete restrict; `tenant_id,representation_id` → [`content.document_representation`](document_representation.md)`.tenant_id,id` on delete restrict; `unit_kind,unit_kind_version` → [`content.unit_kind`](unit_kind.md)`.code,version`.
Inbound: [`content.conversion_finding`](conversion_finding.md).node_id, [`content.document_digest`](document_digest.md).scope_node_id, [`content.document_node`](document_node.md).parent_id, [`content.document_node_edge`](document_node_edge.md).from_node_id|to_node_id, [`content.document_summary`](document_summary.md).scope_node_id, [`content.document_summary_source`](document_summary_source.md).node_id, [`content.unit_change`](unit_change.md).from_node_id|to_node_id, [`content.unit_entity_role`](unit_entity_role.md).node_id, [`content.unit_link`](unit_link.md).from_node_id|to_node_id, [`evidence.extraction_record`](../evidence/extraction_record.md).document_node_id, [`ranking.leaderboard_entry`](../ranking/leaderboard_entry.md).node_id, [`retrieval.chunk_span`](../retrieval/chunk_span.md).document_node_id, [`retrieval.packet_member`](../retrieval/packet_member.md).source_representation_id,source_document_node_id, [`retrieval.projection_target`](../retrieval/projection_target.md).document_node_id.

## Indexes

| Index | Definition |
| --- | --- |
| `document_node_logical_key_idx` | `CREATE INDEX document_node_logical_key_idx ON content.document_node USING btree (tenant_id, logical_key) WHERE (logical_key IS NOT NULL)` |
| `document_node_tenant_id_id_key` | `CREATE UNIQUE INDEX document_node_tenant_id_id_key ON content.document_node USING btree (tenant_id, id)` |
| `document_node_tenant_id_representation_id_parent_id_ordinal_key` | `CREATE UNIQUE INDEX document_node_tenant_id_representation_id_parent_id_ordinal_key ON content.document_node USING btree (tenant_id, representation_id, parent_id, ordinal)` |
| `document_node_tenant_id_representation_id_stable_local_key_key` | `CREATE UNIQUE INDEX document_node_tenant_id_representation_id_stable_local_key_key ON content.document_node USING btree (tenant_id, representation_id, stable_local_key)` |
| `document_node_tenant_representation_id_uq` | `CREATE UNIQUE INDEX document_node_tenant_representation_id_uq ON content.document_node USING btree (tenant_id, representation_id, id)` |
| `document_node_tree_idx` | `CREATE INDEX document_node_tree_idx ON content.document_node USING btree (tenant_id, representation_id, parent_id, ordinal)` |
| `document_node_unit_kind_idx` | `CREATE INDEX document_node_unit_kind_idx ON content.document_node USING btree (tenant_id, unit_kind)` |

## Triggers

- `artifact_retirement_5537e2f308b0b4387c6b3799` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md): `CREATE TRIGGER artifact_retirement_5537e2f308b0b4387c6b3799 BEFORE INSERT OR UPDATE ON content.document_node FOR EACH ROW EXECUTE FUNCTION orchestration.guard_retired_artifact_reference('[{"local": "tenant_id", "parent": "tenant_id"}, {"local": "artifact_id", "parent": "id"}]')`
- `document_node_attributes_valid` → [`content.validate_unit_attributes`](../../functions/content/validate_unit_attributes.md): `CREATE TRIGGER document_node_attributes_valid BEFORE INSERT ON content.document_node FOR EACH ROW EXECUTE FUNCTION content.validate_unit_attributes()`
- `document_node_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md): `CREATE TRIGGER document_node_immutable BEFORE DELETE OR UPDATE ON content.document_node FOR EACH ROW EXECUTE FUNCTION util.reject_mutation()`

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: using `(tenant_id = util.current_tenant_id())`; with check `(tenant_id = util.current_tenant_id())`
