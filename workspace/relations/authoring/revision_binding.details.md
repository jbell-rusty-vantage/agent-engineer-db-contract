---
id: "rel:authoring.revision_binding#details"
kind: details
schema: authoring
name: revision_binding
of: "rel:authoring.revision_binding"
workspace_fingerprint: "sha256:cb1a65412d0fb43423d4f775d78507ab4b320e27f820adab0423446aac89f036"
---
# authoring.revision_binding — details

Spill-over from [the main page](revision_binding.md).

## Relationships

Outbound: `tenant_id,assertion_id` → [`inquiry.assertion`](../inquiry/assertion.md)`.tenant_id,id` on delete restrict; `tenant_id,artifact_id` → [`orchestration.artifact`](../orchestration/artifact.md)`.tenant_id,id` on delete restrict; `tenant_id,capture_id` → [`evidence.source_capture`](../evidence/source_capture.md)`.tenant_id,id` on delete restrict; `tenant_id,claim_id` → [`evidence.claim`](../evidence/claim.md)`.tenant_id,id` on delete restrict; `tenant_id,entity_id` → [`catalog.entity`](../catalog/entity.md)`.tenant_id,id` on delete restrict; `tenant_id,locator_id` → [`evidence.locator`](../evidence/locator.md)`.tenant_id,id` on delete restrict; `tenant_id,record_id` → [`guidance.item`](../guidance/item.md)`.tenant_id,id` on delete restrict; `tenant_id,release_item_id` → [`authoring.release_item`](release_item.md)`.tenant_id,id` on delete restrict; `tenant_id,workspace_id,file_set_id` → [`authoring.file_set`](file_set.md)`.tenant_id,workspace_id,id` on delete restrict; `tenant_id,workspace_id,revision_id` → [`authoring.work_revision`](work_revision.md)`.tenant_id,workspace_id,id` on delete restrict; `tenant_id,workspace_id,target_revision_id` → [`authoring.work_revision`](work_revision.md)`.tenant_id,workspace_id,id` on delete restrict; `tenant_id,workspace_id,target_work_id` → [`authoring.work`](work.md)`.tenant_id,workspace_id,id` on delete restrict.
Inbound: [`authoring.release_item`](release_item.md).workspace_id,via_binding_id.

## Indexes

| Index | Definition |
| --- | --- |
| `revision_binding_assertion_fk_ix` | `CREATE INDEX revision_binding_assertion_fk_ix ON authoring.revision_binding USING btree (tenant_id, assertion_id)` |
| `revision_binding_tenant_id_artifact_id_fkey_ix` | `CREATE INDEX revision_binding_tenant_id_artifact_id_fkey_ix ON authoring.revision_binding USING btree (tenant_id, artifact_id)` |
| `revision_binding_tenant_id_capture_id_fkey_ix` | `CREATE INDEX revision_binding_tenant_id_capture_id_fkey_ix ON authoring.revision_binding USING btree (tenant_id, capture_id)` |
| `revision_binding_tenant_id_claim_id_fkey_ix` | `CREATE INDEX revision_binding_tenant_id_claim_id_fkey_ix ON authoring.revision_binding USING btree (tenant_id, claim_id)` |
| `revision_binding_tenant_id_entity_id_fkey_ix` | `CREATE INDEX revision_binding_tenant_id_entity_id_fkey_ix ON authoring.revision_binding USING btree (tenant_id, entity_id)` |
| `revision_binding_tenant_id_locator_id_fkey_ix` | `CREATE INDEX revision_binding_tenant_id_locator_id_fkey_ix ON authoring.revision_binding USING btree (tenant_id, locator_id)` |
| `revision_binding_tenant_id_record_id_fkey_ix` | `CREATE INDEX revision_binding_tenant_id_record_id_fkey_ix ON authoring.revision_binding USING btree (tenant_id, record_id)` |
| `revision_binding_tenant_id_release_item_id_fkey_ix` | `CREATE INDEX revision_binding_tenant_id_release_item_id_fkey_ix ON authoring.revision_binding USING btree (tenant_id, release_item_id)` |
| `revision_binding_tenant_id_workspace_id_file_set_id_fke_ix` | `CREATE INDEX revision_binding_tenant_id_workspace_id_file_set_id_fke_ix ON authoring.revision_binding USING btree (tenant_id, workspace_id, file_set_id)` |
| `revision_binding_tenant_id_workspace_id_id_key` | `CREATE UNIQUE INDEX revision_binding_tenant_id_workspace_id_id_key ON authoring.revision_binding USING btree (tenant_id, workspace_id, id)` |
| `revision_binding_tenant_id_workspace_id_revision_id_local_k_key` | `CREATE UNIQUE INDEX revision_binding_tenant_id_workspace_id_revision_id_local_k_key ON authoring.revision_binding USING btree (tenant_id, workspace_id, revision_id, local_key)` |
| `revision_binding_tenant_id_workspace_id_target_revision_ix` | `CREATE INDEX revision_binding_tenant_id_workspace_id_target_revision_ix ON authoring.revision_binding USING btree (tenant_id, workspace_id, target_revision_id)` |
| `revision_binding_tenant_id_workspace_id_target_work_id__ix` | `CREATE INDEX revision_binding_tenant_id_workspace_id_target_work_id__ix ON authoring.revision_binding USING btree (tenant_id, workspace_id, target_work_id)` |

## Triggers

- `immutable_guard` → [`product.guard_immutable`](../../functions/product/guard_immutable.md): `CREATE TRIGGER immutable_guard BEFORE DELETE OR UPDATE ON authoring.revision_binding FOR EACH ROW EXECUTE FUNCTION product.guard_immutable()`
- `seal_guard` → [`product.guard_unsealed_parent`](../../functions/product/guard_unsealed_parent.md): `CREATE TRIGGER seal_guard BEFORE INSERT ON authoring.revision_binding FOR EACH ROW EXECUTE FUNCTION product.guard_unsealed_parent('revision_id')`

## Row-level security

Enabled and forced.
- `product_api_all` (ALL) for `product_api_owner`: using `true`; with check `true`
