---
id: "rel:inquiry.support#details"
kind: details
schema: inquiry
name: support
of: "rel:inquiry.support"
workspace_fingerprint: "sha256:0bdaf1f915461feecb08d7ad5612fcb8db9039b883dd9c6e7e9be6d621251eee"
---
# inquiry.support — details

Spill-over from [the main page](support.md).

## Relationships

Outbound: `assessed_by` → `auth.users``.id` on delete restrict; `tenant_id,capture_id` → [`evidence.source_capture`](../evidence/source_capture.md)`.tenant_id,id` on delete restrict; `tenant_id,claim_id` → [`evidence.claim`](../evidence/claim.md)`.tenant_id,id` on delete restrict; `tenant_id,locator_id` → [`evidence.locator`](../evidence/locator.md)`.tenant_id,id` on delete restrict; `tenant_id,record_id` → [`guidance.item`](../guidance/item.md)`.tenant_id,id` on delete restrict; `tenant_id,workspace_id,assertion_id` → [`inquiry.assertion`](assertion.md)`.tenant_id,workspace_id,id` on delete restrict; `tenant_id,workspace_id,cell_id` → [`dataset.cell`](../dataset/cell.md)`.tenant_id,workspace_id,id` on delete restrict; `tenant_id,workspace_id,decision_revision_id` → [`authoring.work_revision`](../authoring/work_revision.md)`.tenant_id,workspace_id,id` on delete restrict; `tenant_id,workspace_id,source_revision_id` → [`authoring.work_revision`](../authoring/work_revision.md)`.tenant_id,workspace_id,id` on delete restrict; `tenant_id,workspace_id,target_assertion_id` → [`inquiry.assertion`](assertion.md)`.tenant_id,workspace_id,id` on delete restrict; `tenant_id,workspace_id,target_cell_id` → [`dataset.cell`](../dataset/cell.md)`.tenant_id,workspace_id,id` on delete restrict.
Inbound: none.

## Indexes

| Index | Definition |
| --- | --- |
| `support_assessed_by_fkey_ix` | `CREATE INDEX support_assessed_by_fkey_ix ON inquiry.support USING btree (assessed_by)` |
| `support_dataset_ix` | `CREATE INDEX support_dataset_ix ON inquiry.support USING btree (dataset_work_id, row_key, field_key) WHERE (dataset_work_id IS NOT NULL)` |
| `support_source_ix` | `CREATE INDEX support_source_ix ON inquiry.support USING btree (source_revision_id) WHERE (source_revision_id IS NOT NULL)` |
| `support_tenant_id_capture_id_fkey_ix` | `CREATE INDEX support_tenant_id_capture_id_fkey_ix ON inquiry.support USING btree (tenant_id, capture_id)` |
| `support_tenant_id_claim_id_fkey_ix` | `CREATE INDEX support_tenant_id_claim_id_fkey_ix ON inquiry.support USING btree (tenant_id, claim_id)` |
| `support_tenant_id_locator_id_fkey_ix` | `CREATE INDEX support_tenant_id_locator_id_fkey_ix ON inquiry.support USING btree (tenant_id, locator_id)` |
| `support_tenant_id_record_id_fkey_ix` | `CREATE INDEX support_tenant_id_record_id_fkey_ix ON inquiry.support USING btree (tenant_id, record_id)` |
| `support_tenant_id_workspace_id_assertion_id_fkey_ix` | `CREATE INDEX support_tenant_id_workspace_id_assertion_id_fkey_ix ON inquiry.support USING btree (tenant_id, workspace_id, assertion_id)` |
| `support_tenant_id_workspace_id_cell_id_fkey_ix` | `CREATE INDEX support_tenant_id_workspace_id_cell_id_fkey_ix ON inquiry.support USING btree (tenant_id, workspace_id, cell_id)` |
| `support_tenant_id_workspace_id_decision_revision_id_fke_ix` | `CREATE INDEX support_tenant_id_workspace_id_decision_revision_id_fke_ix ON inquiry.support USING btree (tenant_id, workspace_id, decision_revision_id)` |
| `support_tenant_id_workspace_id_id_key` | `CREATE UNIQUE INDEX support_tenant_id_workspace_id_id_key ON inquiry.support USING btree (tenant_id, workspace_id, id)` |
| `support_tenant_id_workspace_id_source_revision_id_fkey_ix` | `CREATE INDEX support_tenant_id_workspace_id_source_revision_id_fkey_ix ON inquiry.support USING btree (tenant_id, workspace_id, source_revision_id)` |
| `support_tenant_id_workspace_id_target_assertion_id_fkey_ix` | `CREATE INDEX support_tenant_id_workspace_id_target_assertion_id_fkey_ix ON inquiry.support USING btree (tenant_id, workspace_id, target_assertion_id)` |
| `support_tenant_id_workspace_id_target_cell_id_fkey_ix` | `CREATE INDEX support_tenant_id_workspace_id_target_cell_id_fkey_ix ON inquiry.support USING btree (tenant_id, workspace_id, target_cell_id)` |

## Triggers

- `immutable_guard` → [`product.guard_immutable`](../../functions/product/guard_immutable.md): `CREATE TRIGGER immutable_guard BEFORE DELETE OR UPDATE ON inquiry.support FOR EACH ROW EXECUTE FUNCTION product.guard_immutable()`

## Row-level security

Enabled and forced.
- `product_api_all` (ALL) for `product_api_owner`: using `true`; with check `true`
