---
id: "rel:inquiry.acceptance#details"
kind: details
schema: inquiry
name: acceptance
of: "rel:inquiry.acceptance"
workspace_fingerprint: "sha256:fbf5703bf7a6f6131c452444ee949f1feec1bbe813c78d772fb3886b510815b9"
---
# inquiry.acceptance — details

Spill-over from [the main page](acceptance.md).

## Relationships

Outbound: `accepted_by` → `auth.users``.id` on delete restrict; `tenant_id,workspace_id,accepted_event_id` → [`authoring.event`](../authoring/event.md)`.tenant_id,workspace_id,id` on delete restrict; `tenant_id,workspace_id,brief_work_id,brief_revision_id` → [`authoring.work_revision`](../authoring/work_revision.md)`.tenant_id,workspace_id,work_id,id` on delete restrict; `tenant_id,workspace_id,revises_acceptance_id` → [`inquiry.acceptance`](acceptance.md)`.tenant_id,workspace_id,id` on delete restrict.
Inbound: [`dataset.proposal`](../dataset/proposal.md).workspace_id,acceptance_id, [`inquiry.acceptance`](acceptance.md).workspace_id,revises_acceptance_id, [`inquiry.obligation`](obligation.md).workspace_id,acceptance_id.

## Indexes

| Index | Definition |
| --- | --- |
| `acceptance_accepted_by_fkey_ix` | `CREATE INDEX acceptance_accepted_by_fkey_ix ON inquiry.acceptance USING btree (accepted_by)` |
| `acceptance_tenant_id_id_key` | `CREATE UNIQUE INDEX acceptance_tenant_id_id_key ON inquiry.acceptance USING btree (tenant_id, id)` |
| `acceptance_tenant_id_workspace_id_accepted_event_id_fke_ix` | `CREATE INDEX acceptance_tenant_id_workspace_id_accepted_event_id_fke_ix ON inquiry.acceptance USING btree (tenant_id, workspace_id, accepted_event_id)` |
| `acceptance_tenant_id_workspace_id_brief_work_id_acceptance__key` | `CREATE UNIQUE INDEX acceptance_tenant_id_workspace_id_brief_work_id_acceptance__key ON inquiry.acceptance USING btree (tenant_id, workspace_id, brief_work_id, acceptance_no)` |
| `acceptance_tenant_id_workspace_id_brief_work_id_brief_r_ix` | `CREATE INDEX acceptance_tenant_id_workspace_id_brief_work_id_brief_r_ix ON inquiry.acceptance USING btree (tenant_id, workspace_id, brief_work_id, brief_revision_id)` |
| `acceptance_tenant_id_workspace_id_id_key` | `CREATE UNIQUE INDEX acceptance_tenant_id_workspace_id_id_key ON inquiry.acceptance USING btree (tenant_id, workspace_id, id)` |
| `acceptance_tenant_id_workspace_id_revises_acceptance_id_ix` | `CREATE INDEX acceptance_tenant_id_workspace_id_revises_acceptance_id_ix ON inquiry.acceptance USING btree (tenant_id, workspace_id, revises_acceptance_id)` |

## Triggers

- `mutable_guard` → [`product.guard_mutable`](../../functions/product/guard_mutable.md): `CREATE TRIGGER mutable_guard BEFORE DELETE OR UPDATE ON inquiry.acceptance FOR EACH ROW EXECUTE FUNCTION product.guard_mutable('state', 'state_changed_at', 'spent_usd', 'budget_policy', 'mc_run_id')`

## Row-level security

Enabled and forced.
- `product_api_all` (ALL) for `product_api_owner`: using `true`; with check `true`
