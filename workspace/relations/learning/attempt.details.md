---
id: "rel:learning.attempt#details"
kind: details
schema: learning
name: attempt
of: "rel:learning.attempt"
workspace_fingerprint: "sha256:216c4ae7230478c8e60934da25c852e10680d6caed71a662962ea3c0ac1676d3"
---
# learning.attempt — details

Spill-over from [the main page](attempt.md).

## Relationships

Outbound: `learner_id` → `auth.users``.id` on delete restrict; `tenant_id,option_id` → [`curriculum.requirement_option`](../curriculum/requirement_option.md)`.tenant_id,id` on delete restrict; `tenant_id,task_release_item_id` → [`authoring.release_item`](../authoring/release_item.md)`.tenant_id,id` on delete restrict; `tenant_id,workspace_id,enrollment_id,adoption_id` → [`learning.release_adoption`](release_adoption.md)`.tenant_id,workspace_id,enrollment_id,id` on delete restrict; `tenant_id,workspace_id,enrollment_id` → [`learning.enrollment`](enrollment.md)`.tenant_id,workspace_id,id` on delete restrict; `tenant_id,workspace_id,environment_session_id` → [`learning.environment_session`](environment_session.md)`.tenant_id,workspace_id,id` on delete restrict; `tenant_id,workspace_id,equivalence_request_id` → [`learning.equivalence_request`](equivalence_request.md)`.tenant_id,workspace_id,id` on delete restrict; `tenant_id,workspace_id` → [`authoring.workspace`](../authoring/workspace.md)`.tenant_id,id` on delete restrict; `tenant_id,workspace_id,mastery_decision_id` → [`learning.mastery_decision`](mastery_decision.md)`.tenant_id,workspace_id,id` on delete restrict; `tenant_id,workspace_id,previous_attempt_id` → [`learning.attempt`](attempt.md)`.tenant_id,workspace_id,id` on delete restrict; `tenant_id,workspace_id,task_revision_id` → [`authoring.work_revision`](../authoring/work_revision.md)`.tenant_id,workspace_id,id` on delete restrict.
Inbound: [`learning.attempt`](attempt.md).workspace_id,previous_attempt_id, [`learning.submission`](submission.md).workspace_id,attempt_id.

## Indexes

| Index | Definition |
| --- | --- |
| `attempt_learner_ix` | `CREATE INDEX attempt_learner_ix ON learning.attempt USING btree (learner_id, started_at)` |
| `attempt_tenant_id_option_id_fkey_ix` | `CREATE INDEX attempt_tenant_id_option_id_fkey_ix ON learning.attempt USING btree (tenant_id, option_id)` |
| `attempt_tenant_id_task_release_item_id_fkey_ix` | `CREATE INDEX attempt_tenant_id_task_release_item_id_fkey_ix ON learning.attempt USING btree (tenant_id, task_release_item_id)` |
| `attempt_tenant_id_workspace_id_enrollment_id_adoption_i_ix` | `CREATE INDEX attempt_tenant_id_workspace_id_enrollment_id_adoption_i_ix ON learning.attempt USING btree (tenant_id, workspace_id, enrollment_id, adoption_id)` |
| `attempt_tenant_id_workspace_id_enrollment_id_fkey_ix` | `CREATE INDEX attempt_tenant_id_workspace_id_enrollment_id_fkey_ix ON learning.attempt USING btree (tenant_id, workspace_id, enrollment_id)` |
| `attempt_tenant_id_workspace_id_environment_session_id_f_ix` | `CREATE INDEX attempt_tenant_id_workspace_id_environment_session_id_f_ix ON learning.attempt USING btree (tenant_id, workspace_id, environment_session_id)` |
| `attempt_tenant_id_workspace_id_equivalence_request_id_f_ix` | `CREATE INDEX attempt_tenant_id_workspace_id_equivalence_request_id_f_ix ON learning.attempt USING btree (tenant_id, workspace_id, equivalence_request_id)` |
| `attempt_tenant_id_workspace_id_id_key` | `CREATE UNIQUE INDEX attempt_tenant_id_workspace_id_id_key ON learning.attempt USING btree (tenant_id, workspace_id, id)` |
| `attempt_tenant_id_workspace_id_mastery_decision_id_fkey_ix` | `CREATE INDEX attempt_tenant_id_workspace_id_mastery_decision_id_fkey_ix ON learning.attempt USING btree (tenant_id, workspace_id, mastery_decision_id)` |
| `attempt_tenant_id_workspace_id_previous_attempt_id_fkey_ix` | `CREATE INDEX attempt_tenant_id_workspace_id_previous_attempt_id_fkey_ix ON learning.attempt USING btree (tenant_id, workspace_id, previous_attempt_id)` |
| `attempt_tenant_id_workspace_id_task_revision_id_fkey_ix` | `CREATE INDEX attempt_tenant_id_workspace_id_task_revision_id_fkey_ix ON learning.attempt USING btree (tenant_id, workspace_id, task_revision_id)` |

## Triggers

- `mutable_guard` → [`product.guard_mutable`](../../functions/product/guard_mutable.md): `CREATE TRIGGER mutable_guard BEFORE DELETE OR UPDATE ON learning.attempt FOR EACH ROW EXECUTE FUNCTION product.guard_mutable('state', 'ended_at', 'active_seconds', 'active_seconds_source')`

## Row-level security

Enabled and forced.
- `product_api_all` (ALL) for `product_api_owner`: using `true`; with check `true`
