---
id: "rel:authoring.work_revision#details"
kind: details
schema: authoring
name: work_revision
of: "rel:authoring.work_revision"
workspace_fingerprint: "sha256:027ab2b6133d5d59318c478f06d832d89f937e563c387539f37fb3d7668818a8"
---
# authoring.work_revision — details

Spill-over from [the main page](work_revision.md).

## Relationships

Outbound: `created_by` → `auth.users``.id` on delete restrict; `tenant_id,workspace_id,purged_by_removal_id` → [`library.removal`](../library/removal.md)`.tenant_id,workspace_id,id` on delete restrict; `tenant_id,knowledge_seq` → [`temporal.knowledge_batch`](../temporal/knowledge_batch.md)`.tenant_id,knowledge_seq` on delete restrict; `tenant_id,workspace_id,work_id` → [`authoring.work`](work.md)`.tenant_id,workspace_id,id` on delete restrict; `tenant_id,workspace_id,work_id,parent_revision_id` → [`authoring.work_revision`](work_revision.md)`.tenant_id,workspace_id,work_id,id` on delete restrict.
Inbound: [`authoring.deployment`](deployment.md).workspace_id,revision_id, [`authoring.event`](event.md).workspace_id,work_id,revision_id, [`authoring.release`](release.md).workspace_id,root_work_id,root_revision_id, [`authoring.release_item`](release_item.md).workspace_id,revision_id, [`authoring.revision_binding`](revision_binding.md).workspace_id,revision_id|workspace_id,target_revision_id, [`authoring.revision_block`](revision_block.md).workspace_id,revision_id, [`authoring.runtime_requirement`](runtime_requirement.md).workspace_id,revision_id, [`authoring.work`](work.md).workspace_id,id,head_revision_id, [`authoring.work_revision`](work_revision.md).workspace_id,work_id,parent_revision_id, [`conversation.context_item`](../conversation/context_item.md).workspace_id,revision_id, [`curriculum.outcome`](../curriculum/outcome.md).workspace_id,revision_id, [`curriculum.outcome_alignment`](../curriculum/outcome_alignment.md).competency_revision_id, [`curriculum.part`](../curriculum/part.md).workspace_id,child_revision_id|workspace_id,parent_revision_id, [`curriculum.prerequisite`](../curriculum/prerequisite.md).workspace_id,required_revision_id|workspace_id,revision_id, [`curriculum.requirement`](../curriculum/requirement.md).workspace_id,revision_id, [`curriculum.requirement_option`](../curriculum/requirement_option.md).workspace_id,activity_revision_id, [`dataset.proposal`](../dataset/proposal.md).workspace_id,applied_revision_id, [`inquiry.acceptance`](../inquiry/acceptance.md).workspace_id,brief_work_id,brief_revision_id, [`inquiry.assertion`](../inquiry/assertion.md).workspace_id,revision_id, [`inquiry.delivery`](../inquiry/delivery.md).workspace_id,revision_id, [`inquiry.support`](../inquiry/support.md).workspace_id,decision_revision_id|workspace_id,source_revision_id, [`learning.assessment_result`](../learning/assessment_result.md).finalization_policy_revision_id, [`learning.attempt`](../learning/attempt.md).workspace_id,task_revision_id, [`learning.environment_session`](../learning/environment_session.md).spec_revision_id, [`learning.equivalence_request`](../learning/equivalence_request.md).workspace_id,work_revision_id, [`learning.evidence_item`](../learning/evidence_item.md).workspace_id,revision_id, [`learning.grading_run`](../learning/grading_run.md).pipeline_revision_id, [`learning.mastery_decision`](../learning/mastery_decision.md).competency_revision_id|policy_revision_id, [`learning.release_adoption`](../learning/release_adoption.md).workspace_id,personal_revision_id, [`library.connected_item`](../library/connected_item.md).workspace_id,work_id,synced_revision_id, [`library.passage`](../library/passage.md).workspace_id,revision_id, [`library.preparation`](../library/preparation.md).workspace_id,revision_id, [`retrieval.projection_target`](../retrieval/projection_target.md).authored_revision_id.
Polymorphic target of: [`retrieval.projection_target`](../retrieval/projection_target.md) (check constraint projection_target_exactly_one).

## Indexes

| Index | Definition |
| --- | --- |
| `work_revision_created_by_fkey_ix` | `CREATE INDEX work_revision_created_by_fkey_ix ON authoring.work_revision USING btree (created_by)` |
| `work_revision_purge_fk_ix` | `CREATE INDEX work_revision_purge_fk_ix ON authoring.work_revision USING btree (tenant_id, workspace_id, purged_by_removal_id)` |
| `work_revision_tenant_id_id_key` | `CREATE UNIQUE INDEX work_revision_tenant_id_id_key ON authoring.work_revision USING btree (tenant_id, id)` |
| `work_revision_tenant_id_knowledge_seq_fkey_ix` | `CREATE INDEX work_revision_tenant_id_knowledge_seq_fkey_ix ON authoring.work_revision USING btree (tenant_id, knowledge_seq)` |
| `work_revision_tenant_id_workspace_id_id_key` | `CREATE UNIQUE INDEX work_revision_tenant_id_workspace_id_id_key ON authoring.work_revision USING btree (tenant_id, workspace_id, id)` |
| `work_revision_tenant_id_workspace_id_work_id_id_key` | `CREATE UNIQUE INDEX work_revision_tenant_id_workspace_id_work_id_id_key ON authoring.work_revision USING btree (tenant_id, workspace_id, work_id, id)` |
| `work_revision_tenant_id_workspace_id_work_id_parent_rev_ix` | `CREATE INDEX work_revision_tenant_id_workspace_id_work_id_parent_rev_ix ON authoring.work_revision USING btree (tenant_id, workspace_id, work_id, parent_revision_id)` |
| `work_revision_tenant_id_workspace_id_work_id_revision_no_key` | `CREATE UNIQUE INDEX work_revision_tenant_id_workspace_id_work_id_revision_no_key ON authoring.work_revision USING btree (tenant_id, workspace_id, work_id, revision_no)` |

## Triggers

- `work_revision_guard` → [`product.guard_revision`](../../functions/product/guard_revision.md): `CREATE TRIGGER work_revision_guard BEFORE DELETE OR UPDATE ON authoring.work_revision FOR EACH ROW EXECUTE FUNCTION product.guard_revision()`
- `work_revision_sealed_at_commit` → [`product.check_revision_sealed`](../../functions/product/check_revision_sealed.md) (constraint trigger, deferred): `CREATE CONSTRAINT TRIGGER work_revision_sealed_at_commit AFTER INSERT ON authoring.work_revision DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION product.check_revision_sealed()`

## Row-level security

Enabled and forced.
- `product_api_all` (ALL) for `product_api_owner`: using `true`; with check `true`
