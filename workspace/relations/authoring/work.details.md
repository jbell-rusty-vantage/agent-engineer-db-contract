---
id: "rel:authoring.work#details"
kind: details
schema: authoring
name: work
of: "rel:authoring.work"
workspace_fingerprint: "sha256:195a7bf46350274849f7ac517bb02381bbf8851afdacebee2c17dad0d348934c"
---
# authoring.work — details

Spill-over from [the main page](work.md).

## Relationships

Outbound: `created_by` → `auth.users``.id` on delete restrict; `tenant_id,workspace_id,id,head_revision_id` → [`authoring.work_revision`](work_revision.md)`.tenant_id,workspace_id,work_id,id` on delete restrict; `tenant_id,workspace_id` → [`authoring.workspace`](workspace.md)`.tenant_id,id` on delete restrict.
Inbound: [`authoring.distribution`](distribution.md).workspace_id,root_work_id, [`authoring.event`](event.md).workspace_id,work_id, [`authoring.revision_binding`](revision_binding.md).workspace_id,target_work_id, [`authoring.work_revision`](work_revision.md).workspace_id,work_id, [`dataset.cell`](../dataset/cell.md).workspace_id,dataset_work_id,dataset_kind, [`dataset.field`](../dataset/field.md).workspace_id,dataset_work_id,dataset_kind, [`dataset.proposal`](../dataset/proposal.md).workspace_id,dataset_work_id,dataset_kind, [`dataset.row`](../dataset/row.md).workspace_id,dataset_work_id,dataset_kind, [`inquiry.watch`](../inquiry/watch.md).workspace_id,brief_work_id, [`learning.environment_session`](../learning/environment_session.md).workspace_id,project_work_id, [`library.connected_item`](../library/connected_item.md).workspace_id,work_id, [`library.resource_control`](../library/resource_control.md).workspace_id,work_id, [`taxonomy.assignment`](../taxonomy/assignment.md).target_work_id.

## Indexes

| Index | Definition |
| --- | --- |
| `work_created_by_fkey_ix` | `CREATE INDEX work_created_by_fkey_ix ON authoring.work USING btree (created_by)` |
| `work_head_fk_ix` | `CREATE INDEX work_head_fk_ix ON authoring.work USING btree (tenant_id, workspace_id, id, head_revision_id)` |
| `work_tenant_id_id_key` | `CREATE UNIQUE INDEX work_tenant_id_id_key ON authoring.work USING btree (tenant_id, id)` |
| `work_tenant_id_workspace_id_id_key` | `CREATE UNIQUE INDEX work_tenant_id_workspace_id_id_key ON authoring.work USING btree (tenant_id, workspace_id, id)` |
| `work_tenant_id_workspace_id_id_kind_key` | `CREATE UNIQUE INDEX work_tenant_id_workspace_id_id_kind_key ON authoring.work USING btree (tenant_id, workspace_id, id, kind)` |
| `work_tenant_id_workspace_id_slug_key` | `CREATE UNIQUE INDEX work_tenant_id_workspace_id_slug_key ON authoring.work USING btree (tenant_id, workspace_id, slug)` |

## Triggers

- `mutable_guard` → [`product.guard_mutable`](../../functions/product/guard_mutable.md): `CREATE TRIGGER mutable_guard BEFORE DELETE OR UPDATE ON authoring.work FOR EACH ROW EXECUTE FUNCTION product.guard_mutable('head_revision_id')`

## Row-level security

Enabled and forced.
- `product_api_all` (ALL) for `product_api_owner`: using `true`; with check `true`
