---
id: "rel:content.document_summary#details"
kind: details
schema: content
name: document_summary
of: "rel:content.document_summary"
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# content.document_summary — details

Spill-over from [the main page](document_summary.md).

## Relationships

Outbound: `derived_from_representation_id` → [`content.document_representation`](document_representation.md)`.id` (+tenant); `document_version_id` → [`content.document_version`](document_version.md)`.id` (+tenant); `focus_entity_id` → [`corpus.entity`](../corpus/entity.md)`.id` (+tenant); `representation_id` → [`content.document_representation`](document_representation.md)`.id` (+tenant); `scope_node_id` → [`content.document_node`](document_node.md)`.id` (+tenant); `supersedes_id` → [`content.document_summary`](document_summary.md)`.id` (+tenant); `transformation_run_id` → [`content.transformation_run`](transformation_run.md)`.id` (+tenant).
Inbound: [`content.document_summary`](document_summary.md).supersedes_id, [`content.document_summary_source`](document_summary_source.md).summary_id, [`retrieval.projection_target`](../retrieval/projection_target.md).summary_id.
Polymorphic target of: [`retrieval.projection_target`](../retrieval/projection_target.md) (check constraint projection_target_check).

## Indexes

| Index | Definition |
| --- | --- |
| `document_summary_active_uq` | `CREATE UNIQUE INDEX document_summary_active_uq ON content.document_summary USING btree (tenant_id, document_version_id, summary_kind, scope, COALESCE(scope_node_id, '00000000-0000-0000-0000-000000000000'::uuid), COALESCE(focus_entity_id, '00000000-0000-0000-0000-000000000000'::uuid), audience) WHERE (lifecycle = 'active'::text)` |
| `document_summary_tenant_id_id_key` | `CREATE UNIQUE INDEX document_summary_tenant_id_id_key ON content.document_summary USING btree (tenant_id, id)` |

## Triggers

- `summary_content_immutable` → [`content.guard_summary_content`](../../functions/content/guard_summary_content.md): `CREATE TRIGGER summary_content_immutable BEFORE DELETE OR UPDATE ON content.document_summary FOR EACH ROW EXECUTE FUNCTION content.guard_summary_content()`
- `summary_lineage` → [`content.check_summary_lineage`](../../functions/content/check_summary_lineage.md) (constraint trigger, deferred): `CREATE CONSTRAINT TRIGGER summary_lineage AFTER INSERT OR UPDATE ON content.document_summary DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION content.check_summary_lineage()`
- `summary_sources_integrity` → [`content.check_summary_sources`](../../functions/content/check_summary_sources.md) (constraint trigger, deferred): `CREATE CONSTRAINT TRIGGER summary_sources_integrity AFTER INSERT OR UPDATE ON content.document_summary DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION content.check_summary_sources()`

## Row-level security

Enabled.
- `km_tenant_access` (ALL) for `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: using `(tenant_id = util.current_tenant_id())`; with check `(tenant_id = util.current_tenant_id())`
