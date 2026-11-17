---
id: "rel:authoring.revision_binding#details"
kind: details
schema: authoring
name: revision_binding
of: "rel:authoring.revision_binding"
workspace_fingerprint: "sha256:3cbce2e1f51948facb352a727c22966b1e5ceea4646ae43b07860ce6e83127b4"
---
# authoring.revision_binding — details

Spill-over from [the main page](revision_binding.md).

## Constraints
- PK (id)
- unique (tenant_id, workspace_id, id)
- unique (tenant_id, workspace_id, revision_id, local_key)
- check `revision_binding_check`: `(num_nonnulls(target_revision_id, target_work_id, artifact_id, capture_id, locator_id, claim_id, entity_id, record_id, release_item_id, file_set_id, assertion_id) = 1)`
- check `revision_binding_check1`: `((target_work_id IS NOT NULL) <= (relation = ANY (ARRAY['links_to'::text, 'contains'::text])))`
- check `revision_binding_check10`: `((relation <> 'source'::text) OR (capture_id IS NOT NULL) OR (locator_id IS NOT NULL))`
- check `revision_binding_check11`: `((relation <> 'has_component'::text) OR (target_revision_id IS NOT NULL))`
- check `revision_binding_check2`: `((release_item_id IS NOT NULL) <= (relation = ANY (ARRAY['adapted_from'::text, 'generated_under'::text, 'anchored_to'::text, 'scenario_of'::text])))`
- check `revision_binding_check3`: `((relation <> 'scenario_of'::text) OR (release_item_id IS NOT NULL) OR (target_revision_id IS NOT NULL))`
- check `revision_binding_check4`: `((assertion_id IS NOT NULL) <= (relation = ANY (ARRAY['uses'::text, 'supports'::text, 'contradicts'::text, 'links_to'::text])))`
- check `revision_binding_check5`: `((relation <> ALL (ARRAY['adapted_from'::text, 'generated_under'::text])) OR (release_item_id IS NOT NULL))`
- check `revision_binding_check6`: `((relation <> 'anchored_to'::text) OR (release_item_id IS NOT NULL) OR (target_revision_id IS NOT NULL))`
- check `revision_binding_check7`: `((file_set_id IS NOT NULL) <= (relation = ANY (ARRAY['representation'::text, 'uses'::text, 'evaluates_with'::text])))`
- check `revision_binding_check8`: `((relation <> ALL (ARRAY['links_to'::text, 'contains'::text])) OR (target_work_id IS NOT NULL) OR (target_revision_id IS NOT NULL) OR (assertion_id IS NOT NULL))`
- check `revision_binding_check9`: `((relation <> 'representation'::text) OR (artifact_id IS NOT NULL) OR (file_set_id IS NOT NULL))`
- check `revision_binding_local_key_check`: `(local_key ~ '^[a-z0-9][a-z0-9_.-]{0,62}$'::text)`
- check `revision_binding_relation_check`: `(relation = ANY (ARRAY['derived_from'::text, 'uses'::text, 'representation'::text, 'source'::text, 'supports'::text, 'contradicts'::text, 'covers'::text, 'targets'::text, 'derived_from_problem'::text, 'has_component'::text, 'adapted_from'::text, 'links_to'::text, 'contains'::text, 'evaluates_with'::text, 'generated_under'::text, 'anchored_to'::text, 'scenario_of'::text]))`
- check `revision_binding_rights_basis_check`: `product.nonblank(rights_basis)`
- check `revision_binding_role_check`: `(role = ANY (ARRAY['original'::text, 'transcript'::text, 'captions'::text, 'thumbnail'::text, 'poster'::text, 'accessible_fallback'::text, 'source'::text, 'build'::text, 'static_export'::text, 'lockfile'::text, 'starter'::text, 'solution'::text, 'hidden_check'::text, 'dataset'::text, 'environment_spec'::text]))`
- check `revision_binding_usage_check`: `(usage = ANY (ARRAY['reference_only'::text, 'private_copy'::text, 'redistributable'::text, 'unknown'::text]))`

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
